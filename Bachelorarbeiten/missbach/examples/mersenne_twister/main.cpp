#include <algorithm>
#include <chrono>
#include <ctime>
#include <fstream>
#include <iterator>
#include <random>
#include <ratio>
using namespace std::chrono;

#include <SkelCL/Matrix.h>
#include <SkelCL/Map.h>
#include <SkelCL/SkelCL.h>
#include <SkelCL/Vector.h>
using namespace skelcl;

#include <boost/program_options.hpp>
using namespace boost;
namespace po = boost::program_options;

#include "../common/IOHelper.hpp"
using namespace iohelper;

/* The maximum number of random numbers to generate for each given seed - width of the LSFR. */
#define STATE_SIZE 8
SKELCL_ADD_DEFINE(STATE_SIZE)

SKELCL_COMMON_DEFINITION(
typedef struct {	\
	unsigned int x;	\
	unsigned int y;	\
	unsigned int z;	\
	unsigned int w;	\
} Seed128;			\
)

/* Prints some statistics. */
void printStatistics(unsigned int iterations,
		unsigned int numbersPerIteration,
		duration<double> elapsedTime) {
	using namespace std;

	unsigned long generatedNumbers = (1UL * numbersPerIteration) * iterations;
	double numbersPerSecond = generatedNumbers / elapsedTime.count();
	double kernelTime = elapsedTime.count() / iterations;

	cout << endl << "Statistics: " << endl
	 	 << "\tNumber of iterations:\t" << iterations << endl
	 	 << "\tNumbers generated:\t" << generatedNumbers << endl
	 	 << "\tElapsed time:\t\t" << elapsedTime.count() << " sec" << endl << endl
	 	 << "\tNumbers per second:\t" << numbersPerSecond / mega::num << " Mio/sec " << endl
	 	 << endl;
	if(iterations > 1) {
		cout << "\tIn each iteration:" << endl 
			<< "\tNumbers:\t\t" << numbersPerIteration << endl
			<< "\tKernel+Transfer time:\t" << kernelTime << " sec" << endl;
	}
}

/* Fills given vector<Seed128> with random numbers. */
template<typename ForwardIterator>
void fillSeedVector(ForwardIterator begin, ForwardIterator end) {
	std::random_device rDevice;
	srand(rDevice());
	while(begin != end) {
		begin->x = (unsigned int) rand();
		begin->y = (unsigned int) rand();
		begin->z = (unsigned int) rand();
		begin->w = (unsigned int) rand();
		++begin;
	}
}

/* Verifies the result matrix. */
void verifyResult(const Matrix<float>& result) {
	double sum = std::accumulate(result.begin(), result.end(), 0);
	double meanValue = std::fabs(sum) / result.rowCount() * result.columnCount();
	std::cout << "Verification (desired value is zero mean):" << std::endl;
	std::cout << "\tMean value: " << meanValue << std::endl;
}

/* Performs the mersenne twister number generation. */
void performNumberGeneration(Matrix<float>& numbers,
		duration<double>& executionTime,
		unsigned int seedCount,
		unsigned int multiplier,
		unsigned int iterations,
		const std::string& kernelFile) {
	Map<Seed128(Seed128)> TWISTER(std::ifstream(kernelFile.c_str()), std::string("generateGaussianRands"));
	Vector<Seed128> seeds(seedCount);
	fillSeedVector(seeds.begin(), seeds.end());

	// Warm up...
	for(unsigned int i = 0; i < 2 && iterations != 1; ++i) {
		TWISTER( seeds, numbers, 2 );
	}

	high_resolution_clock::time_point start = high_resolution_clock::now();
	// Perform number generation.
	for(unsigned int i = 0; i < iterations; ++i) {
		seeds = TWISTER( seeds, skelcl::out(numbers), multiplier );
		numbers.copyDataToHost();
	}
	high_resolution_clock::time_point stop = high_resolution_clock::now();
	executionTime = duration_cast<duration<double> >(stop - start);
}

int main(int argc, char **argv) {
	// Number of seeds - One seed is given to one generator, so seedCount equals the number of generators.
	unsigned int seedCount = 8192;
	// Number of 128-bit random numbers per generator.
	unsigned int multiplier = 2;
	// Number of iterations for the given implementation.
	unsigned int iterations = 1;
	// Specified implementation.
	std::string kernelFile("amd");
	std::string outputFile("out");

	int platformId 	= 0;
	int deviceId 	= 0;

	po::options_description desc("Options");
	desc.add_options()
		("help,h", "Print this message and exit.")
		("quiet,q", "Turn the text output off.")
		("display,s", "Display generated 32-bit random numbers.")
		("verify,v", "Verify the result.")
		("outputFile,o",	po::value(&outputFile),
		 	"Output file path.")
		("generators,n", 	po::value(&seedCount),
		 	"Number of SFMT-generators (outputs 32-bit float random numbers).")
		("rands,m", 		po::value(&multiplier),
		 	"Number of 128-bit random numbers per generator.")
		("iterations,i", 	po::value(&iterations),
		 	"Number of kernel iterations.")
		("impl,k", 			po::value(&kernelFile)->default_value("amd"),
		 	"Use specified SFMT-Implementation. Valid arguments:\n"
		 	"amd: \tAMD SDKs implementation. SFMT with box-muller transformation.\n"
			"new: \tNew SFMT-Implementation, but the same box-muller transformation.\n")
		("platformId,p", po::value(&platformId), 
			"Platform id from 0 to N-1,\nwhere N is the number of platforms available.")
		("deviceId,d", po::value(&deviceId),
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

	if(multiplier <= 1 || multiplier > STATE_SIZE) {
		std::cout << "Invalid value for the option --rands (2 <= m <= " 
			<< STATE_SIZE << ")!" << std::endl;
		return 1;
	}

	if(seedCount <= 0) {
		std::cout << "Invalid value for the option --generators (1 <= n)!." << std::endl;
		return 1;
	}

	if(vm.count("help")) {
		std::cout << "Usage: " << argv[0] << " [Options]" << std::endl;
		std::cout << desc << std::endl;
		return 0;
	}

	if(kernelFile.compare("new") == 0) {
		kernelFile = std::string("new_mersenne_twister.cl");
	} else if(kernelFile.compare("amd") == 0) {
		kernelFile = std::string("amd_mersenne_twister.cl");
	} else {
		std::cout << "Invalid value for the option --kernel!" << std::endl;
		return 1;
	}

	if(vm.count("deviceId") || vm.count("platformId")) {
		skelcl::init(skelcl::platform(platformId), skelcl::device(deviceId));
	} else {
		skelcl::init(skelcl::nDevices(1));
	}

	// Output matrix, for each given 128-bit seed 4 32-bit random numbers are generated.
	Matrix<float> numbers({seedCount, 4 * multiplier});
	duration<double> executionTime;
	performNumberGeneration(numbers, executionTime, seedCount, multiplier, iterations, kernelFile);

	if(!vm.count("quiet") && vm.count("display")) { // Display the result to the user.
		std::cout << numbers << std::endl;
	}
	if(!vm.count("quiet") && vm.count("verify")) { // Simple verification.
		verifyResult(numbers);
	}
	if(!vm.count("quiet")) { // Print some statistics.
		printStatistics(iterations, numbers.columnCount() * numbers.rowCount(), executionTime);
	}
	if(vm.count("outputFile")) { // Write output matrix into outputFile.
		writeToFile(numbers.begin(), numbers.end(), outputFile);
	}

	return 0;
}

