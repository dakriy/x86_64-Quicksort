cmake_minimum_required(VERSION 3.15)
project(x86_64-quicksort ASM)

SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -fno-pie -no-pie")
add_executable(${PROJECT_NAME} main.s)
