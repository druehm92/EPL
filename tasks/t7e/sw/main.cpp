// Copyright (C) 2011 University of Kaiserslautern
// Microelectronic System Design Research Group
// 
// Matthias Jung (jungma@eit.uni-kl.de) 
// 
// This file is part of the Virtual Platform Demos
// de.uni-kl.eit.vp.demo

extern "C"
{
	#include "system.h"
}

extern "C" void handle_interrupt(void)
{
        // Empty
}

#include "image.h"

class Profiler
{
	private:
		unsigned int _Start;
		char *_Name;

	public:
		Profiler(char *name);
		~Profiler();
};

Profiler::Profiler(char *name)
{
        _Name = name;
        _Start = getSystickCount();
}

Profiler::~Profiler()
{
        unsigned int cycles = getSystickCount() - _Start;
	float time = cycles * 10 / 1000; // usec
        printf("Profiler: %s took %d cycles (~ %d usec)\n", _Name, cycles, (int)time);
}


#define KS 3 //KERNELSIZE
#define HEIGHT 100
#define WIDTH 100

unsigned int insertionSort(unsigned int window[])
{
    unsigned int temp;
    int i , j;
    for(i = 1; i < 9; i++){
        temp = window[i];

        for(j = i-1; (j >= 0) && (window[j]<temp); j--){
            window[j+1] = window[j];
        }
        window[j+1] = temp;

    }

    //for (int k = 0;k<9;k++)
    //{
    //     printf("temp: %x\n\r",window[k]);
    //}
    //printf("return: %x\n\r",window[KS]);
    return window[KS];
}








int main(void)
{

	initTerminal();  
	// Do a profiling of this block:
	{
		Profiler p("Main");
		
		// Insert your code here:
//void medianFilter0(const unsigned char input[][HEIGHT], unsigned char output[][HEIGHT])
//{

    //100 x 100 Image and 3x3 window
    unsigned int window[KS*3];
    unsigned char output[WIDTH][HEIGHT];
    unsigned int origin;

    for (unsigned int w=0; w < WIDTH; w++)
    {
        for (unsigned int h=0; h < HEIGHT; h++)
        {
            //printf("%d. round: \n\r",h);
            for (int i=0; i <= KS-1;i++)
            {
                window[(i+0)+i*(KS-1)]= IMAGE[w+1-1][h+1+i-1];
                window[(i+1)+i*(KS-1)] = IMAGE[w+1][h+1+i-1];
                window[(i+2)+i*(KS-1)] = IMAGE[w+1+1][h+1+i-1];
                //printf("Value:\n %x\n\r %x\n\r %x\n\r",window[3*i],window[3*i+1],window[3*i+2]);

            }

           origin = insertionSort(window);

           //origin =  medianSort(window);

           if (h == 0 || w == 0 || w == WIDTH-1 || h == HEIGHT-1 )
           {
                output[w][h] = 0x00;
           }
           else
           {
                output[w][h] = origin;
           }
           //printf("Origin:\n %x\n\r",origin);
        }
    }

//}

	}

	flushDisplay();
	flushTerminal();

	while (1)
	{
	}
}

