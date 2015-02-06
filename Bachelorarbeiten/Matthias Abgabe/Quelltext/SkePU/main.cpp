#include <iostream>

#define SKEPU_OPENMP

#include <skepu/vector.h>
#include <skepu/matrix.h>
#include <skepu/map.h>
#include <skepu/scan.h>
#include <skepu/maparray.h>

#include <pvsutil/Timer.h>

using namespace std;
using namespace skepu;

//Konfiguration
#define RADIX_BITS 3 //Blockgroesse 8
const unsigned int NUM_ELEM = 0x1000000;

//Automatisch
#define RADIX (1 << RADIX_BITS)
#define BITMASK (RADIX-1)
const unsigned int ITERATIONS = (sizeof(unsigned int)*8)%RADIX_BITS ? ((sizeof(unsigned int)*8)/RADIX_BITS) + 1 : (sizeof(unsigned int)*8)/RADIX_BITS;
const unsigned int NUM_BLOCKS = NUM_ELEM/RADIX;

#define LOG_VECTORS 0
#define CHECK_SORT 1
#define ADVANCED_CHECK 0

typedef struct {
    unsigned int data[RADIX];
} block;

UNARY_FUNC_CONSTANT(histo, block, unsigned int, unsorted, shiftCount,\
    int i;\
    block result;\
    for(i=0; i<RADIX; i++){\
        result.data[i]=0;\
    }\
    for(i=0; i<RADIX; i++){\
        int bucket = (unsorted.data[i] >> shiftCount) & BITMASK;\
        result.data[bucket]++;\
    }\
    return result;\
)

BINARY_FUNC(add, block, a, b, \
    int i;\
    block sum;\
    for(i=0; i<RADIX; i++){\
        sum.data[i] = a.data[i] + b.data[i];\
    }\
    return sum;\
)

BINARY_FUNC(scanBlock, block, scaned, raw,\
    block buffer;\
    uint sum = 0;\
    for(int i=0; i<RADIX; i++){\
        buffer.data[i] = sum;\
        sum += scaned.data[i] + raw.data[i];\
    }\
    return buffer;\
)

ARRAY_FUNC(addConstArray, block, sumBuffer, scanedHisto,\
    block sum;\
    int i;\
    for(i=0; i<RADIX; i++){\
        sum.data[i] = scanedHisto.data[i] + sumBuffer[0].data[i];\
    }\
    return sum;\
)

BINARY_FUNC_CONSTANT(permutePre, block, unsigned int, unsorted, histo, shiftCount,\
    int i;\
    block positions;\
    for(i=0; i<RADIX; i++){\
        int bucket = (unsorted.data[i] >> shiftCount) & BITMASK;\
        positions.data[i] = histo.data[bucket]; \
        histo.data[bucket] = histo.data[bucket]+1;\
    }\
    return positions;
)

ARRAY_FUNC_MATR(addressSwap, block, positionOut, positionIn, xidx, yidx,\
    int i;\
    for(i=0; i<RADIX; i++){\
        unsigned int bidx = positionIn.data[i]/RADIX;\
        unsigned int eidx = positionIn.data[i]%RADIX;\
        unsigned int srcAddr = (yidx << RADIX_BITS) + i;\
        positionOut[bidx].data[eidx] = srcAddr;\
    }\
    return positionIn;
)

ARRAY_FUNC(permuteFinal, block, unsorted, position,\
    int i;\
    block sorted;\
    for(i=0; i<RADIX; i++){\
        unsigned int bIdx = position.data[i]/RADIX;\
        unsigned int eIdx = position.data[i]%RADIX;\
        sorted.data[i] = unsorted[bIdx].data[eIdx];\
    }\
    return sorted;
)


void printVector(string name, Vector<block> &input){
#if LOG_VECTORS
    cout << name << ": l=" << input.size() << "\n";
    cout << std::hex;
    for(unsigned int i=0; i<input.size(); i++){
        const block current = input.at(i);
        for(unsigned int j=0; j<RADIX; j++){
            cout << current.data[j] << ",";
            if(j%32 == 31){
                cout << "\n";
            }
        }
        cout << "--\n";
    }
    cout << std::dec;
    cout << "\n";
#endif
}

block addBlockHost(const block &a, const block &b){
    block sum;
    for(int i=0; i<RADIX; i++){
        sum.data[i] = a.data[i]+b.data[i];
    }
    return sum;
}

void vectorToMatrix(Matrix<block> &mOut, const Vector<block> &vIn){
    for(unsigned int i=0; i<vIn.size(); i++){
        mOut.at(i,0) = vIn.at(i);
    }
}

void fillVectorZero(Vector<block> &target, unsigned int size){
    target.clear();
    target.reserve(size);
    for(unsigned int i=0; i<size; i++){
        block randomBlock;
        for(unsigned int j=0; j<RADIX; j++){
            randomBlock.data[j]=rand();
        }
        target.push_back(randomBlock);
    }
}

void fillVectorRandom(Vector<block> &target, unsigned int size){
    target.reserve(size);
    block zeroBlock;
    for(unsigned int j=0; j<RADIX; j++){
        zeroBlock.data[j] = 0;
    }
    target.assign(size, zeroBlock);
}

int main()
{
    srand(time(0));

    Map<histo> createHistogram(new histo);
    Scan<add> scanHistogram(new add);
    Map<scanBlock> scanSumBuffer(new scanBlock);
    MapArray<addConstArray> fixOffset(new addConstArray);
    Map<permutePre> permuteA(new permutePre);
    MapArray<addressSwap> permuteB(new addressSwap);
    MapArray<permuteFinal> permuteC(new permuteFinal);

    //init
    Vector<block> numbersA;
    Vector<block> numbersB;
    
    Vector<block> rawHistogram;
    Vector<block> scanedHistogram;
    Vector<block> scanedSumBufferVec;
    Vector<block> finalHistogram;
    
    Vector<block> positionsTarget;
    Matrix<block> positionsTargetMatrix(NUM_BLOCKS,1);
    Vector<block> positionsSource;

    Vector<block> *unsortedPtr = &numbersA;
    Vector<block> *sortedPtr = &numbersB;

    fillVectorRandom(numbersA, NUM_BLOCKS);
    fillVectorZero(numbersB, NUM_BLOCKS);
    fillVectorZero(rawHistogram, NUM_BLOCKS);
    fillVectorZero(scanedHistogram, NUM_BLOCKS);
    fillVectorZero(scanedSumBufferVec, 1);
    fillVectorZero(finalHistogram, NUM_BLOCKS);

    fillVectorZero(positionsTarget, NUM_BLOCKS);
    fillVectorZero(positionsSource, NUM_BLOCKS);

    //sortieren
    pvsutil::Timer timer;
    for(unsigned int iteration=0; iteration < ITERATIONS; iteration++){
	printVector("unsorted", *unsortedPtr);
        createHistogram.setConstant(iteration*RADIX_BITS);
        createHistogram(*unsortedPtr, rawHistogram);
	
        printVector("rawHistogram", rawHistogram);

        scanHistogram(rawHistogram, scanedHistogram, EXCLUSIVE);

        printVector("scanedHistogram", scanedHistogram);

        scanSumBuffer(scanedHistogram.end()-1, scanedHistogram.end(), rawHistogram.end()-1, rawHistogram.end(), scanedSumBufferVec.begin());
        
	printVector("scanedSumBuffer", scanedSumBufferVec);

        fixOffset(scanedSumBufferVec, scanedHistogram, finalHistogram);
        
	printVector("finalHistogram", finalHistogram);

        permuteA.setConstant(iteration*RADIX_BITS);
        permuteA(*unsortedPtr, finalHistogram, positionsTarget);
        printVector("positionsTarget", positionsTarget);
        vectorToMatrix(positionsTargetMatrix, positionsTarget);
        permuteB(positionsSource, positionsTargetMatrix, positionsTargetMatrix);
        printVector("positionsSource", positionsSource);
        permuteC(*unsortedPtr, positionsSource, *sortedPtr);

        printVector("sorted", *sortedPtr);
        Vector<block> *swap = unsortedPtr;
        unsortedPtr = sortedPtr;
        sortedPtr = swap;
    }
    double sort_ms = timer.stop();
    cout << "sorted " << NUM_ELEM << " numbers in " << sort_ms << "ms\n";
    //testen
#if CHECK_SORT
    unsigned int last = 0;
    //*unsortedPtr pruefen, da eben getauscht wurde
    for(unsigned int i = 0; i < numbersA.size(); i++){
        const block curBlock = unsortedPtr->at(i);
        for(int j=0; j<RADIX; j++){
            unsigned int current = curBlock.data[j];
#if ADVANCED_CHECK
            if(current == 0){
                cout << "0-Element gefunden: pos=" << i*RADIX+j << "\n";
            }
            if(current == last){
                cout << "Zwilling gefunden: pos=" << i*RADIX+j << ", val=" << current << "\n";
            }
#endif
            if(last>current){
                cout << "Sortierfehler: pos=" << i*RADIX+j << ", last=" << last << ", current=" << current << "\n";
            }
            last=current;
        }
    }
#endif
    return 0;
}

