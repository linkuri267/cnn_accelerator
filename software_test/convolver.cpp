#include "convolver.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <algorithm>

void convolveImage( const struct image& image, const struct kernel& kernel)
{
  struct node activatedNode;
  activatedNode.mNode = new std::vector< std::vector<int> >;

  // prints original values
  activatedNode.mNode->assign(image.mImage->begin(), image.mImage->end());
  printShit(activatedNode);
  activatedNode.mNode->clear();
  
  std::cout << "-----------------\n";
  
  //originalConvolution(image, kernel, activatedNode);
  //relu(image, kernel, activatedNode);
  maxPool(image, kernel, activatedNode);

  
  printShit(activatedNode);
  
}

void initImage(const struct image& image)
{
  // You can change the 99 to the size you want later
  image.mImage->resize(12);
  
  // 0-98
  
  int imageRowSize = static_cast<int>(image.mImage->size());
  for(int i = 0; i < imageRowSize; ++i)
  {
    
    for(int j = 0; j < imageRowSize; ++j)
    {
      image.mImage->at(i).push_back(j-5);
    }
  }
}

void initKernel(const struct kernel& kernel)
{
  int incrementor = 0;
  
  kernel.mKernel->resize(3);
  
  int kernelRowSize = static_cast<int>(kernel.mKernel->size());
  for(int i = 0; i < kernelRowSize; ++i)
  {
    kernel.mKernel->at(i).resize(3);
  }
  
  for(int i = 0; i < kernelRowSize; ++i)
  {
    for(int j = 0; j < kernelRowSize; ++j)
    {
      kernel.mKernel->at(i)[j] = incrementor;
      ++incrementor;
    }
  }
  
  // delete this shit later
  /*for(int i = 0; i < 3; ++i)
   {
   for(int j = 0; j < 3; ++j)
   {
     std::cout << kernel.mKernel->at(i)[j] << ",";
   }
   
   std::cout << std::endl;
   }*/
}

void originalConvolution( const struct image& image, const struct kernel& kernel, struct node& activatedNode )
{
  // Assuming NxN
  int x_length = static_cast<int>(image.mImage->size());
  int y_length = static_cast<int>(image.mImage->size());
  
  int kernel_length = static_cast<int>(kernel.mKernel->size());
  int convolvedValue = 0;
  int values[9];
  
  for(int i = 0; i < (x_length - kernel_length + 1); ++i)
  {
    std::vector<int> *temp = new std::vector<int>;
    for(int j = 0; j < (y_length - kernel_length + 1); ++j)
    {
      convolvedValue = 0;
      // Convolve the image to the kernel
      values[0] = image.mImage->at(i)[j]      * kernel.mKernel->at(0)[0];
      values[1] = image.mImage->at(i+1)[j]    * kernel.mKernel->at(1)[0];
      values[2] = image.mImage->at(i+2)[j]    * kernel.mKernel->at(2)[0];
      values[3] = image.mImage->at(i)[j+1]    * kernel.mKernel->at(0)[1];
      values[4] = image.mImage->at(i+1)[j+1]  * kernel.mKernel->at(1)[1];
      values[5] = image.mImage->at(i+2)[j+1]  * kernel.mKernel->at(2)[1];
      values[6] = image.mImage->at(i)[j+2]    * kernel.mKernel->at(0)[2];
      values[7] = image.mImage->at(i+1)[j+2]  * kernel.mKernel->at(1)[2];
      values[8] = image.mImage->at(i+2)[j+2]  * kernel.mKernel->at(2)[2];
      
      // Sum up all the values
      for(int k = 0; k < 9; ++k)
      {
        convolvedValue += values[k];
      }
      temp->push_back(convolvedValue);
    }
    // Add a new row
    activatedNode.mNode->push_back( *temp );
  }
}

void relu( const struct image& image, const struct kernel &kernel, struct node& activatedNode)
{
  // Assuming NxN
  int x_length = static_cast<int>(image.mImage->size());
  int y_length = static_cast<int>(image.mImage->size());
  
  activatedNode.mNode->assign(image.mImage->begin(), image.mImage->end());
  
  for(int i = 0; i < (x_length); ++i)
  {
    for(int j = 0; j < (y_length); ++j)
    {
      if( image.mImage->at(i)[j] < 0)
      {
        activatedNode.mNode->at(i)[j] = 0;
      }
      // else don't do anything
    }
  }
}

void maxPool( const struct image& image, const struct kernel& kernel, struct node& activatedNode )
{
  // Assuming NxN
  int x_length = static_cast<int>(image.mImage->size());
  int y_length = static_cast<int>(image.mImage->size());
  
  int kernel_length = static_cast<int>(kernel.mKernel->size());
  //int convolvedValue = 0;
  int values[9];
  
  int currMaxValue = 0;
  
  for(int i = 0; i < (x_length - kernel_length + 1); ++i)
  {
    std::vector<int> *temp = new std::vector<int>;
    for(int j = 0; j < (y_length - kernel_length + 1); ++j)
    {
      //convolvedValue = 0;
      // Convolve the image to the kernel
      values[0] = image.mImage->at(i)[j];
      values[1] = image.mImage->at(i+1)[j];
      values[2] = image.mImage->at(i+2)[j];
      values[3] = image.mImage->at(i)[j+1];
      values[4] = image.mImage->at(i+1)[j+1];
      values[5] = image.mImage->at(i+2)[j+1];
      values[6] = image.mImage->at(i)[j+2];
      values[7] = image.mImage->at(i+1)[j+2];
      values[8] = image.mImage->at(i+2)[j+2];
      
      // find max value
      // Sum up all the values
      currMaxValue = values[0];
      for(int k = 0; k < 9; ++k)
      {
        if(currMaxValue < values[k])
        {
          currMaxValue = values[k];
        }
      }
      temp->push_back(currMaxValue);
    }
    
    // Add a new row
    activatedNode.mNode->push_back( *temp );
  }
}

void printShit(const struct node &node)
{
  // Assuming NxN
  int x_length = static_cast<int>(node.mNode->size());
  int y_length = static_cast<int>(node.mNode->size());
  
  std::cout << "XL:" << x_length << std::endl;
  std::cout << "YL:" << y_length << std::endl;
  
  for(int i = 0; i < x_length; ++i)
  {
    for(int j = 0; j < y_length; ++j)
    {
      std::cout << node.mNode->at(i)[j] << ",";
    }
    
    std::cout << std::endl;
  }
}

void outputShit(const struct node& node){
  std::fstream softwareOuput;
  softwareOuput.open("software_output.txt", std::ios::out);


    // Assuming NxN
    int x_length = static_cast<int>(node.mNode->size());
    int y_length = static_cast<int>(node.mNode->size());
    
    softwareOuput << "{";
    for(int i = 0; i < x_length; ++i)
    {
      softwareOuput << "{";
      for(int j = 0; j < y_length; ++j)
      {
        softwareOuput << node.mNode->at(i)[j] << ",";
      }
      softwareOuput << "}" << std::endl;
    }
    softwareOuput << "}";
    softwareOuput.close();
}