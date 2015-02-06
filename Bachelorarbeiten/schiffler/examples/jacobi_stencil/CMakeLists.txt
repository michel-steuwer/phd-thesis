#set (SKELCL_EXAMPLES_JACOBI_STENCIL_SOURCES
#      common.cpp
#    )

#Build vector version
add_executable (jacobi_stencil_vector main_vec.cpp)
target_link_libraries (jacobi_stencil_vector SkelCL ${SKELCL_COMMON_LIBS})

#Build matrix version
add_executable (jacobi_stencil_matrix main_mat.cpp)
target_link_libraries (jacobi_stencil_matrix SkelCL ${SKELCL_COMMON_LIBS})

add_executable (jacobi_stencil_indexmatrix main_mat_IndexMatrix.cpp)
target_link_libraries (jacobi_stencil_indexmatrix SkelCL ${SKELCL_COMMON_LIBS})

# copy file along with binary
configure_file (kernel_vec.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel_vec.cl)
configure_file (kernel_mat.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel_mat.cl)
configure_file (kernel_mat_IndexMatrix.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel_mat_IndexMatrix.cl)

file (COPY data DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

