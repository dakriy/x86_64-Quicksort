#!/bin/bash

mkdir -p build
cd build || exit
cmake ..
make
# shellcheck disable=SC2046
perf stat -r 100 -d ./x86_64-quicksort $(python -c "import random;[print(random.randint(1,100000), end=' ') for _ in range(100000)]")
read -p "Press [Enter] to benchmark cpp program..."
# shellcheck disable=SC2046
perf stat -r 100 -d ./cpp-quicksort $(python -c "import random;[print(random.randint(1,100000), end=' ') for _ in range(100000)]")
