set (SKELCL_EXAMPLES_LUD_SOURCES
      main.cpp
    )

if(Boost_FOUND)
	include_directories (${Boost_INCLUDE_DIR})
	add_executable (lud ${SKELCL_EXAMPLES_LUD_SOURCES})
	target_link_libraries (lud SkelCL ${SKELCL_COMMON_LIBS} ${Boost_LIBRARIES})
endif()
