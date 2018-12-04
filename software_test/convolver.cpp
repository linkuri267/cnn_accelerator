#include "convolver.h"
#include <sstream>
#include <iostream>
#include <fstream>
#include <iomanip>
#include <algorithm>
#include <stdio.h>
#include <stdlib.h>
#include "time.h"

void convolveImage( const struct image& image, const struct kernel& kernel)
{
  struct node activatedNode;
  activatedNode.mGrid = new std::vector< std::vector<int> >;

  // prints original values
  activatedNode.mGrid->assign(image.mGrid->begin(), image.mGrid->end());
  printShit(activatedNode);
  activatedNode.mGrid->clear();
  
  std::cout << "-----------------\n";
  
  //originalConvolution(image, kernel, activatedNode);
  //relu(image, activatedNode);
  //maxPool(image, activatedNode);
  maxPool(relu(originalConvolution(image, kernel)));
  
  printShit(activatedNode);
  
}

void initImage(const struct image& image, int size)
{
  srand( static_cast<unsigned int>(time(NULL)));
  // You can change the 99 to the size you want later
  image.mGrid->resize(size);
  
  // 0-98

  std::fstream verilogTestFile;
  verilogTestFile.open("source.mem", std::ios::out);
  
  int number = 0;
  int imageRowSize = static_cast<int>(image.mGrid->size());
  for(int i = 0; i < imageRowSize; ++i)
  {
    for(int j = 0; j < imageRowSize; ++j)
    {
      number = (rand() % 256) - 128;
      image.mGrid->at(i).push_back(number);
      verilogTestFile << std::hex << number << " ";
    }
    // Incremental if needed
    /*for(int j = 0; j < imageRowSize; ++j)
    {
      image.mGrid->at(i).push_back(j-5);
    }*/
  }
  
  //outputShit(image, "source.mem", false);
}

void initKernel(const struct kernel& kernel)
{
  int incrementor = 0;
  
  kernel.mGrid->resize(3);
  
  int kernelRowSize = static_cast<int>(kernel.mGrid->size());
  for(int i = 0; i < kernelRowSize; ++i)
  {
    kernel.mGrid->at(i).resize(3);
  }
  
  for(int i = 0; i < kernelRowSize; ++i)
  {
    for(int j = 0; j < kernelRowSize; ++j)
    {
      kernel.mGrid->at(i)[j] = incrementor;
      ++incrementor;
    }
  }
}

struct NeuralNetObj originalConvolution( const struct image& image, const struct kernel& kernel )
{
  // Assuming NxN
  int x_length = static_cast<int>(image.mGrid->size());
  int y_length = static_cast<int>(image.mGrid->size());
  
  struct node activatedNode;
  activatedNode.mGrid = new std::vector< std::vector<int> >;
  
  int kernel_length = static_cast<int>(kernel.mGrid->size());
  int convolvedValue = 0;
  int values[9];
  
  for(int i = 0; i < (x_length - kernel_length + 1); ++i)
  {
    std::vector<int> *temp = new std::vector<int>;
    for(int j = 0; j < (y_length - kernel_length + 1); ++j)
    {
      convolvedValue = 0;
      // Convolve the image to the kernel
      values[0] = image.mGrid->at(i)[j]      * kernel.mGrid->at(0)[0];
      values[1] = image.mGrid->at(i+1)[j]    * kernel.mGrid->at(1)[0];
      values[2] = image.mGrid->at(i+2)[j]    * kernel.mGrid->at(2)[0];
      values[3] = image.mGrid->at(i)[j+1]    * kernel.mGrid->at(0)[1];
      values[4] = image.mGrid->at(i+1)[j+1]  * kernel.mGrid->at(1)[1];
      values[5] = image.mGrid->at(i+2)[j+1]  * kernel.mGrid->at(2)[1];
      values[6] = image.mGrid->at(i)[j+2]    * kernel.mGrid->at(0)[2];
      values[7] = image.mGrid->at(i+1)[j+2]  * kernel.mGrid->at(1)[2];
      values[8] = image.mGrid->at(i+2)[j+2]  * kernel.mGrid->at(2)[2];
      
      // Sum up all the values
      for(int k = 0; k < 9; ++k)
      {
        convolvedValue += values[k];
      }
      temp->push_back(convolvedValue);
    }
    // Add a new row
    activatedNode.mGrid->push_back( *temp );
  }
  
  outputShit(activatedNode, "orig_convolve.txt");
  return activatedNode;
}

struct NeuralNetObj relu( const struct NeuralNetObj& nno)
{
  // Assuming NxN
  int x_length = static_cast<int>(nno.mGrid->size());
  int y_length = static_cast<int>(nno.mGrid->size());
  
  struct node activatedNode;
  activatedNode.mGrid = new std::vector< std::vector<int> >;
  
  activatedNode.mGrid->assign(nno.mGrid->begin(), nno.mGrid->end());
  
  for(int i = 0; i < (x_length); ++i)
  {
    for(int j = 0; j < (y_length); ++j)
    {
      if( nno.mGrid->at(i)[j] < 0)
      {
        activatedNode.mGrid->at(i)[j] = 0;
      }
      // else don't do anything
    }
  }
  
  outputShit(activatedNode, "relu.txt");
  return activatedNode;
}

struct NeuralNetObj maxPool( const struct NeuralNetObj& nno )
{
  // Assuming NxN
  int x_length = static_cast<int>(nno.mGrid->size());
  int y_length = static_cast<int>(nno.mGrid->size());
  
  struct node activatedNode;
  activatedNode.mGrid = new std::vector< std::vector<int> >;
  
  //int kernel_length = static_cast<int>(kernel.mGrid->size());
  // I'm hard coding this for now because we've been using 3x3 grids the whole time, if you want to extend this, please tell
  int kernel_length = 3;
  int values[9];
  
  int currMaxValue = 0;
  
  for(int i = 0; i < (x_length - kernel_length + 1); ++i)
  {
    std::vector<int> *temp = new std::vector<int>;
    for(int j = 0; j < (y_length - kernel_length + 1); ++j)
    {
      // Convolve the nno to the kernel
      values[0] = nno.mGrid->at(i)[j];
      values[1] = nno.mGrid->at(i+1)[j];
      values[2] = nno.mGrid->at(i+2)[j];
      values[3] = nno.mGrid->at(i)[j+1];
      values[4] = nno.mGrid->at(i+1)[j+1];
      values[5] = nno.mGrid->at(i+2)[j+1];
      values[6] = nno.mGrid->at(i)[j+2];
      values[7] = nno.mGrid->at(i+1)[j+2];
      values[8] = nno.mGrid->at(i+2)[j+2];
      
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
    activatedNode.mGrid->push_back( *temp );
  }
    
  outputShit(activatedNode, "max_pool_results.txt");
  return activatedNode;
}

void printShit(const struct node &node)
{
  // Assuming NxN
  int x_length = static_cast<int>(node.mGrid->size());
  int y_length = static_cast<int>(node.mGrid->size());
  
  for(int i = 0; i < x_length; ++i)
  {
    for(int j = 0; j < y_length; ++j)
    {
        std::cout << node.mGrid->at(i)[j];
        
        if( j != y_length - 1 )
        {
            std::cout << ",";
        }
    }
    
    std::cout << std::endl;
  }
}

void outputShit(const struct NeuralNetObj &nno, const std::string &filename, bool csv_flag){
    std::ofstream softwareOuput;
    softwareOuput.open(filename, std::ios::out|std::ios::trunc);
    
    // Assuming NxN
    int x_length = static_cast<int>(nno.mGrid->size());
    int y_length = static_cast<int>(nno.mGrid->size());
    
    softwareOuput << "{";
    for(int i = 0; i < x_length; ++i)
    {
        softwareOuput << "{";
        for(int j = 0; j < y_length; ++j)
        {
            softwareOuput << nno.mGrid->at(i)[j];
            
            if(csv_flag)
            {
                softwareOuput << ",";
            }
            else if( (!csv_flag) && (j != y_length - 1) )
            {
              softwareOuput << " ";
            }
        }
        softwareOuput << "}" << std::endl;
    }
    softwareOuput << "}";
    softwareOuput.close();
}
