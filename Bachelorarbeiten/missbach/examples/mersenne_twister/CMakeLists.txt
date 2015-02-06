set (SKELCL_EXAMPLES_MERSENNETWISTER_SOURCES
      main.cpp
    )

if(Boost_FOUND)
	include_directories (${Boost_INCLUDE_DIR})
	add_executable (mersenne_twister ${SKELCL_EXAMPLES_MERSENNETWISTER_SOURCES})
	target_link_libraries (mersenne_twister SkelCL ${SKELCL_COMMON_LIBS} ${Boost_LIBRARIES})
endif()

# copy file along with binary
configure_file (new_mersenne_twister.cl ${CMAKE_CURRENT_BINARY_DIR}/new_mersenne_twister.cl)
configure_file (amd_mersenne_twister.cl ${CMAKE_CURRENT_BINARY_DIR}/amd_mersenne_twister.cl)

