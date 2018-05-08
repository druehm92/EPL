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

int main(void)
{

	initTerminal();  
	// Do a profiling of this block:
	{
		Profiler p("Main");
		
		// Insert your code here:


	}

	flushDisplay();
	flushTerminal();

	while (1)
	{
	}
}

