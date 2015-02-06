set (SKELCL_EXAMPLES_BTREE_SOURCES
      kernel/kernel_gpu_opencl_wrapper.cpp
      kernel/kernel_gpu_opencl_wrapper_2.cpp
      kernel/kernel_gpu_skelcl_wrapper.cpp
      util/opencl/opencl.cpp
      util/timer/timer.cpp
    )

include_directories ("./kernel"
                     "./util/timer"
                     "./util/opencl"
                     "./util/num"
                    )

# build skelcl version
add_executable (b+tree_skelcl main_skelcl.cpp ${SKELCL_EXAMPLES_BTREE_SOURCES})
target_link_libraries (b+tree_skelcl SkelCL ${SKELCL_COMMON_LIBS})

# build opencl version
add_executable (b+tree_opencl main_opencl.cpp ${SKELCL_EXAMPLES_BTREE_SOURCES})
target_link_libraries (b+tree_opencl SkelCL ${SKELCL_COMMON_LIBS})

# copy file along with binary
configure_file (kernel/kernel_gpu_opencl_2.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel_gpu_opencl_2.cl)
configure_file (kernel/kernel_gpu_opencl.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel_gpu_opencl.cl)
configure_file (kernel/kernel_gpu_skelcl.cl ${CMAKE_CURRENT_BINARY_DIR}/kernel/kernel_gpu_skelcl.cl)
configure_file (run ${CMAKE_CURRENT_BINARY_DIR}/run)

#file (COPY data DESTINATION ${CMAKE_CURRENT_BINARY_DIR})

