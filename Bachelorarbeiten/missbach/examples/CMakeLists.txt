# set include dir for all examples
include_directories ("${PROJECT_SOURCE_DIR}/include")

# find boost only once for all examples
set(CMAKE_INCLUDE_PATH "${PROJECT_SOURCE_DIR}/libraries/boost/" ${CMAKE_INCLUDE_PATH})
set(CMAKE_LIBRARY_PATH "${PROJECT_SOURCE_DIR}/libraries/boost/stage/libs" ${CMAKE_LIBRARY_PATH})
find_package(Boost REQUIRED COMPONENTS program_options)

include_directories (${SKELCL_COMMON_INCLUDE_DIR})
link_directories (${SKELCL_COMMON_LIB_DIR})

add_subdirectory (ludecomposition)
add_subdirectory (mersenne_twister)
