#Matthias Jung 2012
CROSS_COMPILE_DIR = /users/jung/tools/SynopsysGnuArm/arm-2010q1/bin

ARCH		?= arm
CROSS_COMPILE	?= arm-none-eabi-

AS		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)as 
LD		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)ld
CC		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)gcc
CXX		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)g++
CPP		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)cpp
AR		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)ar
NM		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)nm
STRIP		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)strip
OBJCOPY		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)objcopy
OBJDUMP		= $(CROSS_COMPILE_DIR)/$(CROSS_COMPILE)objdump



CFLAGS = -g -O3 -lunistd -I .
CXXFLAGS = -g -O3 -lunistd -I . -fno-exceptions

ASFLAGS = -EL	
LNK_OPT = -nostartfiles
LNK_SCRIPT = arm_boot.ld
LNK_FILE_OPT = -nostartfiles -Xlinker -T$(LNK_SCRIPT)

OBJS =	boot.o\
	system.o\
	main.o

all:	main.elf

main.elf: $(OBJS) $(LNK_SCRIPT) Makefile
	$(CC) $(LNK_FILE_OPT) -o $@ $(OBJS) $(LNK_OPT)

boot.o: Makefile
	$(CPP) boot.s $(CFLAGS) | $(AS) $(ASFLAGS) -o boot.o

clean:	
	rm -f *.o *.elf 
