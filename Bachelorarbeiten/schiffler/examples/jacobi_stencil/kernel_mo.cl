// -*- C -*-

float func(float* input, float c0, float c1){
  bool outside = get(input, 0, 1) == -1 | get(input, 0,-1) == -1 | get(input, 1, 0) == -1 | get(input,-1, 0) == -1;
  
  if(!outside)
    return c1 *
      (
       get(input, 0, 1) +
       get(input, 0,-1) +
       get(input, 1, 0) +
       get(input,-1, 0)
       ) get(input, 0, 0) * c0;
  return get(input, 0, 0);
}
