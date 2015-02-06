/*
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
*/

/*
 * Updates the interior blocks of the input matrix.
 */
void updateInterior(IndexPoint ip,
		__global float *matrix, 
		uint dim, 
		__local float *perimeterRow,
		__local float *perimeterCol,
		uint offset)
{
	// Get the group id and the local id of the work item.
	int gridx	= get_group_id(0);
	int gridy	= get_group_id(1);
	int lidx	= get_local_id(0);
	int lidy	= get_local_id(1);

  	int globalRowId = offset + (gridy + 1) * BLOCK_SIZE;
  	int globalColId = offset + (gridx + 1) * BLOCK_SIZE;

  	int i;
  	float sum = 0;

	// Copy from global to local.
  	perimeterRow[lidy * BLOCK_SIZE + lidx] = matrix[(offset + lidy) * dim + globalColId + lidx];
  	perimeterCol[lidy * BLOCK_SIZE + lidx] = matrix[(globalRowId + lidy) * dim + offset + lidx];

  	barrier(CLK_LOCAL_MEM_FENCE);

	// Compute interior elements.
  	for(i = 0; i < BLOCK_SIZE; ++i) {
    	sum += perimeterCol[lidy * BLOCK_SIZE + i] * perimeterRow[i * BLOCK_SIZE + lidx];
	}
	// Write data to the global memory and subtract the sum calculated.
  	matrix[(globalRowId + lidy) * dim + globalColId + lidx] -= sum;
}

