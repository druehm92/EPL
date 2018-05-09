# Christian De Schryver 2014
# Markus Steffes 2015

CC=g++
CFLAGS=-g -Wall -std=c++0x -I./EasyBMP
#LDFLAGS=-L$(SYSTEMC_LIB_DIR) -lsystemc


all:
	$(CC) $(CFLAGS) $(LDFLAGS) -o main EasyBMP/EasyBMP.cpp median.cpp main.cpp

dbg:
	$(CC) -v $(CFLAGS) $(LDFLAGS) -o main median.cpp main.cpp

clean:	
	rm -f *.o main Output.bmp *.cpp.*

