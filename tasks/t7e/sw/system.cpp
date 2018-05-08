extern "C"
{
	#include "system.h"
}

#define TERMINAL_ADDR 0x8000000
#define COUNTER_ADDR  0x9000000
#define DISPLAY_ADDR  0xA000000


void printchar(char c)
{
	unsigned char* p = (unsigned char*)TERMINAL_ADDR;
	*p = (unsigned char)c;
} 

static void my_putcf (void*,char c)
{
	printchar(c);
}

void myprint(const char* str)
{
	int i=0;
	while(str[i]!='\0')
	{
		if (str[i] == '\n')
		{
			printchar('\r');
		}
		printchar(str[i]);
		i = i+1;
	}
} 

void initTerminal(void)
{
	unsigned long long* p = (unsigned long long*)(TERMINAL_ADDR+4);
	*p = 0;//puts buffer size to 0
	init_printf(0, my_putcf);
} 

void flushTerminal(void)
{
	char* p = (char*)(TERMINAL_ADDR+8);
	*p = 2;//flush and close
} 

unsigned int getSystickCount()
{
	unsigned int * value = (unsigned int *)(COUNTER_ADDR);
	return *value;
}

bool flushDisplay()
{
	unsigned int * value = (unsigned int *)(DISPLAY_ADDR);
	if(*value != 0)
	{
		return true;
	}
	else
	{
		return false;
	}
}

void setPixel(unsigned int x, unsigned int y, unsigned char value)
{
	unsigned int addr = 100 * y + x;
	addr = addr * 4;
	unsigned char* p = (unsigned char*)(DISPLAY_ADDR + addr);
	*p = (unsigned char)value;
}

typedef void (*putcf) (void*,char);
static putcf stdout_putf;
static void* stdout_putp;


#ifdef PRINTF_LONG_SUPPORT

static void uli2a(unsigned long int num, unsigned int base, int uc,char * bf)
{
	int n=0;
	unsigned int d=1;
	while (num/d >= base)
		d*=base;		 
	while (d!=0) {
		int dgt = num / d;
		num%=d;
		d/=base;
		if (n || dgt>0|| d==0) {
			*bf++ = dgt+(dgt<10 ? '0' : (uc ? 'A' : 'a')-10);
			++n;
		}
	}
	*bf=0;
}

static void li2a (long num, char * bf)
{
	if (num<0) {
		num=-num;
		*bf++ = '-';
	}
	uli2a(num,10,0,bf);
}

#endif

static void ui2a(unsigned int num, unsigned int base, int uc,char * bf)
{
	int n=0;
	unsigned int d=1;
	while (num/d >= base)
		d*=base;		
	while (d!=0) {
		int dgt = num / d;
		num%= d;
		d/=base;
		if (n || dgt>0 || d==0) {
			*bf++ = dgt+(dgt<10 ? '0' : (uc ? 'A' : 'a')-10);
			++n;
		}
	}
	*bf=0;
}

static void i2a (int num, char * bf)
{
	if (num<0) {
		num=-num;
		*bf++ = '-';
	}
	ui2a(num,10,0,bf);
}

static int a2d(char ch)
{
	if (ch>='0' && ch<='9') 
		return ch-'0';
	else if (ch>='a' && ch<='f')
		return ch-'a'+10;
	else if (ch>='A' && ch<='F')
		return ch-'A'+10;
	else return -1;
}

static char a2i(char ch, char** src,int base,int* nump)
{
	char* p= *src;
	int num=0;
	int digit;
	while ((digit=a2d(ch))>=0) {
		if (digit>base) break;
		num=num*base+digit;
		ch=*p++;
	}
	*src=p;
	*nump=num;
	return ch;
}

static void putchw(void* putp,putcf putf,int n, char z, char* bf)
{
	char fc=z? '0' : ' ';
	char ch;
	char* p=bf;
	while (*p++ && n > 0)
		n--;
	while (n-- > 0) 
		//putf(putp,fc);
			// myzinsky:
			printchar(fc);
	while ((ch= *bf++))
		//putf(putp,ch);
			// myzinsky:
			printchar(ch);
}

void tfp_format(void* putp,putcf putf,char *fmt, va_list va)
{
	char bf[12];

	char ch;


	while ((ch=*(fmt++))) {
		if (ch!='%') 
			//putf(putp,ch);
			//stdout_putf(putp,ch);
			// myzinsky:
			printchar(ch);
		else {
			char lz=0;
#ifdef 	PRINTF_LONG_SUPPORT
			char lng=0;
#endif
			int w=0;
			ch=*(fmt++);
			if (ch=='0') {
				ch=*(fmt++);
				lz=1;
			}
			if (ch>='0' && ch<='9') {
				ch=a2i(ch,&fmt,10,&w);
			}
#ifdef 	PRINTF_LONG_SUPPORT
			if (ch=='l') {
				ch=*(fmt++);
				lng=1;
			}
#endif
			switch (ch) {
				case 0: 
					goto abort;
				case 'u' : {
#ifdef 	PRINTF_LONG_SUPPORT
						   if (lng)
							   uli2a(va_arg(va, unsigned long int),10,0,bf);
						   else
#endif
							   ui2a(va_arg(va, unsigned int),10,0,bf);
						   putchw(putp,putf,w,lz,bf);
						   break;
					   }
				case 'd' :  {
#ifdef 	PRINTF_LONG_SUPPORT
						    if (lng)
							    li2a(va_arg(va, unsigned long int),bf);
						    else
#endif
							    i2a(va_arg(va, int),bf);
						    putchw(putp,putf,w,lz,bf);
						    break;
					    }
				case 'x': case 'X' : 
#ifdef 	PRINTF_LONG_SUPPORT
					    if (lng)
						    uli2a(va_arg(va, unsigned long int),16,(ch=='X'),bf);
					    else
#endif
						    ui2a(va_arg(va, unsigned int),16,(ch=='X'),bf);
					    putchw(putp,putf,w,lz,bf);
					    break;
				case 'c' : 
					    //putf(putp,(char)(va_arg(va, int)));
					    // myzinsky:
					    printchar(ch);

					    break;
				case 's' : 
					    putchw(putp,putf,w,0,va_arg(va, char*));
					    break;
				case '%' :
					    //putf(putp,ch);
					    // myzinsky:
					    printchar(ch);
				default:
					    break;
			}
		}
	}
abort:;
}


void init_printf(void* putp,void (*putf) (void*,char))
{
	stdout_putf=putf;
	stdout_putp=putp;
}

void tfp_printf(char *fmt, ...)
{
	va_list va;
	va_start(va,fmt);
	tfp_format(stdout_putp,stdout_putf,fmt,va);
	va_end(va);
}

static void putcp(void* p,char c)
{
	*(*((char**)p))++ = c;
}



void tfp_sprintf(char* s,char *fmt, ...)
{
	va_list va;
	va_start(va,fmt);
	tfp_format(&s,putcp,fmt,va);
	putcp(&s,0);
	va_end(va);
}




