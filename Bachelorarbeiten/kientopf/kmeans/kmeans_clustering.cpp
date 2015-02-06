/*****************************************************************************/
/*IMPORTANT:  READ BEFORE DOWNLOADING, COPYING, INSTALLING OR USING.         */
/*By downloading, copying, installing or using the software you agree        */
/*to this license.  If you do not agree to this license, do not download,    */
/*install, copy or use the software.                                         */
/*                                                                           */
/*                                                                           */
/*Copyright (c) 2005 Northwestern University                                 */
/*All rights reserved.                                                       */

/*Redistribution of the software in source and binary forms,                 */
/*with or without modification, is permitted provided that the               */
/*following conditions are met:                                              */
/*                                                                           */
/*1       Redistributions of source code must retain the above copyright     */
/*        notice, this list of conditions and the following disclaimer.      */
/*                                                                           */
/*2       Redistributions in binary form must reproduce the above copyright   */
/*        notice, this list of conditions and the following disclaimer in the */
/*        documentation and/or other materials provided with the distribution.*/ 
/*                                                                            */
/*3       Neither the name of Northwestern University nor the names of its    */
/*        contributors may be used to endorse or promote products derived     */
/*        from this software without specific prior written permission.       */
/*                                                                            */
/*THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS    */
/*IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED      */
/*TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT AND         */
/*FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL          */
/*NORTHWESTERN UNIVERSITY OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT,       */
/*INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES          */
/*(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR          */
/*SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)          */
/*HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,         */
/*STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN    */
/*ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE             */
/*POSSIBILITY OF SUCH DAMAGE.                                                 */
/******************************************************************************/

/*************************************************************************/
/**   File:         kmeans_clustering.c                                 **/
/**   Description:  Implementation of regular k-means clustering        **/
/**                 algorithm                                           **/
/**   Author:  Wei-keng Liao                                            **/
/**            ECE Department, Northwestern University                  **/
/**            email: wkliao@ece.northwestern.edu                       **/
/**                                                                     **/
/**   Edited by: Jay Pisharath                                          **/
/**              Northwestern University.                               **/
/**                                                                     **/
/**   ================================================================  **/
/**																		**/
/**   Edited by: Shuai Che, David Tarjan, Sang-Ha Lee					**/
/**				 University of Virginia									**/
/**																		**/
/**   Description:	No longer supports fuzzy c-means clustering;	 	**/
/**					only regular k-means clustering.					**/
/**					No longer performs "validity" function to analyze	**/
/**					compactness and separation crietria; instead		**/
/**					calculate root mean squared error.					**/
/**                                                                     **/
/*************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <float.h>
#include <math.h>
#include <omp.h>
#include "kmeans.h"
#include <chrono>						//+++
#include <fstream> 					//+++

#include <SkelCL/SkelCL.h>	//+++
#include <SkelCL/Vector.h>	//+++
#include <SkelCL/Matrix.h>  //+++
#include <SkelCL/IndexVector.h> //+++
#include <SkelCL/Map.h>	//+++

#define RANDOM_MAX 2147483647

extern double wtime(void);

/*----< kmeans_clustering() >---------------------------------------------*/
float** kmeans_clustering(float **feature,    /* in: [npoints][nfeatures] */
                          int     nfeatures,
                          int     npoints,
                          int     nclusters,
                          float   threshold,
                          int    *membership, /* out: [npoints] */
                          skelcl::Matrix<float> *feature_matrix, //+++matrix with input values+++
                          int   *membership_OCL) //+++pointer to membership+++
{    
    int      i, j, n = 0;				/* counters */
	int		 loop=0, temp;
    int     *new_centers_len;	/* [nclusters]: no. of points in each cluster */
    float    delta;				/* if the point moved */
    float  **clusters;			/* out: [nclusters][nfeatures] */
    float  **new_centers;		/* [nclusters][nfeatures] */

	int     *initial;			/* used to hold the index of points not yet selected
								   prevents the "birthday problem" of dual selection (?)
								   considered holding initial cluster indices, but changed due to
								   possible, though unlikely, infinite loops */
	int      initial_points;
	int		 c = 0;

	/* nclusters should never be > npoints
	   that would guarantee a cluster without points */
	if (nclusters > npoints)
		nclusters = npoints;

    /* allocate space for and initialize returning variable clusters[] */
    clusters    = (float**) malloc(nclusters *             sizeof(float*));
    clusters[0] = (float*)  malloc(nclusters * nfeatures * sizeof(float));
    for (i=1; i<nclusters; i++)
        clusters[i] = clusters[i-1] + nfeatures;
    skelcl::Matrix<float> *cluster_matrix = new skelcl::Matrix<float>({nclusters, nfeatures}); //+++matrix for cluster centers+++

	/* initialize the random clusters */
	initial = (int *) malloc (npoints * sizeof(int));
	for (i = 0; i < npoints; i++)
	{
		initial[i] = i;
	}
	initial_points = npoints;

    /* randomly pick cluster centers */
    for (i=0; i<nclusters && initial_points >= 0; i++) {
		//n = (int)rand() % initial_points;		
		
        for (j=0; j<nfeatures; j++) {
            clusters[i][j] = feature[initial[n]][j];	// remapped
            (*cluster_matrix)[i][j] = feature[initial[n]][j]; //+++set cluster centers+++
        }

		/* swap the selected index to the end (not really necessary,
		   could just move the end up) */
		temp = initial[n];
		initial[n] = initial[initial_points-1];
		initial[initial_points-1] = temp;
		initial_points--;
		n++;
    }

	/* initialize the membership to -1 for all */
		int* membership2 = (int*) malloc(npoints * sizeof(int)); //+++second membership+++
    for (i=0; i < npoints; i++){
			membership[i] = -1;
			membership2[i] = -1; //+++set values to -1+++
		}

    /* allocate space for and initialize new_centers_len and new_centers */
    new_centers_len = (int*) calloc(nclusters, sizeof(int));
    int* new_centers_len2 = (int*) calloc(nclusters, sizeof(int)); //+++second new_centers_len+++

    new_centers    = (float**) malloc(nclusters *            sizeof(float*));
    new_centers[0] = (float*)  calloc(nclusters * nfeatures, sizeof(float));
    float** new_centers2    = (float**) malloc(nclusters *            sizeof(float*)); //+++second new_center+++
    new_centers2[0] = (float*)  calloc(nclusters * nfeatures, sizeof(float)); //+++
    
    for (i=1; i<nclusters; i++){
        new_centers[i] = new_centers[i-1] + nfeatures;
        new_centers2[i] = new_centers2[i-1] + nfeatures; //+++
    }

	auto t1 = std::chrono::high_resolution_clock::now(); //+++timestamp+++  
	skelcl::Map<int(skelcl::Index)> clusterix(std::ifstream("kmeans.skelcl"));	  
	auto t2 = std::chrono::high_resolution_clock::now(); //+++timestamp+++ 
	LOG_INFO("SkelCL prepair skeleton: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count(), "ms");  //logging the runtime
	
	auto topencl = std::chrono::high_resolution_clock::now() - std::chrono::high_resolution_clock::now(); //+++timestamp+++
	auto tskelcl = std::chrono::high_resolution_clock::now() - std::chrono::high_resolution_clock::now(); //+++timestamp+++
	
	/* iterate until convergence */
	do {
    delta = 0.0;     
        
		// CUDA
		auto t1 = std::chrono::high_resolution_clock::now(); //+++timestamp+++
		delta = (float) kmeansOCL(feature,			/* in: [npoints][nfeatures] */
								   nfeatures,		/* number of attributes for each point */
								   npoints,			/* number of data points */
								   nclusters,		/* number of clusters */
								   membership,		/* which cluster the point belongs to */
								   clusters,		/* out: [nclusters][nfeatures] */
								   new_centers_len,	/* out: number of points in each cluster */
								   new_centers		/* sum of points in each cluster */
								   );
								   
		auto t2 = std::chrono::high_resolution_clock::now(); //+++timestamp+++
		topencl = topencl + (t2-t1);

		float delta2 = kmeansOCL2(feature,	
								   nfeatures,		
								   npoints,			
								   nclusters,		
								   membership2,	
								   cluster_matrix,		
								   new_centers_len2,	
								   new_centers2,		
								   feature_matrix,
								   clusterix
								   ); 
								   
		auto t3 = std::chrono::high_resolution_clock::now(); //+++timestamp+++	
		tskelcl = tskelcl + (t3-t2);
		LOG_DEBUG("Round: ", c , " original: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count(), "ms   skelcl: ", std::chrono::duration_cast<std::chrono::milliseconds>(t3 - t2).count(), "ms"); //+++logging runtime+++
		
		
		bool e;
		
		e = true;
		for(int i = 0; i < npoints; i++)
		{
			int o = membership[i];
			int s = membership2[i];
			if(o != s)
			{
				e = false;
			}
		}
		
		if(e){
			LOG_DEBUG("Round: ", c , " Equal membership"); 
		}else{
			LOG_DEBUG("Round: ", c , " Unequal membership!!!");
		} 
		
		e = true;
		for(int i = 0; i < nclusters; i++)
		{
			for(int j = 0; j < nfeatures; j++)
			{
				float o = new_centers[i][j];
				float s = new_centers2[i][j];
				if(o != s)
				{
					e = false;
//					new_centers2[i][j] = o;
				}
			}
		}
		
		if(e){
			LOG_DEBUG("Round: ", c , " Equal centers"); 
		}else{
			LOG_DEBUG("Round: ", c , " Unequal centers!!!");
		} 
	
		e = true;
		for(int i = 0; i < nclusters; i++)
		{
			int o = new_centers_len[i];
			int s = new_centers_len2[i];
			if(o != s)
			{
				e = false;
//				new_centers_len2[i] = o;
			}
		}
		
		if(e){
			LOG_DEBUG("Round: ", c , " Equal centers length"); 
		}else{
			LOG_DEBUG("Round: ", c , " Unequal centers length!!!");
		} 
		
		if(delta == delta2){
			LOG_DEBUG("Round: ", c , " delta: ", delta, " delta2: ", delta2); 
		}else{
			LOG_DEBUG("Round: ", c , " delta: ", delta, " delta2: ", delta2, " !!!");
		}

		/* replace old cluster centers with new_centers */
		/* CPU side of reduction */
		for (i=0; i<nclusters; i++) {
			for (j=0; j<nfeatures; j++) {
				if (new_centers_len[i] > 0) 
					clusters[i][j] = new_centers[i][j] / new_centers_len[i];	/* take average i.e. sum/n */
				if (new_centers_len2[i] > 0)
					(*cluster_matrix)[i][j] = new_centers2[i][j] / new_centers_len2[i];	/* take average i.e. sum/n */
				if(clusters[i][j] != (*cluster_matrix)[i][j])
				{
					e = false;
//					(*cluster_matrix)[i][j] = clusters[i][j];
				}
				new_centers[i][j] = 0.0;	/* set back to 0 */
				new_centers2[i][j] = 0.0;	/* set back to 0 */
			}
			new_centers_len[i] = 0;			/* set back to 0 */
			new_centers_len2[i] = 0;			/* set back to 0 */
		}	 
		cluster_matrix->dataOnHostModified();
		
		if(e){
			LOG_DEBUG("Round: ", c , " Equal new centers \n"); 
		}else{
			LOG_DEBUG("Round: ", c , " Unequal new centers!!! \n");
		} 
		
		c++;
    } while ((delta > threshold) && (loop++ < 500));	/* makes sure loop terminates */
    
    LOG_INFO("OpenCL perform kernels: ", std::chrono::duration_cast<std::chrono::milliseconds>(topencl).count(), "ms");  //logging the runtime
    LOG_INFO("SkelCL perform skeletons: ", std::chrono::duration_cast<std::chrono::milliseconds>(tskelcl).count(), "ms");  //logging the runtime
    
	printf("iterated %d times\n", c);
    free(new_centers[0]);
    free(new_centers);
    free(new_centers_len);
    free(new_centers2[0]);
    free(new_centers2);
    free(new_centers_len2);
    free(membership2);

    return clusters;
}

