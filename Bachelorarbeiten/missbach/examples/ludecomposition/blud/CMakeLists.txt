set (SKELCL_EXAMPLES_BLUD_SOURCES
      main.cpp
    )

if(Boost_FOUND)
	include_directories (${Boost_INCLUDE_DIR})
	add_executable (blud ${SKELCL_EXAMPLES_BLUD_SOURCES})
	target_link_libraries (blud SkelCL ${SKELCL_COMMON_LIBS} ${Boost_LIBRARIES})
endif()

# copy file along with binary
configure_file (diagonal.cl ${CMAKE_CURRENT_BINARY_DIR}/diagonal.cl)
configure_file (perimeter.cl ${CMAKE_CURRENT_BINARY_DIR}/perimeter.cl)
configure_file (interior.cl ${CMAKE_CURRENT_BINARY_DIR}/interior.cl)
