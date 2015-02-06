/* ============================================================

Copyright (c) 2009-2010 Advanced Micro Devices, Inc.  All rights reserved.
 
Redistribution and use of this material is permitted under the following 
conditions:
 
Redistributions must retain the above copyright notice and all terms of this 
license.
 
In no event shall anyone redistributing or accessing or using this material 
commence or participate in any arbitration or legal action relating to this 
material against Advanced Micro Devices, Inc. or any copyright holders or 
contributors. The foregoing shall survive any expiration or termination of 
this license or any agreement or access or use related to this material. 

ANY BREACH OF ANY TERM OF THIS LICENSE SHALL RESULT IN THE IMMEDIATE REVOCATION 
OF ALL RIGHTS TO REDISTRIBUTE, ACCESS OR USE THIS MATERIAL.

THIS MATERIAL IS PROVIDED BY ADVANCED MICRO DEVICES, INC. AND ANY COPYRIGHT 
HOLDERS AND CONTRIBUTORS "AS IS" IN ITS CURRENT CONDITION AND WITHOUT ANY 
REPRESENTATIONS, GUARANTEE, OR WARRANTY OF ANY KIND OR IN ANY WAY RELATED TO 
SUPPORT, INDEMNITY, ERROR FREE OR UNINTERRUPTED OPERA TION, OR THAT IT IS FREE 
FROM DEFECTS OR VIRUSES.  ALL OBLIGATIONS ARE HEREBY DISCLAIMED - WHETHER 
EXPRESS, IMPLIED, OR STATUTORY - INCLUDING, BUT NOT LIMITED TO, ANY IMPLIED 
WARRANTIES OF TITLE, MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, 
ACCURACY, COMPLETENESS, OPERABILITY, QUALITY OF SERVICE, OR NON-INFRINGEMENT. 
IN NO EVENT SHALL ADVANCED MICRO DEVICES, INC. OR ANY COPYRIGHT HOLDERS OR 
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, PUNITIVE,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, REVENUE, DATA, OR PROFITS; OR 
BUSINESS INTERRUPTION) HOWEVER CAUSED OR BASED ON ANY THEORY OF LIABILITY 
ARISING IN ANY WAY RELATED TO THIS MATERIAL, EVEN IF ADVISED OF THE POSSIBILITY 
OF SUCH DAMAGE. THE ENTIRE AND AGGREGATE LIABILITY OF ADVANCED MICRO DEVICES, 
INC. AND ANY COPYRIGHT HOLDERS AND CONTRIBUTORS SHALL NOT EXCEED TEN DOLLARS 
(US $10.00). ANYONE REDISTRIBUTING OR ACCESSING OR USING THIS MATERIAL ACCEPTS 
THIS ALLOCATION OF RISK AND AGREES TO RELEASE ADVANCED MICRO DEVICES, INC. AND 
ANY COPYRIGHT HOLDERS AND CONTRIBUTORS FROM ANY AND ALL LIABILITIES, 
OBLIGATIONS, CLAIMS, OR DEMANDS IN EXCESS OF TEN DOLLARS (US $10.00). THE 
FOREGOING ARE ESSENTIAL TERMS OF THIS LICENSE AND, IF ANY OF THESE TERMS ARE 
CONSTRUED AS UNENFORCEABLE, FAIL IN ESSENTIAL PURPOSE, OR BECOME VOID OR 
DETRIMENTAL TO ADVANCED MICRO DEVICES, INC. OR ANY COPYRIGHT HOLDERS OR 
CONTRIBUTORS FOR ANY REASON, THEN ALL RIGHTS TO REDISTRIBUTE, ACCESS OR USE 
THIS MATERIAL SHALL TERMINATE IMMEDIATELY. MOREOVER, THE FOREGOING SHALL 
SURVIVE ANY EXPIRATION OR TERMINATION OF THIS LICENSE OR ANY AGREEMENT OR 
ACCESS OR USE RELATED TO THIS MATERIAL.

NOTICE IS HEREBY PROVIDED, AND BY REDISTRIBUTING OR ACCESSING OR USING THIS 
MATERIAL SUCH NOTICE IS ACKNOWLEDGED, THAT THIS MATERIAL MAY BE SUBJECT TO 
RESTRICTIONS UNDER THE LAWS AND REGULATIONS OF THE UNITED STATES OR OTHER 
COUNTRIES, WHICH INCLUDE BUT ARE NOT LIMITED TO, U.S. EXPORT CONTROL LAWS SUCH 
AS THE EXPORT ADMINISTRATION REGULATIONS AND NATIONAL SECURITY CONTROLS AS 
DEFINED THEREUNDER, AS WELL AS STATE DEPARTMENT CONTROLS UNDER THE U.S. 
MUNITIONS LIST. THIS MATERIAL MAY NOT BE USED, RELEASED, TRANSFERRED, IMPORTED,
EXPORTED AND/OR RE-EXPORTED IN ANY MANNER PROHIBITED UNDER ANY APPLICABLE LAWS, 
INCLUDING U.S. EXPORT CONTROL LAWS REGARDING SPECIFICALLY DESIGNATED PERSONS, 
COUNTRIES AND NATIONALS OF COUNTRIES SUBJECT TO NATIONAL SECURITY CONTROLS. 
MOREOVER, THE FOREGOING SHALL SURVIVE ANY EXPIRATION OR TERMINATION OF ANY 
LICENSE OR AGREEMENT OR ACCESS OR USE RELATED TO THIS MATERIAL.

NOTICE REGARDING THE U.S. GOVERNMENT AND DOD AGENCIES: This material is 
provided with "RESTRICTED RIGHTS" and/or "LIMITED RIGHTS" as applicable to 
computer software and technical data, respectively. Use, duplication, 
distribution or disclosure by the U.S. Government and/or DOD agencies is 
subject to the full extent of restrictions in all applicable regulations, 
including those found at FAR52.227 and DFARS252.227 et seq. and any successor 
regulations thereof. Use of this material by the U.S. Government and/or DOD 
agencies is acknowledgment of the proprietary rights of any copyright holders 
and contributors, including those of Advanced Micro Devices, Inc., as well as 
the provisions of FAR52.227-14 through 23 regarding privately developed and/or 
commercial computer software.

This license forms the entire agreement regarding the subject matter hereof and 
supersedes all proposals and prior discussions and writings between the parties 
with respect thereto. This license does not affect any ownership, rights, title,
or interest in, or relating to, this material. No terms of this license can be 
modified or waived, and no breach of this license can be excused, unless done 
so in a writing signed by all affected parties. Each term of this license is 
separately enforceable. If any term of this license is determined to be or 
becomes unenforceable or illegal, such term shall be reformed to the minimum 
extent necessary in order for this license to remain in effect in accordance 
with its terms as modified by such reformation. This license shall be governed 
by and construed in accordance with the laws of the State of Texas without 
regard to rules on conflicts of law of any state or jurisdiction or the United 
Nations Convention on the International Sale of Goods. All disputes arising out 
of this license shall be subject to the jurisdiction of the federal and state 
courts in Austin, Texas, and all defenses are hereby waived concerning personal 
jurisdiction and venue of these courts.

============================================================ */
#pragma OPENCL EXTENSION cl_khr_fp64 : enable

#define VECTOR_SIZE 4


/* Kernel to decompose the matrix in LU parts
    input taken from inlacematrix
    param d tells which iteration of the kernel is executing
    output matrix U is generated in the inplacematrix itself
    output matrix L is generated in the LMatrix*/

__kernel void kernelLUDecompose(__global double4* LMatrix,
                           __global double4* inplaceMatrix,
                            int d,
                            __local double* ratio)
{	
    //get the global id of the work item
    int y = get_global_id(1);
    int x = get_global_id(0);
    int lidx = get_local_id(0);
    int lidy = get_local_id(1);
    //the range in x axis is dimension / 4
    int xdimension = get_global_size(0) + d / VECTOR_SIZE;
    int D = d % VECTOR_SIZE;
    //printf(" Thread ID %d %d local ID %d  %d\n",x,y,lidx,lidy);
    if(get_local_id(0) == 0)
    {
        
        //ratio needs to be calculated only once per workitem
        (D == 0) ? (ratio[lidy] = inplaceMatrix[ y * xdimension + d / VECTOR_SIZE].s0 / inplaceMatrix[ d * xdimension + d / VECTOR_SIZE].s0):1;
        (D == 1) ? (ratio[lidy] = inplaceMatrix[ y * xdimension + d / VECTOR_SIZE].s1 / inplaceMatrix[ d * xdimension + d / VECTOR_SIZE].s1):1;
        (D == 2) ? (ratio[lidy] = inplaceMatrix[ y * xdimension + d / VECTOR_SIZE].s2 / inplaceMatrix[ d * xdimension + d / VECTOR_SIZE].s2):1;
        (D == 3) ? (ratio[lidy] = inplaceMatrix[ y * xdimension + d / VECTOR_SIZE].s3 / inplaceMatrix[ d * xdimension + d / VECTOR_SIZE].s3):1;
    }
    
    barrier(CLK_LOCAL_MEM_FENCE);
    
    //check which workitems need to be included for computation
    if(y >= d + 1 && ((x + 1) * VECTOR_SIZE) > d)
    {
        double4 result;
        
        //the vectorized part begins here
        {
            result.s0 = inplaceMatrix[y * xdimension + x].s0 - ratio[lidy] * inplaceMatrix[ d * xdimension + x].s0;
            result.s1 = inplaceMatrix[y * xdimension + x].s1 - ratio[lidy] * inplaceMatrix[ d * xdimension + x].s1;
            result.s2 = inplaceMatrix[y * xdimension + x].s2 - ratio[lidy] * inplaceMatrix[ d * xdimension + x].s2;
            result.s3 = inplaceMatrix[y * xdimension + x].s3 - ratio[lidy] * inplaceMatrix[ d * xdimension + x].s3;
        }
        
        
        if(x == d / VECTOR_SIZE)
        {
            (D == 0) ? (LMatrix[y * xdimension + x].s0 = ratio[lidy]) : (inplaceMatrix[y * xdimension + x].s0 = result.s0);
            (D == 1) ? (LMatrix[y * xdimension + x].s1 = ratio[lidy]) : (inplaceMatrix[y * xdimension + x].s1 = result.s1);
            (D == 2) ? (LMatrix[y * xdimension + x].s2 = ratio[lidy]) : (inplaceMatrix[y * xdimension + x].s2 = result.s2);
            (D == 3) ? (LMatrix[y * xdimension + x].s3 = ratio[lidy]) : (inplaceMatrix[y * xdimension + x].s3 = result.s3);
        }
        else
        {
            inplaceMatrix[y * xdimension + x].s0 = result.s0;
            inplaceMatrix[y * xdimension + x].s1 = result.s1;
            inplaceMatrix[y * xdimension + x].s2 = result.s2;
            inplaceMatrix[y * xdimension + x].s3 = result.s3;
        }
    }
}


/*	This function will combine L & U into 1 matrix
    param: inplace matrix contains the U matrix generated by above kernel
    param: LMatrix contains L MAtrix
    The kernel will combine them together as one matrix
    We ignore the diagonal elements of LMatrix during this as 
    they will all be zero
    */


__kernel void kernelLUCombine(__global double* LMatrix,
                         __global double* inplaceMatrix)
{
    int i = get_global_id(1);
    int j = get_global_id(0);
    int gidx = get_group_id(0);
    int gidy = get_group_id(1);
    int dimension = get_global_size(0);
    if(i>j )
    {
        int dimension = get_global_size(0);
        inplaceMatrix[i * dimension + j] = LMatrix[i * dimension + j];
    }
}

