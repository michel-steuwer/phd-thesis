#include <fstream>
#include <iostream>
#include <iterator>
#include <algorithm>

#include <SkelCL/SkelCL.h>

#include <SkelCL/IndexMatrix.h>
#include <SkelCL/MapOverlap.h>
#include <SkelCL/detail/Logger.h>

#define FILE_OUT "output_mo.bin"

using namespace skelcl;

template <typename Iterator>
void readGrid(Iterator iter, FILE *fp,int nx, int ny, int nz){
  
  float tmp;
  for(int z=0; z<nz; z++){
    for(int y=0; y<ny; y++){
      for(int x=0; x<nx; x++){
	fread(&tmp,sizeof(float),1,fp);
	(*iter)=tmp;
	++iter;
      }
    }
  }

}

template <typename Iterator>
void writeGrid(Iterator iter, FILE *fp,int nx, int ny, int nz){

  printf("Begin write back\n");
  float tmp;
  for(int x=0; x<nx; x++){
    for(int y=0; y<ny; y++){
      for(int z=0; z<nz; z++){
	tmp=*iter;
	fwrite(&tmp,sizeof(float),1,fp);
	++iter;
      }
    }
  }

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
  printf("\n\n----------------\n\n");

}

int main(int argc, char** argv){

  int nx,ny,nz;
  int iterations;
  float c0 = 1.0f/6.0f;
  float c1 = 1.0f/6.0f/6.0f;
  char* inputFile;

  //Get parameters
  if (argc<6){
    printf("Usage: prog nx ny nz t file\n"
	   "nx:    the grid size x\n"
	   "ny:    the grid size y\n"
	   "nz:    the grid size z\n"
	   "t:     the iteration time\n"
	   "file:  the input filename\n"
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
  inputFile=argv[5];

  printf("Start program with nx: %d, ny: %d, nz: %d\n",nx,ny,nz);

  skelcl::init();

  //Read input file  
  Matrix<float> input({ny*nz, nx});

  FILE *fp = fopen(inputFile,"rb");
  readGrid(input.begin(), fp, nx, ny, nz);
  fclose(fp);
  
  MapOverlap<float(float)> f(std::ifstream("kernel_mo.cl"), 1, SCL_NEUTRAL, -1);

  input.setDistribution(distribution::Overlap(input));

  for (int iter=0; iter<iterations; iter++){
    input = f(input, c0, c1);
    input.copyDataToHost();
  }

  //Write output file
  fp = fopen(FILE_OUT,"w+");
  writeGrid(input.begin(), fp, nx, ny, nz);
  fclose(fp);
  
  return 0;
}
