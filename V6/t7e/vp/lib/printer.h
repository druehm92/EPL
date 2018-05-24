#ifndef PRINTER_H
#define PRINTER_H

#include <systemc>
#include <iostream>

SC_MODULE(printer)
{
	sc_in<bool> clk;
	sc_in<sc_uint<32> > value;
	SC_CTOR(printer)
	{
		SC_METHOD(process);
		sensitive << clk.pos();
	}
	void process()
	{
		sc_uint<32> end = 10;
		if(value >= end)
		{
			std::cout << "Simulation Finished" << std::endl;  
			sc_stop();
		}
		std::cout << value << std::endl;  
	}
};

#endif

