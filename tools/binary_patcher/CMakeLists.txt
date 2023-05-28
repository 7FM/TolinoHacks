set(CMAKE_BUILD_TYPE Release)

cmake_minimum_required(VERSION 3.25)
project(binary_patcher CXX)

file(GLOB_RECURSE cppSrcs CONFIGURE_DEPENDS
"src/*.cpp"
)

add_executable(${PROJECT_NAME} ${cppSrcs})

# Target specific compile flags
if(MSVC)
  target_compile_options(${PROJECT_NAME} PRIVATE /W4)
else()
  target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -pedantic)
endif()
