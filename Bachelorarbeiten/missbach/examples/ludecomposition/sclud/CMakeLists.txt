set (SKELCL_EXAMPLES_LUDSCL_SOURCES
      main.cpp
    )

add_executable (sclud ${SKELCL_EXAMPLES_LUDSCL_SOURCES})
target_link_libraries (sclud SkelCL ${SKELCL_COMMON_LIBS})
