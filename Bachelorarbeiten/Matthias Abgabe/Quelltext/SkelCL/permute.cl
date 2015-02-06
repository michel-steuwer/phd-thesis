void permute(block unsortedBlock, __global block *finalHisto, __global block *sortedData, uint shiftCount){
  block modifiedHisto; //noetig?
  int i;
  int gid = get_global_id(0); 
  for(i=0;i<RADIX;i++){
    modifiedHisto.data[i]=finalHisto[gid].data[i];
  }
  for(i=0;i<RADIX;i++){
    uint item = unsortedBlock.data[i];
    uint bucketPos = ((item >> shiftCount) & BITMASK);
    uint movePos = modifiedHisto.data[bucketPos];
    sortedData[movePos/RADIX].data[movePos%RADIX] = item;
    modifiedHisto.data[bucketPos]++;
  }
}