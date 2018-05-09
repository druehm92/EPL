// Copyright (C) 2014 University of Kaiserslautern
// Microelectronic System Design Research Group
// 
// This file is part of the FPGAHS Course
// de.uni-kl.eit.course.fpgahs
// 
// Matthias Jung <jungma@eit.uni-kl.de>
// Christian De Schryver <schryver@eit.uni-kl.de>

//Programm took ~0.00578816sec with medianFilter0 and medianSort
//Programm took ~0.00196452sec with medianFilter0 and InsertionSort



#include <iostream>
//#include <opencv2/imgproc/imgproc.hpp>
//#include <opencv2/highgui/highgui.hpp>
#include "profiler.h"
#include "median.h"
#include "EasyBMP/EasyBMP.h"

// define IMAGE, WIDTH, HEIGHT
#include "image.h"

using namespace std;
//using namespace cv;

int main(void)
{
	unsigned char OUT[WIDTH][HEIGHT];

	// Do a profiling of this block:
	{
		Profiler p;
        medianFilter0(IMAGE, OUT);
	
	}

	// Save Image:
        BMP image;
//        BMP input_image;
        image.SetSize(WIDTH,HEIGHT);
//        input_image.SetSize(WIDTH,HEIGHT);
        int x;
        for(x = 0; x < WIDTH; x++)
        {
                int y;
                for(y = 0; y < HEIGHT; y++)
                {
                        image(x,y)->Red   = OUT[x][y];
                        image(x,y)->Green = OUT[x][y];
                        image(x,y)->Blue  = OUT[x][y];
                        image(x,y)->Alpha = 0;

//                        input_image(x,y)->Red   = IMAGE[x][y];
//                        input_image(x,y)->Green = IMAGE[x][y];
//                        input_image(x,y)->Blue  = IMAGE[x][y];
//                        input_image(x,y)->Alpha = 0;
                }
        }
        //input_image.WriteToFile("/home/daniel/Dokumente/UNI_Kaiserslautern/Master EIT - ESY/3.Semester_SS18/FPGAHS/Lab/QtCreator/median.cpp/EasyBMP/Input.bmp");
        image.WriteToFile("/home/daniel/Dokumente/UNI_Kaiserslautern/Master EIT - ESY/3.Semester_SS18/FPGAHS/Lab/QtCreator/median.cpp/EasyBMP/Output.bmp");
}
