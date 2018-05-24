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



unsigned int insertionSort(unsigned int window[])
{
    unsigned int temp;
    int i , j;
    for(i = 1; i < 3; i++){
        temp = window[i];
        for(j = i-1; (j >= 0) && (window[j]<temp); j--){
            window[j+1] = window[j];
        }
        window[j+1] = temp;
    }
    return window[KS];
}




int main(void)
{

	initTerminal();  
	// Do a profiling of this block:
	{
		Profiler p("Main");
		
		// Insert your code here:
        //100 x 100 Image and 3x3 window
        unsigned int kernel_v[KS];
        unsigned int kernel_h[KS];
        unsigned char temp[WIDTH][HEIGHT];
        unsigned char output[WIDTH][HEIGHT];
        unsigned int origin;

        //vertical 1D median
        for (unsigned int h=0; h <= HEIGHT-1; h++){
            for (unsigned int w=0; w <= WIDTH-1; w++){
                if (w > 0 && h > 0 && w < WIDTH-1 && h < HEIGHT-1){                
                    for (int ks=0; ks <= KS-1;ks++){
                        kernel_v[ks] = IMAGE[w][h+ks-1];
                    }
                    origin = insertionSort(kernel_v);
                    
                }
                
                if (h == 0 || w == 0 || w == WIDTH-1 || h == HEIGHT-1){
                    temp[w][h] = 0x00;
                }
                else{
                    temp[w][h] = origin;
                }
                
                //setPixel(w,h, output[w][h]); 
                //setPixel(w,h, IMAGE[w][h]); //for receiving input image  
            }
	    }


        //horizontal 1D median
        for (unsigned int w=0; w <= WIDTH-1; w++){
            for (unsigned int h=0; h <= HEIGHT-1; h++){
                if (w > 0 && h > 0 && w < WIDTH-1 && h < HEIGHT-1){                
                    for (int ks=0; ks <= KS-1;ks++){
                        kernel_h[ks] = temp[w+ks-1][h];
                    }
                    origin = insertionSort(kernel_h);
                }
                
                if (h == 0 || w == 0 || w == WIDTH-1 || h == HEIGHT-1){
                    output[w][h] = 0x00;
                }
                else{
                    output[w][h] = origin;
                }
                
                setPixel(w,h, temp[w][h]); 
                //setPixel(w,h, IMAGE[w][h]); //for receiving input image  
            }
	    }		

    }
	flushDisplay();
	flushTerminal();

	while (1)
	{
	}
}

