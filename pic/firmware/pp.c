#include "compiler.h"
#include <hardwareprofile.h>
#include "pp.h"



void InitPP()
{
	mPORTBSetPinsDigitalOut(PP_READ_BIT|PP_WRITE_BIT|PP_STATUS_BIT);
	mPORTBClearBits(PP_READ_BIT|PP_WRITE_BIT|PP_STATUS_BIT);

	PPRead();
	PPStatusWrite(0);
	mPORTCSetPinsDigitalIn(0xff);
}

unsigned char PPStatusRead()
{
	unsigned char status;

	mPORTCSetPinsDigitalIn(0xff);

	mPORTBSetBits(PP_STATUS_BIT|PP_READ_BIT);
	asm("nop");
	status = PORTRead(IOPORT_C);
	mPORTBClearBits(PP_STATUS_BIT|PP_READ_BIT);

	return status;
}

void PPStatusWrite(unsigned char status)
{
	mPORTCSetPinsDigitalOut(0xff);

	mPORTCWrite(status);
	mPORTBSetBits(PP_STATUS_BIT|PP_WRITE_BIT);
	asm("nop");
	mPORTBClearBits(PP_STATUS_BIT|PP_WRITE_BIT);
}

unsigned char PPRead()
{
	unsigned char data;

	mPORTCSetPinsDigitalIn(0xff);

	mPORTBSetBits(PP_READ_BIT);
	asm("nop");
	data = PORTRead(IOPORT_C);
	mPORTBClearBits(PP_READ_BIT);

	return data;
}

void PPWrite(unsigned char data)
{
	mPORTCSetPinsDigitalOut(0xff);

	mPORTCWrite(data);
	mPORTBSetBits(PP_WRITE_BIT);
	asm("nop");
	mPORTBClearBits(PP_WRITE_BIT);
}
