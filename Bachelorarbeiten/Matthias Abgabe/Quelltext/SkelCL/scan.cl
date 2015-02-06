block scanBlock(block input){
    block scaned;
    uint sum = 0;
    for(int i=0; i<RADIX; i++){
        scaned.data[i] = sum;
        sum += input.data[i];
    }
    return scaned;
} 
