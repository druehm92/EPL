#ifndef I2T_TRANSACOR_H
#define I2T_TRANSACOR_H

#include <systemc>
#include "tlm_utils/simple_target_socket.h"
#include "tlm_utils/simple_initiator_socket.h"

#include "tlm.h"
#include <iostream>

using namespace std;

#define SDEBUG 0

SC_MODULE(i2t_transactor)
{
	// States: enum doesnt work!
	#define SIDLE 0
	#define SSEND 1 
	#define SWAIT 2 
	sc_signal<int> currentState;

	// Auxillary signals;
	sc_uint<32>   dataout_a; 
	unsigned int  datain_a; 
	unsigned char datain_a_byte; 
	unsigned char datain_a_array[10];
	sc_uint<20>   addr_a;    
	bool          write_a;   
	bool          requestPending_a; 
	sc_event      requestComplete_a;

	// Ports:
	sc_in<bool>          clk;
	sc_in<bool>          rst;
	sc_in<sc_uint<32> >  datain;
	sc_in<bool>          done;
	sc_out<bool>         enable;
	sc_out<sc_uint<32> > dataout;
	sc_out<sc_uint<20> > addr;
	sc_out<sc_uint<2> >  width;
	sc_out<bool>         write;

	// TLM Port:
	tlm_utils::simple_target_socket<i2t_transactor,32> targetSocket;
	tlm_utils::simple_initiator_socket<i2t_transactor,32> debugInitiatorSocket;
	

	// Methods::
	void transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay);
	unsigned int transport_dbg(tlm::tlm_generic_payload& trans);
	void fsmState();

	// Constructor:
	SC_CTOR(i2t_transactor) : currentState("i2t_state"), clk("i2t_clk"), rst("i2t_rst"), dataout("i2t_dataout"),
	                         done("i2t_done"), datain("i2t_datain"), enable("i2t_enable"), addr("i2t_addr"),
				 write("i2t_write"), targetSocket("targetSocket")
	{
		SC_METHOD(fsmState);
		sensitive << clk.pos() << rst.pos();

		targetSocket.register_b_transport(this,&i2t_transactor::transport);
		targetSocket.register_transport_dbg(this,&i2t_transactor::transport_dbg);

		requestPending_a = false;
	}


};

// Methods
unsigned int i2t_transactor::transport_dbg(tlm::tlm_generic_payload& trans)
{
	return debugInitiatorSocket->transport_dbg(trans);
}

void i2t_transactor::transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay)
{
	#if SDEBUG 
	cout << "i2t: START TRANSACTION" << endl;
	#endif
	tlm::tlm_command cmd = trans.get_command();
	sc_dt::uint64    adr = trans.get_address();
	unsigned int     len = trans.get_data_length();
	unsigned char*   ptr = trans.get_data_ptr();

	if(len == 1) // Set byte access
	{
		width.write(1);
	}
	else // Set full word access
	{
		width.write(0);
	}	

	if ( cmd == tlm::TLM_READ_COMMAND )
	{
		write_a = false;
		addr_a = adr;
	}
	else if ( cmd == tlm::TLM_WRITE_COMMAND )
	{
		write_a   = true;
		addr_a    = adr;
		if(len == 1) // TODO ungetestet
		{
			dataout_a = (unsigned int)*reinterpret_cast<unsigned char*>(ptr);
		}
		else // scheint zu gehen
		{
			dataout_a = *reinterpret_cast<unsigned int*>(ptr);
		}
	}
	
	requestPending_a = true;

	//allow dmi
	trans.set_dmi_allowed(false);

	//Wait for requestComplete
	wait(requestComplete_a);
	requestPending_a = false;
	#if SDEBUG 
	cout << "i2t: CONTINUE" << endl;
	#endif

	if(write_a == false) // READ
	{
		if(len == 1) // Byte access
		{
			*reinterpret_cast<unsigned char*>(ptr) = (unsigned char)datain_a;
		}
		else // Full Word access, UNGETESTET
		{
			//trans.set_data_ptr(reinterpret_cast<unsigned char*>(&datain_a));
			*reinterpret_cast<unsigned int*>(ptr) = datain_a;
		}
	}

	trans.set_response_status(tlm::TLM_OK_RESPONSE);

	// reset data
	write_a   = false;
	addr_a    = 0;
	dataout_a = 0;
}

void i2t_transactor::fsmState()
{
	// Auxillary signals:
	bool enable_a  = false;
	int  nextState = SIDLE;

	if(rst.read() == true) // reset is active
	{
		currentState = SIDLE;
		enable.write(false);
		dataout.write(0x0);
		addr.write(0x0);
		write.write(false);

		#if SDEBUG 
		cout << "i2t: RESET" << endl;
		#endif
	}
	else // reset is not active
	{
		if( currentState == SIDLE) // 0
		{
			if(requestPending_a == true)
			{
				enable_a  = true;
				nextState = SSEND;
			}

			#if SDEBUG 
			cout << "i2t: IDLE " << endl;
			#endif
		}
		else if( currentState == SSEND ) // 1
		{
			nextState = SWAIT;

			// ENABLE is now on true
			#if SDEBUG 
			cout << "i2t: SEND" << endl;
			#endif
		}
		else if( currentState == SWAIT ) // 2
		{
			if(done.read() == true)
			{
				#if SDEBUG 
				cout << "i2t: DONE" << endl;
				#endif
				if( write_a == false) // read
				{
					datain_a = datain.read();

					#if SDEBUG 
					cout << "i2t: DONE (0x" << hex << datain_a << ")" << endl;
					#endif
				}
				requestComplete_a.notify();

				// Next Request Pending? branch directly to send
				//if(requestPending_a == true)
				//{
				//	enable_a  = true;
				//	nextState = SSEND;
				//}
				//else
				//{
					nextState = SIDLE;
				//}

			}
			else
			{
				nextState = SWAIT;

				#if SDEBUG 
				cout << "i2t: WAIT" << endl;
				#endif
			}
		}

		currentState = nextState;

		dataout.write(dataout_a);
		addr.write(addr_a);
		write.write(write_a);
		enable.write(enable_a);
	}
}

#endif

