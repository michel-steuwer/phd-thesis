// -*- c -*-

float func(int position, global float *input, float c0, float c1, int nx, int ny, int nz){

  int x = position%nx; 
  int y = position/ny%ny;
  int z = position/(nx*ny);
  bool outside = x==0 | x==nx-1 | y==0 | y==ny-1 | z==0 | z==nz-1;
  
  if(!outside)  
    return c1 *
      ( 
       input[position+1] +
       input[position-1] +
       input[position+nx] +
       input[position-nx] +
       input[position+nx*ny] +
       input[position-nx*ny] 
	) - input[position] * c0;
  return input[position];
}
