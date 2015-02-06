// -*- C -*-

// double precision support (switch between as needed for NVIDIA/AMD)
// #pragma OPENCL EXTENSION cl_khr_fp64 : enable
// #pragma OPENCL EXTENSION cl_amd_fp64 : enable

// change to double if double precision needed

#define fp float

#define DEFAULT_ORDER 508

typedef struct record {
  int value;
} record;

typedef struct knode {
	int location;
	int indices [DEFAULT_ORDER + 1];
	int  keys [DEFAULT_ORDER + 1];
	bool is_leaf;
	int num_keys;
} knode; 

record func(int key, long height, int order, global knode *knodes, long knodes_elem, global record *records){

  long currKnode = 0;
  long offset = 0;
  record ans;
  ans.value = -1;

  for(int i=0; i<height; i++){
    for(int thid=0; thid < order; thid++)
      if(knodes[currKnode].keys[thid] <= key && knodes[currKnode].keys[thid+1] > key)
	if(knodes[offset].indices[thid] < knodes_elem)
	  offset = knodes[offset].indices[thid];
    currKnode=offset;
  }
  
  for(int thid=0; thid<order; thid++)
    if(knodes[currKnode].keys[thid] == key)
      ans.value = records[knodes[currKnode].indices[thid]].value;  

  return ans;
   
}
