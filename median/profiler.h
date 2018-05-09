// Copyright (C) 2014 University of Kaiserslautern
// Microelectronic System Design Research Group
// 
// This file is part of the FPGAHS Course
// de.uni-kl.eit.course.fpgahs
// 
// Matthias Jung <jungma@eit.uni-kl.de>
// Christian De Schryver <schryver@eit.uni-kl.de>

#include <chrono>
#include <iostream>

using namespace std;

class Profiler
{
	private:
		chrono::high_resolution_clock::time_point  start;

	public:
		Profiler()
		{
			start = chrono::high_resolution_clock::now();
		}

		~Profiler()
		{
			chrono::high_resolution_clock::time_point end = std::chrono::high_resolution_clock::now();
			chrono::duration< double > time = chrono::duration_cast< chrono::duration< double > >(end - start);
			cout << "Profile: Programm took ~" << time.count() << "sec" << endl;
		}
};


