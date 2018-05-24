#ifndef GENERATOR_H
#define GENERATOR_H

#include <systemc>
#include "tlm_utils/simple_initiator_socket.h"
#include "tlm.h"
#include <iostream>

using namespace std;

SC_MODULE(generator)
{
	// TLM Port:
	tlm_utils::simple_initiator_socket<generator,32> initiatorSocket;

	// Methods::
	void sendThread();

	// Constructor:
	SC_CTOR(generator) : initiatorSocket("targetSocket")
	{
		SC_THREAD(sendThread);
	}


};

// Methods


void generator::sendThread()
{
	for(int i = 0; i < 5; i++)
	{
		unsigned int word = 0xdeadbeef;
		tlm::tlm_generic_payload trans;
		trans.set_address(i*4);
		if(i%2==0)
		{
			trans.set_command(tlm::TLM_READ_COMMAND);
			trans.set_data_ptr(0);
		}
		else
		{
			trans.set_command(tlm::TLM_WRITE_COMMAND);
			trans.set_data_ptr(reinterpret_cast<unsigned char*>(&word));
		}
		trans.set_data_length(4);
		trans.set_byte_enable_ptr(0);
		trans.set_byte_enable_length(0);
		trans.set_streaming_width(4);
		trans.set_response_status(tlm::TLM_INCOMPLETE_RESPONSE);

		sc_time delay = SC_ZERO_TIME;

		initiatorSocket->b_transport(trans, delay);

		if(i%2==0)
		{
			unsigned int data = *reinterpret_cast<unsigned int*>(trans.get_data_ptr());
			cout << "Received Data:" << hex << data << endl;
		}
	}

	sc_stop();
}

#endif

