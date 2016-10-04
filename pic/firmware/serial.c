#include "compiler.h"
#include <stdarg.h>

#include <hardwareprofile.h>
#include "serial.h"

void Serial_printCharImpl(char acter)
{
	while(!UARTTransmitterIsReady(UARTNUM)); 
	UARTSendDataByte(UARTNUM, acter);
} 

void Serial_NLImpl()
{
	Serial_printCharImpl('\r'); 
	Serial_printCharImpl('\n'); 
}

char pfbuffer[256];
void Serial_printfImpl(char* format, ...)
{
	va_list valist;
    va_start(valist,format);
    vsprintf(pfbuffer,format,valist);
    va_end(valist);
    Serial_printImpl(pfbuffer);
}

void Serial_printImpl(char *buffer)
{
	while(*buffer != (char)0) 
	{
		Serial_printCharImpl(*buffer);
		++buffer;
	}
} 

void Serial_printLineImpl(char *buffer)
{
	Serial_printImpl(buffer);
	Serial_NLImpl();
}

void Serial_VT100Impl(char* buffer)
{
	Serial_printCharImpl(27);
	Serial_printCharImpl('[');
	Serial_printImpl(buffer);
}

void Serial_printBinImpl(unsigned char data)
{
	char i;
	for(i = 0; i < 8; ++i)
	{
		Serial_printCharImpl(data & 0x80 ? '1' : '0');
		data <<= 1;
	}
}

void Serial_printBin16Impl(unsigned short data)
{
	char i;
	for(i = 0; i < 16; ++i)
	{
		Serial_printCharImpl(data & 0x8000 ? '1' : '0');
		data <<= 1;
	}
}

void Serial_printHexImpl(unsigned char data)
{
	Serial_printCharImpl("0123456789ABCDEF"[(data & 0xf0) >> 4]);
	Serial_printCharImpl("0123456789ABCDEF"[ data & 0x0f]);
}

void Serial_printHex16Impl(unsigned short data)
{
	Serial_printCharImpl("0123456789ABCDEF"[(data & 0xf000) >> 12]);
	Serial_printCharImpl("0123456789ABCDEF"[(data & 0x0f00) >> 8]);
	Serial_printCharImpl("0123456789ABCDEF"[(data & 0x00f0) >> 4]);
	Serial_printCharImpl("0123456789ABCDEF"[ data & 0x000f]);
}
