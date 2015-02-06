#include <algorithm>
#include <chrono>
#include <ctime>
#include <fstream>
#include <iterator>
#include <numeric>
#include <random>
#include <ratio>
using namespace std::chrono;

#include <SkelCL/IndexMatrix.h>
#include <SkelCL/IndexVector.h>
#include <SkelCL/Local.h>
#include <SkelCL/Map.h>
#include <SkelCL/Matrix.h>
#include <SkelCL/SkelCL.h>
using namespace skelcl;

#include <boost/program_options.hpp>
using namespace boost;
namespace po = boost::program_options;

#include "../../common/IOHelper.hpp"
using namespace iohelper;

/* Each block has BLOCK_SIZE rows and BLOCK_SIZE columns. */
#define BLOCK_SIZE 16
SKELCL_ADD_DEFINE(BLOCK_SIZE)

/* 
 * Decomposes the input matrix (in blocks) in a triangular submatrix L and R,
 * both are stored within the input matrix.
 *
 * A block is a BLOCK_SIZE by BLOCK_SIZE submatrix of the input matrix.
 */
void blockLUDecomposition(Matrix<float>& matrix) {
	// Decomposes a single block of the input matrix.
	// The first element within the block is at position (i, i) in the input matrix.
	Map<void(Index)> DECOMPOSE_DIAGONAL(std::ifstream("diagonal.cl"), std::string("decomposeDiagonal"));
	DECOMPOSE_DIAGONAL.setWorkGroupSize(BLOCK_SIZE);
	// Computes all perimeter blocks.
	Map<void(Index)> COMPUTE_PERIMETER(std::ifstream("perimeter.cl"), std::string("computePerimeter"));
	COMPUTE_PERIMETER.setWorkGroupSize(2 * BLOCK_SIZE);
	// Updates all interior blocks.
	Map<void(IndexPoint)> UPDATE_INTERIOR(std::ifstream("interior.cl"), std::string("updateInterior"));
	UPDATE_INTERIOR.setWorkGroupSize(BLOCK_SIZE * BLOCK_SIZE);

	const size_t dim = matrix.columnCount();
	for(unsigned int i = 0; i < dim; i += BLOCK_SIZE) {
		DECOMPOSE_DIAGONAL( IndexVector(BLOCK_SIZE),
				out(matrix),
				Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
				i );

		if(i + BLOCK_SIZE < dim) {
			size_t index = BLOCK_SIZE * ((dim - i) / BLOCK_SIZE - 1);
			COMPUTE_PERIMETER( IndexVector(2 * index),
					matrix,
					Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
					Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
					Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
					i );
			UPDATE_INTERIOR( IndexMatrix({index, index}),
					matrix,
					Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
					Local(sizeof(float) * BLOCK_SIZE * BLOCK_SIZE),
					i );
		}
	}
	// Wait for data being downloaded.
	matrix.copyDataToHost();
} 

int main(int argc, char **argv) {
	size_t platformId 	= 0;
	size_t deviceId 	= 0;
	size_t dim 			= 256; // Dimension of the input matrix.
	std::string outfile;

	po::options_description desc("Options");
	desc.add_options()
		("help,h",			"Print this message and exit.")
		("dimension,n",		po::value<size_t>(&dim),
		 	"Matrix dimension,\nwhere dimension is a multiple of 16.")
		("outputFile,o",	po::value<std::string>(&outfile),
		 	"Output file path.")
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

	// Dimension must be a multiple of 16.
	size_t effDim = (dim % BLOCK_SIZE != 0) ? (dim - (dim % BLOCK_SIZE) + BLOCK_SIZE) : dim;
	Matrix<float> matrix({effDim, effDim});
	generateRandom<float>(matrix.begin(), matrix.end(), 1.0, 3.0);

	std::cout << "Block LU Decomposition (dimension: " << effDim << "):" << std::endl;
	high_resolution_clock::time_point start = high_resolution_clock::now();
	blockLUDecomposition(matrix);
	high_resolution_clock::time_point stop = high_resolution_clock::now();
	duration<double> executionTime = duration_cast<duration<double>>(stop - start);
	std::cout << "\tTransfer and Execution time (seconds):\t" << executionTime.count() << std::endl;

	if(vm.count("outputFile")) { // Write matrix to outfile
		writeToFile(matrix.begin(), matrix.end(), outfile);
	}
	return 0;
}

