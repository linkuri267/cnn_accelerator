#ifndef convolver_h
#define convolver_h

#include <stdio.h>
#include <vector>

struct image
{
  std::vector< std::vector<int> > *mImage;
};

struct kernel
{
  std::vector< std::vector<int> > *mKernel;
};

struct node
{
  std::vector< std::vector<int> > *mNode;
};


// Needs to convolve 99x99 image and 3x3 kernel
void convolveImage( const struct image& image, const struct kernel& kernel);

void printShit(const struct node &node);

void outputShit(const struct node &node);

void initImage(const struct image& image);

void initKernel(const struct kernel& kernel);

#endif
