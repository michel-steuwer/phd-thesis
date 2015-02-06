#ifndef MAIN_H
#define MAIN_H

#include <iostream>

#include <SkelCL/SkelCL.h>
#include <SkelCL/Vector.h>
#include <SkelCL/Map.h>
#include <SkelCL/Scan.h>
#include <SkelCL/Reduce.h>
#include <SkelCL/Zip.h>
#include <SkelCL/Out.h>
#include <SkelCL/Index.h>

//Konfiguration
const unsigned int NUM_ELEM = 0x1000000;
#define RADIX_BITS 3 //Blockgroesse 8
const int WORKGROUP_SIZE = 64;

//Automatisch
#define RADIX (1<<RADIX_BITS)
#define BITMASK (RADIX-1)
const unsigned int ITERATIONS = (sizeof(unsigned int)*8)%RADIX_BITS ? ((sizeof(unsigned int)*8)/RADIX_BITS) + 1 : (sizeof(unsigned int)*8)/RADIX_BITS;
const unsigned int NUM_BLOCKS = NUM_ELEM/RADIX;

SKELCL_ADD_DEFINE(RADIX)
SKELCL_ADD_DEFINE(BITMASK)

SKELCL_COMMON_DEFINITION(\
typedef struct {\
    unsigned int data[RADIX];\
} block;\
)

skelcl::Vector<block> numbersA;
skelcl::Vector<block> rawHistogram;
skelcl::Vector<block> scanedHistogram;
skelcl::Vector<block> sumBufferVec;
skelcl::Vector<block> scanedSumBufferVec;
skelcl::Vector<block> finalHistogram;
skelcl::Vector<block> numbersB;

skelcl::Vector<block> *unsortedPtr;
skelcl::Vector<block> *sortedPtr;

void runSort(skelcl::Map<block(block)> &createHistogram,
             skelcl::Scan<block(block)> &scanHistogram,
             skelcl::Map<block(unsigned int)> &createSumBuffer,
             skelcl::Map<block(block)> &scanBlock,
             skelcl::Map<block(block)> &fixOffset,
             skelcl::Map<void(block)> &permute);

void fillVectorRandom(skelcl::Vector<block> &input, unsigned int numBlocks);
void fillVectorZero(skelcl::Vector<block> &input, unsigned int numBlocks);
bool checkSorted(skelcl::Vector<block> &output);
void cleanup();

void printVector(std::string name, skelcl::Vector<block> &input);

#endif // MAIN_H
