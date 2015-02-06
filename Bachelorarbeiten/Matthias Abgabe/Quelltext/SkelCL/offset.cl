block fixOffset(block scanedHisto, __global block *sumBuffer){
  block finalHisto;
  int i;
  for(i=0; i<RADIX; i++){
    finalHisto.data[i]=scanedHisto.data[i]+sumBuffer[0].data[i];
  }
  return finalHisto;
}
