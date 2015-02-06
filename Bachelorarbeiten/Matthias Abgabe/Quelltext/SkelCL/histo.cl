block histogram(block unsortedBlock, uint shiftCount){
  int i;
  block rawHisto;
  
  for(i=0; i<RADIX; i++){
    rawHisto.data[i] = 0;
  }
  for(i=0; i<RADIX; i++){
    uint bucketPos = ((unsortedBlock.data[i] >> shiftCount) & BITMASK);
    rawHisto.data[bucketPos]++;
  }
  return rawHisto;
}
