#include "time.h"

constexpr int segment_size = 1024;
constexpr int threads = 512;

void __global__ alloc(int **pointers) {
  auto index = blockIdx.x * blockDim.x + threadIdx.x;
  pointers[index] = (int *)malloc(segment_size);
}

void __global__ fill(int **pointers) {
  auto index = blockIdx.x * blockDim.x + threadIdx.x;
  for (int i = 0; i < segment_size / sizeof(int); i++) {
    pointers[index][i] = i;
  }
}

void __global__ free(int **pointers) {
  auto index = blockIdx.x * blockDim.x + threadIdx.x;
  free(pointers[index]);
}

int main() {
  int **pointers;
  cudaMalloc(&pointers, threads * sizeof(int *));

  int bd = 32;
  for (int i = 0; i < 10; i++) {
    alloc<<<threads / bd, bd>>>(pointers);
    fill<<<threads / bd, bd>>>(pointers);
    free<<<threads / bd, bd>>>(pointers);
  }
  cudaDeviceSynchronize();
}