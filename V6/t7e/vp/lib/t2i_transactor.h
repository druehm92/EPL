#ifndef T2I_TRANSACTOR_H
#define T2I_TRANSACTOR_H

#include <systemc>
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm_utils/simple_target_socket.h"

#include "tlm.h"
#include <iostream>

using namespace std;

#define SDEBUG 0

SC_MODULE(t2i_transactor)
{
	// States: enum doesnt work!
	#define SIDLE   0
	#define SWORK   1
	#define SFINISH 2
	sc_signal<int> currentState;

	// Ports:
	sc_in<bool>          clk;
	sc_in<bool>          rst;
	sc_out<sc_uint<32> > dataout;
	sc_out<bool>         done;
	sc_in<sc_uint<32> >  datain;
	sc_in<bool>          enable;
	sc_in<sc_uint<32> >  addr;
	sc_in<bool>          write;

	// Auxillary signals:
	unsigned int dataout_a;
	unsigned int datain_a;
	sc_uint<32>  addr_a;
	bool         write_a;
	bool         transactionFinished;

	sc_event startTransaction_a;

	// TLM Port:
	tlm_utils::simple_initiator_socket<t2i_transactor,32> initiatorSocket;
	tlm_utils::simple_target_socket<t2i_transactor,32> debugTargetSocket;	

	// Methods:
	void fsmState();
	void sendThread();
	unsigned int transport_dbg(tlm::tlm_generic_payload& trans);


	// Constructor:
	SC_CTOR(t2i_transactor) : currentState("t2i_state"), clk("t2i_clk"), rst("t2i_rst"), dataout("t2i_dataout"),
	                         done("t2i_done"), datain("t2i_datain"), enable("t2i_enable"), addr("t2i_addr"), write("t2i_write")
	{
		transactionFinished = false;

		debugTargetSocket.register_transport_dbg(this,&t2i_transactor::transport_dbg);		

		SC_THREAD(sendThread);
		sensitive << startTransaction_a;
		SC_METHOD(fsmState);
		sensitive << clk.pos() << rst.pos();
	}

};

unsigned int t2i_transactor::transport_dbg(tlm::tlm_generic_payload& trans)
{
	return initiatorSocket->transport_dbg(trans);
}

void t2i_transactor::sendThread()
{
	while(true)
	{
		wait(startTransaction_a);
		#if SDEBUG
		cout << "t2i: sendThread()" << endl;
		#endif

		tlm::tlm_generic_payload trans;
		trans.set_address(addr_a);
		if(write_a == false)
		{
			trans.set_command(tlm::TLM_READ_COMMAND);
		}
		else
		{
			trans.set_command(tlm::TLM_WRITE_COMMAND);
		}
		trans.set_data_ptr(reinterpret_cast<unsigned char*>(&datain_a));
		trans.set_data_length(4);
		trans.set_byte_enable_ptr(0);
		trans.set_byte_enable_length(0);
		trans.set_streaming_width(4);
		trans.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

		sc_time delay = SC_ZERO_TIME;

		initiatorSocket->b_transport(trans, delay);

		if(write_a == false)
		{
			dataout_a = *(reinterpret_cast<unsigned int*>(trans.get_data_ptr()));
			
			#if SDEBUG 
			cout << "t2i: Data From Memory: 0x0" << hex << dataout_a << endl;
			#endif
		}
		#if SDEBUG 
		cout << "t2i: sendThread() transactionFinished" << endl;
		#endif
		
		wait(delay);

		transactionFinished = true;
	}
}
void t2i_transactor::fsmState()
{
	// auxillary signals
	bool         done_a    = false;
	int          nextState = SIDLE;

	if(rst.read() == true) // reset is active
	{
		currentState = SIDLE;
		// todo: set some values to 0

		#if SDEBUG 
		cout << "t2i: RESET" << endl;
		#endif
	}
	else // reset is not active
	{
		if( currentState == SIDLE)
		{
			if(enable.read() == true)
			{
				// setup transaction
				write_a = write.read();
				if(write_a == true)
				{
					datain_a = datain.read();
				}
				addr_a = addr.read();

				//startTransaction_a.notify(SC_ZERO_TIME);
				#if SDEBUG 
				cout << "t2i: notify sendthread <...";
				#endif
				startTransaction_a.notify();
				#if SDEBUG 
				cout << ">" << endl;
				#endif

				nextState = SWORK;
				#if SDEBUG 
				cout << "t2i: SIDLE: START TRANSACTION" << endl;
				#endif
			}
			#if SDEBUG 
			cout << "t2i: SIDLE" << endl;
			#endif
		}
		else if( currentState == SWORK ) // 1
		{
			#if SDEBUG 
			cout << "t2i: SWORK" << endl;
			#endif
			if( transactionFinished == true)
			{
				#if SDEBUG 
				cout << "t2i: SWORK: Transaction Finished" << endl;
				#endif
				transactionFinished = false;
				nextState = SFINISH;
			}
			else
			{
				nextState = SWORK;
			}
		}
		else if( currentState == SFINISH) // 2
		{
			done_a = true;
			nextState = SIDLE;

			#if SDEBUG 
			cout << "t2i: SFINISH" << endl;
			#endif
		}

		currentState = nextState;

		dataout.write(dataout_a);
		done.write(done_a);
	}
}

#endif

