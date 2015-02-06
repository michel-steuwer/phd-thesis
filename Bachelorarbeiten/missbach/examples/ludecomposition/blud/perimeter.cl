/*****************************************************************************************************************
LICENSE TERMS

Copyright (c)2008-2011 University of Virginia
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted without royalty fees or other restrictions, provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the University of Virginia, the Dept. of Computer Science, nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE UNIVERSITY OF VIRGINIA OR THE SOFTWARE AUTHORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

If you use this software or a modified version of it, please cite the most relevant among the following papers:

- M. A. Goodrum, M. J. Trotter, A. Aksel, S. T. Acton, and K. Skadron. Parallelization of Particle Filter Algorithms. In Proceedings 
of the 3rd Workshop on Emerging Applications and Many-core Architecture (EAMA), in conjunction with the IEEE/ACM International 
Symposium on Computer Architecture (ISCA), June 2010.

- S. Che, M. Boyer, J. Meng, D. Tarjan, J. W. Sheaffer, Sang-Ha Lee and K. Skadron.
"Rodinia: A Benchmark Suite for Heterogeneous Computing". IEEE International Symposium
on Workload Characterization, Oct 2009.

- J. Meng and K. Skadron. "Performance Modeling and Automatic Ghost Zone Optimization
for Iterative Stencil Loops on GPUs." In Proceedings of the 23rd Annual ACM International
Conference on Supercomputing (ICS), June 2009.

- L.G. Szafaryn, K. Skadron and J. Saucerman. "Experiences Accelerating MATLAB Systems
Biology Applications." in Workshop on Biomedicine in Computing (BiC) at the International
Symposium on Computer Architecture (ISCA), June 2009.

- M. Boyer, D. Tarjan, S. T. Acton, and K. Skadron. "Accelerating Leukocyte Tracking using CUDA:
A Case Study in Leveraging Manycore Coprocessors." In Proceedings of the International Parallel
and Distributed Processing Symposium (IPDPS), May 2009.

- S. Che, M. Boyer, J. Meng, D. Tarjan, J. W. Sheaffer, and K. Skadron. "A Performance
Study of General Purpose Applications on Graphics Processors using CUDA" Journal of
Parallel and Distributed Computing, Elsevier, June 2008.
*****************************************************************************************************************/

/*
 * Computes perimeter blocks by using the solved diagonal part of matrix.
 */
void computePerimeter(Index id,
		__global float *matrix,
		uint dim,
		__local float *perimeterRow,
		__local float *perimeterCol,
		__local float *diagonal,
		uint offset)
{
	int i, j;
	int arrayOffset;
    int idx;

	// Get the group id and the local id of this work item.
    int grpidx	= get_group_id(0);
	int lidx	= get_local_id(0);

	// Copy from global to local.
	if (lidx < BLOCK_SIZE) {
    	idx = lidx;
		// Copy half of the diagonal elements.
    	arrayOffset = offset * dim + offset;
    	for (i = 0; i < BLOCK_SIZE / 2; i++) {
    		diagonal[i * BLOCK_SIZE + idx] = matrix[arrayOffset + idx];
    		arrayOffset += dim;
		}
		// Copy perimeter elements.
    	arrayOffset = offset * dim + offset;
    	for (i = 0; i < BLOCK_SIZE; i++) {
      		perimeterRow[i * BLOCK_SIZE + idx] = matrix[arrayOffset + (grpidx + 1) * BLOCK_SIZE + idx];
      		arrayOffset += dim;
    	}
	} else {
    	idx = lidx - BLOCK_SIZE;
		// Copy half of the diagonal elements.
    	arrayOffset = (offset + BLOCK_SIZE / 2) * dim + offset;
    	for (i = BLOCK_SIZE / 2; i < BLOCK_SIZE; i++) {
      		diagonal[i * BLOCK_SIZE + idx] = matrix[arrayOffset + idx];
      		arrayOffset += dim;
    	}
		// Copy perimeter elements.
		arrayOffset = (offset + (grpidx + 1) * BLOCK_SIZE) * dim + offset;
		for (i = 0; i < BLOCK_SIZE; i++) {
			perimeterCol[i * BLOCK_SIZE + idx] = matrix[arrayOffset + idx];
			arrayOffset += dim;
		}
   	}

	barrier(CLK_LOCAL_MEM_FENCE);

	// Compute perimeter elements.
    if (lidx < BLOCK_SIZE) {
		// Computation of the perimeter rows.
		idx = lidx;
		for(i = 1; i < BLOCK_SIZE; i++) {
  			for (j = 0; j < i; j++) {
        		perimeterRow[i * BLOCK_SIZE + idx] -= diagonal[i * BLOCK_SIZE + j] * perimeterRow[j * BLOCK_SIZE + idx];
			}
    	}
	} else {
		// Computation of the perimeter columns.
    	idx = lidx - BLOCK_SIZE;
    	for(i = 0; i < BLOCK_SIZE; i++) {
      		for(j = 0; j < i; j++) {
        		perimeterCol[idx * BLOCK_SIZE + i] -= perimeterCol[idx * BLOCK_SIZE + j] * diagonal[j * BLOCK_SIZE + i];
			}
      		perimeterCol[idx * BLOCK_SIZE + i] /= diagonal[i * BLOCK_SIZE + i];
     	}
	}

	barrier(CLK_LOCAL_MEM_FENCE);

	if (lidx < BLOCK_SIZE) {
    	idx = lidx;
		// Write perimeter rows into global memory.
    	arrayOffset = (offset + 1) * dim + offset;
    	for(i = 1; i < BLOCK_SIZE; i++){
      		matrix[arrayOffset + (grpidx + 1) * BLOCK_SIZE + idx] = perimeterRow[i * BLOCK_SIZE + idx];
      		arrayOffset += dim;
    	}
	} else {
    	idx = lidx - BLOCK_SIZE;
		// Write perimeter columns into global memory.
    	arrayOffset = (offset + (grpidx + 1) * BLOCK_SIZE) * dim + offset;
    	for(i = 0; i < BLOCK_SIZE; i++){
      		matrix[arrayOffset + idx] =  perimeterCol[i * BLOCK_SIZE + idx];
      		arrayOffset += dim;
		}
	}
}

