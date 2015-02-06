#include <algorithm>
#include <fstream>
#include <iterator>
#include <random>

#include <pvsutil/Logger.h>

#include <SkelCL/Map.h>
#include <SkelCL/SkelCL.h>
#include <SkelCL/Vector.h>
#include <SkelCL/Zip.h>
using namespace skelcl;

#include "../../common/IOHelper.hpp"
using namespace iohelper;

/* 
 * Unfinished LU-Decomposition
 *
 * Computes triangular matrix L only.
 * TODO Extract triangular matrix R.
 */
void decompose() {
	const int dim = 256;

	// Define operators
	Zip<float(float, float)> VSUB("float func(float x, float y) { return x - y; }");

	Map<float(float)> SMUL("float func(float x, float a) { return a * x; }");
	Map<float(float)> SDIV("float func(float x, float a) { return x / a; }");

	// Combines VSUB and SMUL
	Zip<float(float, float)> VSUBSMUL("float func(float x, float y, float a) { return x - (a * y); }");

	// Define the input matrix
	std::vector<Vector<float>> column(dim);
	for(int i = 0; i < dim; ++i) {
		column[i] = Vector<float>(dim);
		generateRandom<float>(column[i].begin(), column[i].end(), 1.0f, 3.0f);
	}

	// Decompose triangular matrix L
	for(int i = 0; i < dim; ++i) {
		for(int j = 0; j < i; ++j) {
			column[i] = VSUB( column[i], SMUL( column[j], column[i][j] ) );
			// column[i] = VSUBSMUL( column[i], column[j], column[i][j] );
		}
		column[i] = SDIV( column[i], column[i][i] );
	}
}

int main() {
  	// pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::DebugInfo);
	skelcl::init(skelcl::nDevices(1));

	decompose();

	return 0;
}

