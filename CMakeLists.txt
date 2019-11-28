cmake_minimum_required(VERSION 3.15)
project(x86_quicksort ASM)

SET(CMAKE_ASM_FLAGS "${CMAKE_ASM_FLAGS} -fno-pie -no-pie")
add_executable(${PROJECT_NAME} main.s)
#set_target_properties(
#        ${PROJECT_NAME}
#        PROPERTIES
#        LINK_FLAGS "-lc -dynamic-linker /lib/ld-linux.so.2"
#)
