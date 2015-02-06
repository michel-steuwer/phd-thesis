block lastSum(unsigned int end, __global block *scanedHistograms, __global block *rawHistograms){
  int i;
  block last1 = scanedHistograms[end];
  block last2 = rawHistograms[end];
  for(i=0; i<RADIX; i++){
    last1.data[i] += last2.data[i];
  }
  return last1;
}
