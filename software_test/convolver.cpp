#include "convolver.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <stdio.h>
#include <stdlib.h>
#include "time.h"


void convolveImage( const struct image& image, const struct kernel& kernel)
{
  struct node activatedNode;
  activatedNode.mNode = new std::vector< std::vector<int> >;
  
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
  
  outputShit(activatedNode);
  
}

void initImage(const struct image& image)
{
  srand (time(NULL));
  std::fstream verilogTestFile;
  verilogTestFile.open("source.mem", std::ios::out);

  // You can change the 99 to the size you want later
  image.mImage->resize(99);
  
  // 0-98

  int number;
  int imageRowSize = static_cast<int>(image.mImage->size());
  for(int i = 0; i < imageRowSize; ++i)
  {
    //image.mImage->at(i).resize(imageRowSize);
    
    for(int j = 0; j < imageRowSize; ++j)
    {
      number = (rand() % 256) - 128;

      image.mImage->at(i).push_back(number);
      verilogTestFile << std::hex << number << " ";

    }
  }
  verilogTestFile.close();

  
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

void printShit(const struct node &node)
{
  // Assuming NxN
  int x_length = static_cast<int>(node.mNode->size());
  int y_length = static_cast<int>(node.mNode->size());
  
  for(int i = 0; i < x_length; ++i)
  {
    std::cout << "{";
    for(int j = 0; j < y_length; ++j)
    {
      std::cout << node.mNode->at(i)[j] << ",";
    }
    std::cout << "}" << std::endl;
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
