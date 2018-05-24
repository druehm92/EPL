#ifndef RSTINVERTER_H
#define RSTINVERTER_H

#include <systemc>
#include <iostream>

using namespace std;

SC_MODULE(rstInverter)
{
	sc_in<bool> rstIn;
	sc_out<bool> rstOut;

	SC_CTOR(rstInverter)
	{
		SC_METHOD(process);
		sensitive << rstIn;
	}

	void process()
	{
		rstOut.write(!rstIn.read());
	}
};


#endif

