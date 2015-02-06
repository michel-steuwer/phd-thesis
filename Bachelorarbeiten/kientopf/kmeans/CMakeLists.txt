set (SKELCL_EXAMPLES_KMEANS_SOURCES
      getopt.h kmeans.h unistd.h  getopt.cpp read_input.cpp kmeans_clustering.cpp kmeans_skelcl.cpp rmse.cpp kmeans.cpp cluster.cpp
    )

add_executable (kmeans ${SKELCL_EXAMPLES_KMEANS_SOURCES})
target_link_libraries (kmeans SkelCL ${SKELCL_COMMON_LIBS})

configure_file (kmeans.cl ${CMAKE_CURRENT_BINARY_DIR}/kmeans.cl)
configure_file (kmeans.skelcl ${CMAKE_CURRENT_BINARY_DIR}/kmeans.skelcl)
configure_file (data/kdd_cup ${CMAKE_CURRENT_BINARY_DIR}/kdd_cup)
configure_file (data/100 ${CMAKE_CURRENT_BINARY_DIR}/test_100)
configure_file (data/204800.txt ${CMAKE_CURRENT_BINARY_DIR}/test_204800)
configure_file (data/819200.txt ${CMAKE_CURRENT_BINARY_DIR}/test_819200)
