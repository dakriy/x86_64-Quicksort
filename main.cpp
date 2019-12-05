#include <iostream>
#include <vector>

void swap(long& a, long& b) {
    long t = a;
    a = b;
    b = t;
}

int partition (std::vector<long>& arr, int low, int high) {
    long pivot = arr[low + (high - low) / 2];
    int i = low - 1;
    int j = high + 1;
    for (;;) {
        do {
            i += 1;
        } while (arr[i] < pivot);
        do {
            j -= 1;
        } while (arr[j] > pivot);
        if (i >= j) {
            return j;
        }
        swap(arr[i], arr[j]);
    }
}

void quickSort(std::vector<long>& arr, int low, int high) {
	if (low < high) {
		int p = partition(arr, low, high);

		quickSort(arr, low, p);
		quickSort(arr, p + 1, high);
	}
}

int main(int argc, char ** argv) {
    std::vector<long> args;
    // Apparently resizing and using if slightly faster than reserving and then push backing
    args.resize(argc - 1);
    for (long i = 1; i < argc; ++i) {
        args[i - 1] = atol(argv[i]);
    }
    quickSort(args, 0, argc - 1);

    // Comment out the printing of lines for benchmarking
    for (auto elem : args) {
        std::cout << elem << std::endl;
    }

	return 0;
}

