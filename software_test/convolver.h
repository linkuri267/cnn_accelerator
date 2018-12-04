#ifndef convolver_h
#define convolver_h

#include <stdio.h>
#include <vector>
#include <string>

// Used strictly for polymorphic purposes
struct NeuralNetObj
{
  std::vector< std::vector<int> > *mGrid;
};

struct image : NeuralNetObj
{
  //std::vector< std::vector<int> > *mImage;
};

struct kernel : NeuralNetObj
{
  //std::vector< std::vector<int> > *mKernel;
};

struct node : NeuralNetObj
{
  //std::vector< std::vector<int> > *mNode;
};


// Needs to convolve 99x99 image and 3x3 kernel
void convolveImage( const struct image& image, const struct kernel& kernel);

struct NeuralNetObj originalConvolution( const struct image& image, const struct kernel& kernel );

struct NeuralNetObj relu( const struct NeuralNetObj& nno );

struct NeuralNetObj maxPool( const struct NeuralNetObj& nno );

void outputShit(const struct NeuralNetObj &nno, const std::string &filename, bool csv_flag = true);

void printShit(const struct node &node);

void initImage(const struct image& image, int size);

void initKernel(const struct kernel& kernel);

#endif
