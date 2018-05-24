#ifndef COUNTER_H
#define COUNTER_H

#include <systemc>
#include "tlm_utils/simple_target_socket.h"
#include "tlm.h"

SC_MODULE(counter)
{
	// Auxillary signals: 
	sc_signal<unsigned int> value;
	unsigned int v;

	// Ports:
	sc_in<bool> clk;
	sc_in<bool> rst;

	// TLM Port:
	tlm_utils::simple_target_socket<counter,32> targetSocket;

	// Methods::
	void transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay);
	void countingProcess();

	// Constructor:
	SC_CTOR(counter) : clk("i2t_clk"),
	                   rst("i2t_rst"),
	                   targetSocket("targetSocket")
	{
		SC_METHOD(countingProcess);
		sensitive << clk.pos() << rst.pos();

		targetSocket.register_b_transport(this,&counter::transport);
	}
};

// Methods
void counter::transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay)
{
	tlm::tlm_command cmd = trans.get_command();
	sc_dt::uint64    adr = trans.get_address();
	unsigned char*   ptr = trans.get_data_ptr();

	v = value.read();

	if ( cmd == tlm::TLM_READ_COMMAND )
	{
		*reinterpret_cast<unsigned int*>(ptr) = v; 
	}
	else if ( cmd == tlm::TLM_WRITE_COMMAND )
	{
		// Do Nothing at All
	}
	
	//disallow dmi
	trans.set_dmi_allowed(false);

	sc_time delaytime(10,SC_NS);

	delay += delaytime; 

	trans.set_response_status(tlm::TLM_OK_RESPONSE);
}

void counter::countingProcess()
{
	if(rst.read() == false) // reset is active (negative reset -- nreset)
	{
		value.write(0x0);
	}
	else // reset is not active
	{
		value.write(value.read()+1);
		if(value.read() == 0)
		{
			cout << endl << "COUNTER RESTART " << endl;
		}
	}
}

#endif

