#!/bin/bash

mkdir -p build
cd build || exit
cmake ..
make
# shellcheck disable=SC2046
time ./x86_quicksort $(python -c "import random;[print(random.randint(1,10000), end=' ') for _ in range(100000)]")
