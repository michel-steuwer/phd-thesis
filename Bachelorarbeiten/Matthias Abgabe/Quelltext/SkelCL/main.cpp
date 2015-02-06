#include "main.h"
#include <pvsutil/Logger.h>
#include <pvsutil/Timer.h>

#define LOG_VECTORS 0
#define CHECK_MORE 0

using namespace skelcl;
using namespace std;

int main()
{
    srand(time(0));
    //pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::DebugInfo);
    pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::Info);
    skelcl::init(skelcl::nDevices(1).deviceType(device_type::GPU));
    LOG_DEBUG("init fertig");

    //Skels erzeugen
    Map<block(block)> createHistogram(std::ifstream("histo.cl"), "histogram");
    createHistogram.setWorkGroupSize(WORKGROUP_SIZE);
    LOG_DEBUG("createHistogram fertig");
    Scan<block(block)> scanHistogram(std::ifstream("add.cl"), "get_zero_block()", "add");
    scanHistogram.setWorkGroupSize(WORKGROUP_SIZE);
    LOG_DEBUG("scanHistogram fertig");
    Map<block(unsigned int)> createSumBuffer(std::ifstream("sumbuffer.cl"), "lastSum");
    LOG_DEBUG("createSumBuffer fertig");
    Map<block(block)> scanBlock(std::ifstream("scan.cl"), "scanBlock");
    scanBlock.setWorkGroupSize(WORKGROUP_SIZE);
    LOG_DEBUG("scanBlock fertig");
    Map<block(block)> fixOffset(std::ifstream("offset.cl"), "fixOffset");
    fixOffset.setWorkGroupSize(WORKGROUP_SIZE);
    LOG_DEBUG("fixOffset fertig");
    Map<void(block)> permute(std::ifstream("permute.cl"), "permute");
    permute.setWorkGroupSize(WORKGROUP_SIZE);
    LOG_DEBUG("permute fertig");
    LOG_DEBUG("Skels erzeugt");

    //Buffer fuellen
    fillVectorRandom(numbersA, NUM_BLOCKS);
    fillVectorZero(rawHistogram, NUM_BLOCKS);
    fillVectorZero(scanedHistogram, NUM_BLOCKS);
    fillVectorZero(sumBufferVec, 1);
    fillVectorZero(scanedSumBufferVec, 1);
    fillVectorZero(finalHistogram, NUM_BLOCKS);
    fillVectorZero(numbersB, NUM_BLOCKS);
    unsortedPtr = &numbersA;
    sortedPtr = &numbersB;
    LOG_DEBUG("Vektoren erzeugt");

    //Sortieren
    runSort(createHistogram, scanHistogram, createSumBuffer, scanBlock, fixOffset, permute);
    LOG_DEBUG("sortiert");

    //Probe
    if(!checkSorted(*unsortedPtr)){
        cleanup();
        return 1;
    }
    LOG_DEBUG("geprueft");

    //freigeben
    cleanup();
    LOG_DEBUG("fertig");
    return 0;
}

void fillVectorRandom(skelcl::Vector<block> &input, unsigned int numBlocks){
    input.clear();
    input.reserve(numBlocks);
    for(unsigned int i=0; i<numBlocks; i++){
        block randomBlock;
        for(int j=0; j<RADIX; j++){
            randomBlock.data[j]=rand();
        }
        input.push_back(randomBlock);
    }
}

void fillVectorZero(skelcl::Vector<block> &input, unsigned int numBlocks){
    block zeroBlock;
    for(int j=0; j<RADIX; j++){
        zeroBlock.data[j]=0;
    }
    input.resize(numBlocks, zeroBlock);
}

void cleanup(){
    skelcl::terminate();
}

void runSort(skelcl::Map<block(block)> &createHistogram,
             skelcl::Scan<block(block)> &scanHistogram,
             skelcl::Map<block(unsigned int)> &createSumBuffer,
             skelcl::Map<block(block)> &scanBlock,
             skelcl::Map<block(block)> &fixOffset,
             skelcl::Map<void(block)> &permute)
{
    //Out-Container
    Out<Vector<block>> numbersAOut(numbersA);
    Out<Vector<block>> rawHistogramOut(rawHistogram);
    Out<Vector<block>> scanedHistogramOut(scanedHistogram);
    Out<Vector<block>> sumBufferVecOut(sumBufferVec);
    Out<Vector<block>> scanedSumBufferVecOut(scanedSumBufferVec);
    Out<Vector<block>> finalHistogramOut(finalHistogram);
    Out<Vector<block>> numbersBOut(numbersB);

    Out<Vector<block>> *unsortedOutPtr = &numbersAOut;
    Out<Vector<block>> *sortedOutPtr = &numbersBOut;

    Vector<unsigned int> sumBufferIndex(1,NUM_BLOCKS-1);

    pvsutil::Timer sortTimer;
    for(unsigned int iteration=0; iteration<ITERATIONS; iteration++){
        LOG_DEBUG("beginne Iteration ", iteration);

        printVector("unsorted", *unsortedPtr);

        pvsutil::Timer iterationTimer;

        LOG_DEBUG("create Histogram");
        createHistogram(rawHistogramOut, *unsortedPtr, iteration*RADIX_BITS);
        rawHistogram.dataOnDeviceModified();

        printVector("rawHistogram", rawHistogram);

        LOG_DEBUG("scan Histogram");
        scanHistogram(scanedHistogramOut, rawHistogram);

        printVector("scanedHistogram", scanedHistogram);

        LOG_DEBUG("calculateSumBuffer");
        createSumBuffer(sumBufferVecOut, sumBufferIndex, scanedHistogram, rawHistogram);

        printVector("sumBuffer", sumBufferVec);

        LOG_DEBUG("scan SumBuffer");
        scanBlock(scanedSumBufferVecOut, sumBufferVec);

        printVector("scanedSumBuffer", scanedSumBufferVec);
	
        LOG_DEBUG("fix Offset");
        fixOffset(finalHistogramOut, scanedHistogram, scanedSumBufferVec);

        printVector("finalHistogram", finalHistogram);

        LOG_DEBUG("permute");
        permute(*unsortedPtr, finalHistogram, *sortedPtr, iteration*RADIX_BITS);
        (*sortedPtr).dataOnDeviceModified();

        printVector("sorted", *sortedPtr);

        LOG_DEBUG("vertausche sorted und unsorted");
        Vector<block> *vecSwap = sortedPtr;
        sortedPtr = unsortedPtr;
        unsortedPtr = vecSwap;
        Out<Vector<block>> *outSwap = sortedOutPtr;
        sortedOutPtr = unsortedOutPtr;
        unsortedOutPtr = outSwap;

        LOG_INFO("Iteration: ", iteration, "; Zeit: ",iterationTimer.stop(), "ms");
    }
    LOG_INFO("Anzahl Elemente: ", NUM_ELEM, "; Zeit zum Sortieren: ",sortTimer.stop(), "ms");
}

bool checkSorted(skelcl::Vector<block> &output){
    unsigned int last = 0;
    for(unsigned int i=0; i<NUM_ELEM/RADIX; i++){
        for(int j=0; j<RADIX; j++){
            unsigned int current = output[i].data[j];
#if CHECK_MORE
            if(current == 0){
                LOG_WARNING("0-Element gefunden: pos=", i*RADIX+j);
            }
            if(current == last){
                LOG_WARNING("Zwilling gefunden: pos=", i*RADIX+j,", val=",current);
            }
#endif
            if(last>current){
                LOG_ERROR("Sortierfehler: pos=",i*RADIX+j,", last=",last,", current=",current);
                return false;
            }
            last=current;
        }
    }
    return true;
}

void printVector(std::string name, skelcl::Vector<block> &input){
#if LOG_VECTORS
    cout << name << ": l=" << input.size() << "\n";
    for(std::vector<block>::const_iterator i=input.begin(); i!=input.end(); i++){
        for(int j=0; j<RADIX; j++){
            cout << i->data[j] << ",";
            if(j%32 == 31){
                cout << "\n";
            }
        }
        cout << "--\n";
    }
    cout << "\n";
#endif
}
