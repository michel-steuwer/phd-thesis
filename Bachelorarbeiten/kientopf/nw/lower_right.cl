void func(Index index, int_matrix_t reference, __local int* l_ref, int i, int penalty, int n, int wgs)
{
	int lid = get_local_id(0) +1;
	//calculate start block-index
	int index_x = n -((i - (index / wgs)) * wgs); 
	int index_y = n -(((index / wgs) +1) * wgs);
	
	if(get_local_id(0) == 0){
		l_ref[0] = get(reference, index_y, index_x);
	}
	l_ref[lid] = 						get(reference, index_y, index_x + lid);
	l_ref[(wgs +1) * lid] = 	get(reference, index_y +lid, index_x);

	barrier(CLK_LOCAL_MEM_FENCE);
	
	// calculate upper left block
	for(int k = 1; k <= wgs; k++){
		if(lid <= k){
		  //read in data
			int d = l_ref[(wgs +1) * (lid -1) + k -lid] + get(reference, index_y + lid, index_x +k -lid +1);
			int l = l_ref[(wgs +1) * lid + k -lid] - penalty;
			int t = l_ref[(wgs +1) * (lid -1) + k -lid +1] - penalty;
			//calculate maximim
			if(t > l){
				if(t > d){
					d = t;
				}
			}else if(l > d){
				d = l;
			}
			//safe data
			if((index_x +k -lid +1 < n) && (index_y + lid < n)){
				l_ref[(wgs +1) * lid + k -lid +1] = d;
				set(reference, index_y + lid, index_x +k -lid +1, d);
			}
		}
		barrier(CLK_LOCAL_MEM_FENCE);
	}
	
	// calculate lower right block
	for(int k = 1; k <= wgs -1; k++){
		if((wgs -lid) >= k){
			//read in data
			int d = l_ref[(wgs +1) * (wgs -lid) + (k + lid -1)] + get(reference, index_y + (wgs -lid +1), index_x +k +lid);
			int l = l_ref[(wgs +1) * (wgs -lid +1) + (k +lid -1)]  - penalty;
			int t = l_ref[(wgs +1) * (wgs -lid) + (k +lid)]  - penalty;
			//calculate maximim
			if(t > l){
				if(t > d){
					d = t;
				}
			}else if(l > d){
				d = l;
			} 
			//safe data
				if((index_x +k +lid < n) && (index_y + (wgs -lid +1) < n)){
					l_ref[(wgs +1) * (wgs -lid +1) +k +lid] = d;
					set(reference, index_y + (wgs -lid +1), index_x +k +lid, d);
				}
		}
		barrier(CLK_LOCAL_MEM_FENCE);
	}
  return; 
}	
