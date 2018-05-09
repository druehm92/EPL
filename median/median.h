// Copyright (C) 2014 University of Kaiserslautern
// Microelectronic System Design Research Group
//
// This file is part of the FPGAHS Course
// de.uni-kl.eit.course.fpgahs
//
// Matthias Jung <jungma@eit.uni-kl.de>
// Christian De Schryver <schryver@eit.uni-kl.de>

#ifndef MEDIAN_H
#define MEDIAN_H

#include<image.h>




void medianFilter0(const unsigned char input[][HEIGHT], unsigned char output[][HEIGHT]);
//void medianFilter1(const unsigned char input[][HEIGHT], unsigned char output[][HEIGHT], unsigned int width, unsigned int height);

unsigned int middle_of_3(unsigned int a, unsigned int b, unsigned int c);

unsigned int insertionSort(int window[]);
unsigned int medianSort(int window[]);
#endif // MEDIAN_H
