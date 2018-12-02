#include <iostream>
#include <vector>
#include "convolver.h"

int main(int argc, const char * argv[]) {

  struct image testImage;
  struct kernel testKernel;
  
  testImage.mImage = new std::vector< std::vector<int> >;
  testKernel.mKernel = new std::vector< std::vector<int> >;
  
  initImage(testImage);
  initKernel(testKernel);
  
  convolveImage(testImage, testKernel);
  
  return 0;
}
