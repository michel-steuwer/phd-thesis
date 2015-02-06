block get_zero_block(){
  int i;
  block neutral;
  for(i=0;i<RADIX;i++){
    neutral.data[i] = 0;
  }
  return neutral;
}

block add(block a, block b){
  int i;
  block sum;
  for(i=0;i<RADIX;i++){
    sum.data[i] = a.data[i]+b.data[i];
  }
  return sum;
}
