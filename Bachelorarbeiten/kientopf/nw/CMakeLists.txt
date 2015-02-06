set (SKELCL_EXAMPLES_NW_SOURCES
      nw_skelcl.cpp
    )

add_executable (nw ${SKELCL_EXAMPLES_NW_SOURCES})
target_link_libraries (nw SkelCL ${SKELCL_COMMON_LIBS})

# copy file along with binary
configure_file (nw.cl ${CMAKE_CURRENT_BINARY_DIR}/nw.cl)
configure_file (upper_left.cl ${CMAKE_CURRENT_BINARY_DIR}/upper_left.cl)
configure_file (lower_right.cl ${CMAKE_CURRENT_BINARY_DIR}/lower_right.cl)
