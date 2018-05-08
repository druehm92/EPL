#ifndef SYSTEM_H_
#define SYSTEM_H_

#include <stdarg.h>

/**
 * \brief Write a single character to a defined address
 * \param c is the character to print
**/
void printchar(char c);

/**
 * \brief Simple print implementation
 * \param str is the string to print
**/
void myprint(const char* str);

/**
 * \brief Initialize the Terminal
**/
void initTerminal(void) ;

/**
 * \brief Flush and Close the Terminal
**/
void flushTerminal(void);

/**
 * \brief Get systick counter
**/
unsigned int getSystickCount();

/**
 * \brief Flush the Display
**/
bool flushDisplay();

/**
 * \brief Set Pixel
**/
void setPixel(unsigned int x, unsigned int y, unsigned char value);

/**
 * \brief Printf implementations
**/
void init_printf(void* putp,void (*putf) (void*,char));

void tfp_printf(char *fmt, ...);
void tfp_sprintf(char* s,char *fmt, ...);

void tfp_format(void* putp,void (*putf) (void*,char),char *fmt, va_list va);

#define printf tfp_printf 
#define sprintf tfp_sprintf 


#endif
