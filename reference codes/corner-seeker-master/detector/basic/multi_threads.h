#pragma once
#include <thread>
#include <vector>

namespace multi_threads {
    int num_cores = std::thread::hardware_concurrency();
    int i;
    std::vector<std::thread> threads;

    void start() {
        return;
    }
    void end() {
        for (int i = 0; i < num_cores; ++i) threads[i].join();
        threads.clear();
        threads.shrink_to_fit();
    }
}

#ifdef MULTI_THREADS_FOR_MATRIX3D

#define INVOKE_MULTI_THREADS(height, s, t, exec_code) { \
multi_threads::start(); \
for (int iiii = 0; iiii < multi_threads::num_cores; ++iiii) { \
    int s = height / multi_threads::num_cores * iiii; \
    int t = height / multi_threads::num_cores * (iiii + 1); \
    if (iiii == multi_threads::num_cores - 1) \
        t = height; \
    multi_threads::threads.push_back(std::thread([&, s, t] exec_code)); \
} \
multi_threads::end(); \
}

#else

#define INVOKE_MULTI_THREADS(height, s, t, exec_code) { \
int s = 0; int t = height; exec_code \
}

#endif
