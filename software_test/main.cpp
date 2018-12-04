#include <iostream>
#include <vector>
#include "convolver.h"

int main(int argc, const char * argv[]) {

  struct image testImage;
  struct kernel testKernel;
  
  testImage.mGrid = new std::vector< std::vector<int> >;
  testKernel.mGrid = new std::vector< std::vector<int> >;
  
  initImage(testImage, 99);
  initKernel(testKernel);
  
  convolveImage(testImage, testKernel);
  
  //std::cout << "Hello, World!\n";
  return 0;
}
