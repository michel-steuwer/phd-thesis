#include <chrono>
#include <ctime>
#include <iterator>
#include <numeric>
#include <ratio>
using namespace std::chrono;

#include <SkelCL/SkelCL.h>
#include <SkelCL/IndexVector.h>
#include <SkelCL/IndexMatrix.h>
#include <SkelCL/Map.h>
#include <SkelCL/Matrix.h>
using namespace skelcl;

#include <boost/program_options.hpp>
using namespace boost;
namespace po = boost::program_options;

#include "../../common/IOHelper.hpp"
using namespace iohelper;

#define VECTOR_SIZE 4
SKELCL_ADD_DEFINE(VECTOR_SIZE)

/* 
 * LU-Decomposition.
 * The dimension of the input matrix must be a multiple of 4.
 */
void LUDecomposition(Matrix<double>& matrix, duration<double>& executionTime) {
	// Decomposes the input matrix mat into a triangular matrix L.
	Map<void(Index)> DECOMPOSE_L(
		"void func(Index id,\n\
				__global double *mat, uint dim,\n\
				__global double *matL, uint dimL, uint d) {\n\
			int i = id + d;\n\
			if(i < dim) {\n\
				matL[i * dimL + d] = mat[i * dim + d] / mat[d * dim + d];\n\
			}\n\
		}"
	);
	// Decomposes rows of input matrix into the triangular matrix R.
	Map<void(IndexPoint)> DECOMPOSE_R(
		"void func(IndexPoint ip,\n\
				__global double4 *mat, uint dim,\n\
				__global double *matL, uint dimL, uint d) {\n\
			int xdim = dim / VECTOR_SIZE;\n\
			int i = ip.x + d / VECTOR_SIZE;\n\
			int j = ip.y + d;\n\
			if(j < dim && i < xdim && j >= (d + 1) && ((i + 1) * VECTOR_SIZE) > d) {\n\
				mat[j * xdim + i] -= mat[d * xdim + i] * matL[j * dim + d];\n\
			}\n\
		}"
	);
	// Combines triangular matrix mat and triangular matrix matL in matrix mat.
	Map<void(IndexPoint)> COMBINE(
		"void func(IndexPoint ip,\n\
				__global double *mat, uint dim,\n\
				__global double *matL, uint dimL) {\n\
			if(ip.y < dim && ip.x < dim && ip.y > ip.x) {\n\
				mat[ip.y * dim + ip.x] = matL[ip.y * dimL + ip.x];\n\
			}\n\
		}"
	);
	const unsigned int dim = matrix.rowCount();
	Matrix<double> matrixL({dim, dim});
	high_resolution_clock::time_point start = high_resolution_clock::now();

	for(unsigned int i = 0; i < dim - 1; ++i) {
		DECOMPOSE_L( IndexVector(dim - i), matrix, matrixL, i );
		DECOMPOSE_R( IndexMatrix({dim - i, dim - i}), matrix, matrixL, i );
	}
	COMBINE( IndexMatrix({dim, dim}), out(matrix), matrixL );
	matrix.copyDataToHost();

	high_resolution_clock::time_point stop = high_resolution_clock::now();
	executionTime = duration_cast<duration<double>>(stop - start);
}

/* Basic (sequential) LU-Decomposition. */
template<typename T>
void CPULUDecomposition(Matrix<T>& matrix) {
	for(size_t i = 0; i < matrix.rowCount() - 1; ++i) {
		// triangular matrix L
		for(size_t k = i + 1; k < matrix.columnCount(); ++k) {
			for(size_t j = 0; j < i; ++j) {
				matrix[k][i] -= matrix[k][j] * matrix[j][i];
			}
			matrix[k][i] /= matrix[i][i];
		}
		// triangular matrix R
		for(size_t k = i + 1; k < matrix.columnCount(); ++k) {
			for(size_t j = 0; j < i + 1; ++j) {
				matrix[i + 1][k] -= matrix[i + 1][j] * matrix[j][k];
			}
		}
	}
}

/* Verifies the result with given reference matrix. */
void verify(Matrix<double>& result, Matrix<double>& reference) {
	CPULUDecomposition(reference);
	// Inner product of reference and mean squared error (MSE) of result matrix.
	double ref = std::inner_product(reference.begin(), reference.end(), reference.begin(), 0.0);
	double error = std::inner_product(reference.begin(), reference.end(), result.begin(), 0.0,
			std::plus<double>(),
			[] (double x, double y) { return std::pow(x - y, 2.0); }
	);
	std::cout << "Verification:" << std::endl;
	std::cout << "\tError: " << std::sqrt(error) / std::sqrt(ref) << std::endl;
}

int main(int argc, char **argv) {
	size_t platformId 		= 0;
	size_t deviceId 		= 0;
	unsigned int dim		= 256; // Dimension of the input matrix.
	std::string infile, outfile;

	po::options_description desc("Options");
	desc.add_options()
		("help,h", 		"Print this message and exit.")
		("verify,v", 	"Verify the result.")
		("outputFile,o",	po::value<std::string>(&outfile),
		 	"Output file path.")
		("dimension,n", 	po::value<unsigned int>(&dim),
		 	"Matrix dimension,\nwhere dimension is a multiple of 4.")
		("platformId,p", 	po::value<size_t>(&platformId), 
			"Platform id from 0 to N-1,\nwhere N is the number of platforms available.")
		("deviceId,d", 		po::value<size_t>(&deviceId),
		 	"Device id from 0 to N-1,\nwhere N is the number of devices available.")
	;

	po::variables_map vm;
	try {
		po::store(po::parse_command_line(argc, argv, desc), vm);
		po::notify(vm);
	} catch(std::exception& e) {
		std::cerr << e.what() << std::endl;
		return 1;
	}

	if(vm.count("help")) {
		std::cout << "Usage: " << argv[0] << " [Options]" << std::endl;
		std::cout << desc << std::endl;
		return 0;
	}

	if(vm.count("deviceId") || vm.count("platformId")) {
		skelcl::init(skelcl::platform(platformId), skelcl::device(deviceId));
	} else {
		skelcl::init(skelcl::nDevices(1));
	}

	if(dim < 1 || dim > 65536) {
		std::cout << "Invalid value for option --dimension (1 < dimension < 65536)!" << std::endl;
		return 1;
	}

	// Dimension must be a mutiple of 4.
	unsigned int effDim = (dim % VECTOR_SIZE != 0) ? (dim - (dim % VECTOR_SIZE) + VECTOR_SIZE) : dim;
	// Fill input matrix.
	Matrix<double> matrix({effDim, effDim});
	generateRandom<double>(matrix.begin(), matrix.end(), 1.0, 8.0);

	// Reference matrix for verification.
	Matrix<double> reference({effDim, effDim});
	if(vm.count("verify")) {
		reference.assign(matrix.begin(), matrix.end());
	}

	// Perform LU-Decomposition.
	std::cout << "LU Decomposition with matrix dimension " << effDim << ":" << std::endl;
	duration<double> executionTime;
	LUDecomposition(matrix, executionTime);
	std::cout << "\tExecution time (seconds):\t" << executionTime.count() << std::endl;

	if(vm.count("verify")) {
		verify(matrix, reference);
	}
	// TODO Output the user defined matrix.
	if(vm.count("outputFile")) {
		writeToFile(matrix.begin(), matrix.end(), outfile);
	}

	return 0;
}

