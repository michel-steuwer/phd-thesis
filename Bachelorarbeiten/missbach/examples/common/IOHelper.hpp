#ifndef IOHELPER_H_
#define IOHELPER_H_

#include <algorithm>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <iterator>
#include <numeric>
#include <random>
#include <string>

namespace iohelper {

/* Writes the given input into filename. */
template<typename ForwardIterator>
void writeToFile(ForwardIterator begin, ForwardIterator end, const std::string& filename) {
	typedef typename std::iterator_traits<ForwardIterator>::value_type T;
	std::ofstream outfile(filename.c_str(), std::ios::binary | std::ios::ate);
	std::copy(begin, end, std::ostream_iterator<T>(outfile));
}

/* Reads input from filename. */
template<typename ForwardIterator>
void readFromFile(ForwardIterator begin, ForwardIterator end, const std::string& filename) {
	// TODO finish it!
}

/* Generates random numbers */
template<typename T, typename ForwardIterator>
void generateRandom(ForwardIterator begin, ForwardIterator end, const T& minRange, const T& maxRange) {
	std::random_device rDevice;
	srand(rDevice());

	while(begin != end) {
		*begin = minRange + T((maxRange - minRange) * double(rand()) / RAND_MAX);

		++begin;
	}
}

/* Write skelcl vector to standard output. */
template<typename T>
std::ostream& operator<<(std::ostream& os, const skelcl::Vector<T>& vec) {
	std::copy(vec.begin(), vec.end(), std::ostream_iterator<T>(os, " "));

	return os;
}

/* Write skelcl matrix to standard output. */
template<typename T>
std::ostream& operator<<(std::ostream& os, const skelcl::Matrix<T>& mat) {
	for(size_t i = 0; i < mat.rowCount(); ++i) {
		std::copy(mat.row_begin(i), mat.row_end(i), std::ostream_iterator<T>(os, " "));
		os << std::endl;
	}

	return os;
}

} /* namespace iohelper */

#endif /* IOHELPER_H_ */

