#ifndef DISPLAY_H
#define DISPLAY_H

#include <systemc>
#include "tlm_utils/simple_target_socket.h"
#include "tlm.h"
#include "EasyBMP/EasyBMP.h"

#define WIDTH  100
#define HEIGHT 100

SC_MODULE(display)
{
	// Auxillary signals: 
	sc_signal<unsigned int> value;
	unsigned int v;

	// TLM Port:
	tlm_utils::simple_target_socket<display,32> targetSocket;

	// Methods::
	void transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay);

	unsigned char IMAGE[WIDTH][HEIGHT];

	// Constructor:
	SC_CTOR(display) : targetSocket("targetSocket")
	{
		int x;
		for(x = 0; x < WIDTH; x++)
		{
			int y;
			for(y = 0; y < HEIGHT; y++)
			{
				IMAGE[y][x] = 0;
			}
		}
		targetSocket.register_b_transport(this,&display::transport);
	}
};

// Methods
void display::transport(tlm::tlm_generic_payload& trans, sc_core::sc_time& delay)
{
	tlm::tlm_command cmd = trans.get_command();
	sc_dt::uint64    adr = trans.get_address();
	unsigned char*   ptr = trans.get_data_ptr();

	v = value.read();

	if ( cmd == tlm::TLM_READ_COMMAND )
	{
		//Flush Image
		BMP image;
		image.SetSize(WIDTH,HEIGHT);
		int x;
		for(x = 0; x < WIDTH; x++)
		{
			int y;
			for(y = 0; y < HEIGHT; y++)
			{
				image(x,y)->Red   = IMAGE[y][x];
				image(x,y)->Green = IMAGE[y][x];
				image(x,y)->Blue  = IMAGE[y][x];
				image(x,y)->Alpha = 0;
			}
		}
		image.WriteToFile("Output.bmp");
		*reinterpret_cast<unsigned int*>(ptr) = 1;
	}
	else if ( cmd == tlm::TLM_WRITE_COMMAND )
	{
		adr = adr / 4;
		unsigned int y = adr / 100;
		unsigned int x = adr % 100;
		unsigned char value = *reinterpret_cast<unsigned char*>(ptr);
		IMAGE[y][x] = value;
		//cout << "Addr:" << adr << "\tX: " << x << "\tY: " << y << "\tValue: " << value << endl;
	}
	
	//disallow dmi
	trans.set_dmi_allowed(false);

	sc_time delaytime(10,SC_NS);

	delay += delaytime; 

	trans.set_response_status(tlm::TLM_OK_RESPONSE);
}

#endif

