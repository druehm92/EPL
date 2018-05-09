// Copyright (C) 2014 University of Kaiserslautern
// Microelectronic System Design Research Group
//
// This file is part of the FPGAHS Course
// de.uni-kl.eit.course.fpgahs
//
// Matthias Jung <jungma@eit.uni-kl.de>
// Christian De Schryver <schryver@eit.uni-kl.de>

#include<image.h>
#include<stdio.h>
#include <stdint.h>
#include "profiler.h"
#define MIN(x,y) ( (x)>(y) ? (y) : (x) )
#define MAX(x,y) ( (x)>(y) ? (x) : (y) )

#define KS 3 //KERNELSIZE

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

unsigned int medianSort(unsigned int window[])
{

    int const N=KS*KS;
    int t[N], z[N];
    int i, k, stage;

    // copy input data locally
    for (i=0; i<KS*KS; i++) z[i] = window[i];
        // sorting network loop
        for (stage = 1; stage <= N; stage++)
        {
            if ((stage%2)==1) k=0;
            if ((stage%2)==0) k=1;
            for (i = k; i<N-1; i=i+2)
            {
                t[i ] = MIN(z[i], z[i+1]);
                t[i+1] = MAX(z[i], z[i+1]);
                z[i ] = t[i ];
                z[i+1] = t[i+1];
            }
        } // end of sorting network loop
    // the median value is in location N/2+1,
    // but in C the address starts from 0
    return z[N/2];
} // end of function

unsigned int middle_of_3(unsigned int a,unsigned int b, unsigned int c)
{
     unsigned int middle;

     if ((a <= b) && (a <= c))
     {
        middle = (b <= c) ? b : c;
     }
     else if ((b <= a) && (b <= c))
     {
        middle = (a <= c) ? a : c;
     }
     else
     {
        middle = (a <= b) ? a : b;
     }

    return middle;
}


void medianFilter0(const unsigned char input[][HEIGHT], unsigned char output[][HEIGHT])
{

    //100 x 100 Image and 3x3 window
    unsigned int window[KS*3];

    unsigned int origin;

    for (unsigned int w=0; w < WIDTH; w++)
    {
        for (unsigned int h=0; h < HEIGHT; h++)
        {
            //printf("%d. round: \n\r",h);
            for (int i=0; i <= KS-1;i++)
            {
                window[(i+0)+i*(KS-1)]= input[w+1-1][h+1+i-1];
                window[(i+1)+i*(KS-1)] = input[w+1][h+1+i-1];
                window[(i+2)+i*(KS-1)] = input[w+1+1][h+1+i-1];
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

}

//void medianFilter1(const unsigned char input[][HEIGHT], unsigned char output[][HEIGHT], unsigned int width, unsigned int height)
//{

//    //100 x 100 Image and 3x3 window
//    unsigned int window0[KS];
//    unsigned int window1[KS];
//    unsigned int window2[KS];
//    unsigned int middles[KS];

//    unsigned int origin;

//    for (unsigned int w=0; w < WIDTH; w++)
//    {
//        for (unsigned int h=0; h < HEIGHT; h++)
//        {
//            //printf("%d. round: \n\r",h);
//            for (int i=0; i <= KS-1;i++)
//            {
//                window0[i]=input[w+1-1][h+1+i-1];
//                window1[i]=input[w+1][h+1+i-1];
//                window2[i]=input[w+1+1][h+1+i-1];

//                middles[i] = middle_of_3(window0[i],window1[i],window2[i]);
//                //printf("Middle:\n %x\n\r",middles[i]);

//            }

//           origin = middle_of_3(middles[0],middles[1],middles[2]);

//           if (h == 0 || w == 0 || w == WIDTH-1 || h == HEIGHT-1 )
//           {
//                output[w][h] = 0x00;
//           }
//           else
//           {
//                output[w][h] = origin;
//           }
//           //printf("Origin:\n %x\n\r",origin);
//        }
//    }

//}

