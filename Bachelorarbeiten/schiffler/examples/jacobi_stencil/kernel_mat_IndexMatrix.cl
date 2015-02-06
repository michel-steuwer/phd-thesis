// -*- c -*-

float func(IndexPoint pos, float_matrix_t input, float c0, float c1, int nx, int ny, int nz){

  int x = pos.x;
  int y = pos.y%ny;
  int z = pos.y/ny;
  bool outside = x==0 | x==nx-1 | y==0 | y==ny-1 | z==0 | z==nz-1;

  if(!outside)
    return c1 *
      (
       get(input, (pos.y-1),     pos.x)   +
       get(input, (pos.y+1),     pos.x)   +
       get(input, pos.y,     (pos.x-1))   +
       get(input, pos.y,     (pos.x+1))   +
       get(input, (pos.y-ny),    pos.x)   +
       get(input, (pos.y+ny),    pos.x)
    	) - get(input, pos.y, pos.x)  * c0;
  return get(input, pos.y, pos.x);
}
