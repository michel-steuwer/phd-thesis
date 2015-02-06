#include <sys/time.h>
#include <iterator>
#include <fstream>
#include <iostream>

#include <SkelCL/SkelCL.h>
#include <SkelCL/IndexMatrix.h>
#include <SkelCL/Map.h>
#include <pvsutil/Logger.h>

#define FILE_OUT "output_mat_im.bin"

using namespace skelcl;

template <typename Iterator>
void readGrid(Iterator iter, const char *filename, int nx, int ny, int nz){
  
  FILE *f = fopen(filename,"rb");
  float tmp;
  
  for(int i=0; i<nx*ny*nz; i++){
    fread(&tmp,sizeof(float),1,f);
    (*iter)=tmp;
    ++iter;
  }

  fclose(f);
}

template <typename Iterator>
void writeGrid(Iterator iter, const char *filename, int nx, int ny, int nz){

  FILE *f = fopen(filename,"w");
  float tmp;
  uint32_t tmp32=nx*ny*nz;
  
  fwrite(&tmp32, sizeof(uint32_t), 1, f);
  for(int i=0; i<nx*ny*nz; i++){
    tmp=*iter;
    fwrite(&tmp,sizeof(float),1,f);
    ++iter;
  }
  
  fclose(f);
}

template <typename Iterator>
void printGrid(Iterator iter, int nx, int ny, int nz){

  float tmp;
  for(int z=0; z<nz; z++){
    for(int y=0; y<ny; y++){
      for(int x=0; x<nx; x++){
	tmp=*iter;
	printf("%8.2f ",tmp);
	++iter;
      }
      printf("\n");
    }
    printf("\n");
  }
  printf("\n----------------\n");

}

long long get_time() {
  struct timeval tv;
  gettimeofday(&tv, NULL);
  return (tv.tv_sec * 1000000) + tv.tv_usec;
}

int main(int argc, char** argv){

  int nx, ny, nz;
  int iterations;
  float c0=1.0f/6.0f;
  float c1=1.0f/6.0f/6.0f;
  char* inputFilename;
  Matrix<float> input;
  Matrix<float> output;
  long long time0;
  long long time1;

  //Get parameters
  if (argc<6){
    printf("Usage: prog nx ny nz t file\n"
	   "nx:    the grid x dim      \n"
	   "ny:    the grid y dim      \n"
	   "nz:    the grid z dim      \n"
	   "t:     the iteration time  \n"
	   "file:  the input filename  \n"
	   );
    return -1;
  }
  nx = atoi(argv[1]);
  if (nx<1)
    return -1;
  ny = atoi(argv[2]);
  if (ny<1)
    return -1;
  nz = atoi(argv[3]);
  if (nz<1)
    return -1;
  iterations = atoi(argv[4]);
  if(iterations<1)
    return -1;
  if(!argv[5])
    return -1;
  inputFilename=argv[5];
   
  printf("Start jacobi stencil operation with dimensions x: %d, y: %d, z: %d, %d times\n", nx, ny, nz, iterations);
  
  //Read input file
  input = Matrix<float>({ny*nz, nx});
  readGrid(input.begin(), inputFilename, nx, ny, nz);

  time0 = get_time();

  detail::DeviceProperties d=nDevices(1);
  //detail::DeviceProperties d=allDevices();
  d.deviceType(device_type::GPU);
  skelcl::init(d);  

  //  pvsutil::defaultLogger.setLoggingLevel(pvsutil::Logger::Severity::DebugInfo);

  IndexMatrix pos({ny*nz, nx});
  output = Matrix<float>({ny*nz, nx});
  Matrix<float> *iPtr = &input;
  Matrix<float> *oPtr = &output;

  Map<float(IndexPoint)> f(std::ifstream("kernel_mat_IndexMatrix.cl"));

  //Begin computation
  pos.setDistribution(distribution::Block(pos));
  input.setDistribution(distribution::Copy(input));
  output.setDistribution(distribution::Block(output));

  for (int iter=0; iter<iterations; iter++){
    *oPtr = f(pos, *iPtr, c0, c1, nx, ny, nz);
    
    Matrix<float> *tmp;
    tmp=iPtr;
    iPtr=oPtr;
    oPtr=tmp;
    (*oPtr).copyDataToHost();

    (*iPtr).setDistribution(distribution::Copy(*iPtr));
    (*oPtr).setDistribution(distribution::Block(*oPtr));
  }

  //  printGrid(output.begin(), nx, ny, nz);

  //Get time                                                                                                                              
  time1=get_time();
  printf("%.12f\n", (float) (time1-time0) / 1000000);

  //Write output file
  printf("Begin write back\n");
  writeGrid(output.begin(), FILE_OUT, nx, ny, nz);
  
  return 0;
}
