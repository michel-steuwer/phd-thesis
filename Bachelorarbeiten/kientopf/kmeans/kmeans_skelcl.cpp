#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <fstream>
#include <string>
#include "kmeans.h"
#include <chrono>

#include <pvsutil/Logger.h> //skelcl

#include <SkelCL/SkelCL.h>	//skelcl
#include <SkelCL/Vector.h>	//skelcl
#include <SkelCL/Matrix.h>  //skelcl
#include <SkelCL/IndexVector.h> //skelcl
#include <SkelCL/Map.h>	//skelcl


#ifndef FLT_MAX
#define FLT_MAX 3.40282347e+38
#endif

int	kmeansOCL2(float **feature, 
              int     n_features,
              int     n_points,
              int     n_clusters,
              int* 		membership,
		          skelcl::Matrix<float> *cluster_matrix,
		          int*		new_centers_len,
              float**	new_centers,
              skelcl::Matrix<float> *feature_matrix,
              skelcl::Map<int(skelcl::Index)> clusterix//,
//              skelcl::Vector<int> **membership_vector_OCL
             )
{	
	auto t1 = std::chrono::high_resolution_clock::now();
	skelcl::IndexVector index((*feature_matrix).size().rowCount());
	
//	skelcl::Map<int(skelcl::Index)> clusterix(std::ifstream("kmeans.skelcl"));
	
	skelcl::Vector<int> membership_vector_OCL = clusterix(index, (*feature_matrix), n_clusters, n_features, (*cluster_matrix));
	auto t2 = std::chrono::high_resolution_clock::now();
	LOG_DEBUG("skelcl: ", std::chrono::duration_cast<std::chrono::milliseconds>(t2 - t1).count());
	
	int delta = 0;
	for (int i = 0; i < membership_vector_OCL.size(); i++)
	{
		int cluster_id = membership_vector_OCL[i];
		new_centers_len[cluster_id]++;
		if (cluster_id != membership[i])
		{
			delta++;
			membership[i] = membership_vector_OCL[i];
		}
		for (int j = 0; j < n_features; j++)
		{
			new_centers[cluster_id][j] += feature[i][j];
		} 
	} 
	
	auto t3 = std::chrono::high_resolution_clock::now();
	LOG_DEBUG("skelcl-calculate: ", std::chrono::duration_cast<std::chrono::milliseconds>(t3 - t2).count());

	return delta; 
}
