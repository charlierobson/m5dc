/*

--== einSDein ==--

Tatung Einstein SD card interface

2013 SirMorris

PIC32MX130
XILINX XC9572XL

0.3 hardware

TODO
----

-FIRMWARE-

why does the board reset every now and then of its own accord?

boot loader

blank disk creator - from fresh or from template?

test cpld programmer

interrupt on change for card insertion/removal - will also update WP status

mCNOpen(unsigned int control, unsigned int pins, unsigned int pullup)

If the disk I/O layer does not detect media change, application program needs to perform f_mount() every media change.

size reporting for open etc, remove 64k limit
file write mode disposition control

FILE_READ_SECTOR needs FILE_WRITE_SECTOR,
FILE_WRITE needs a FILE_READ

detect incompatible DOS when loading img file?

support RAW disk image files?

set default image / last image  - save to nvmem

sort out friendly behaviour when NODISK etc

test MCAL reporter - print info about mcals


-ROM-

support 2/3 SD drives???
test MCAL reporting

auto boot to 3:
ensure drive params are correct,
use more accurate sector out of range detection
get drive params from interface - tracks, sectors, sides etc


-TRANSIENT-

DIR - 
 same format as regular dir
 display path correctly - append passed path to cwd, canonicalise??
 
COPY - 
 ability to copy from/to SD card using s: as sd card drive? or 4: ?

makedisk - initiate creation of a disk on the card

*/


#include <compiler.h>
#include <string.h>
#include <plib.h>
#include <hardwareprofile.h>
#include <config.h>
#include <ctype.h>

#include "ff.h"
#include "pp.h"
#include "command.h"
#include "serial.h"
#include "timer.h"
#include "dsk.h"
#include "diskio.h"
#include "configfile.h"
#include "xilinx\micro.h"




int mode;

FATFS fatfs;

FIL userFile;
FILINFO filInfo;

extern const char* errmsgs[];

extern config_t config;

short so1[40*10]; // todo - eliminate this ((ab)used by xilinx code)
void* tp = (void*)so1;

char ioBuffer[512];
char* bp = ioBuffer;

void inline einSDein(void);

void activityLight(int state)
{
	// LEDs are active low, remember
	LED_BLUE_SET(1-state);
}


void delayUs(unsigned int us)
{
	unsigned int tWait = ( GetSystemClock() / 2000000 ) * us;
	unsigned int tStart = ReadCoreTimer();
	while((ReadCoreTimer() - tStart)< tWait);
} 

void delayMs(unsigned int ms)
{
	unsigned int tWait = ( GetSystemClock() / 2000 ) * ms;
	unsigned int tStart = ReadCoreTimer();
	while( ( ReadCoreTimer() - tStart ) < tWait );
}



 
void report (char* buffer, unsigned int data)
{
	Serial_print(buffer);
	Serial_printHex(data);
	Serial_NL();
}

int reportOKFail(int result)
{
	// read
	result &= 0x7f;
	if (result)
	{
		strcpy(ioBuffer, errmsgs[result]);	// returned to client

		Serial_printf(" - failed: %d: %s\r\n", result, &ioBuffer[0]); //*t*r9*

		bp = ioBuffer;
		mode = MODE_OUTPUT;
		return result | 0x80;
	}

	Serial_printLine(" - OK.");
	return 0;
}

int reportError(const char* message)
{
	strcpy(ioBuffer, message);	// returned to client
	bp = ioBuffer;
	mode = MODE_OUTPUT;
	return 0x81;
}

void reportInput(char* buffer)
{
	Serial_print(buffer);
	Serial_print(" - \"");
	Serial_print(ioBuffer);
	Serial_print("\" ");
}

void hexLabel(char* lbl, int sixteen)
{
	Serial_print(lbl);
	Serial_printChar(' ');
	Serial_printHex(*bp);
	++bp;
	if (sixteen)
	{
		Serial_printHex(*bp);
		++bp;
	}
	Serial_printChar(' ');
}	


UINT bytesInBuf;

FRESULT beginReadSVF(const char* filename)
{
	FRESULT err = FR_NO_FILE;

	bytesInBuf = 0;

	// files ready for burning need to have their archive bit set.
	// it will be cleared once burning has been attempted
	//
	err = f_stat(filename, &filInfo);
	if (!err && (filInfo.fattrib & AM_ARC))
	{
		err = f_open(&userFile, filename, FA_READ);
		if (err == FR_OK)
		{
			Serial_print("Programming CPLD");

			InitJTAGPins_Ready();

			LED_WHITE_ON;

			err = xsvfExecute();
			if (err != XSVF_ERROR_NONE)
			{
				err += DSK_LAST - 1;
			}
			reportOKFail(err);

			LED_WHITE_OFF;

			InitJTAGPins_Off();
		}
	}

	LED_BLUE_OFF;

	userFile.fs = NULL;
	return err;
}

void readByte(unsigned char *data)
{
	static int counter = 0;

	if (bytesInBuf == 0)
	{
		++counter;

		LED_BLUE_LAT = (counter & 64) == 0;

		f_read(&userFile, ioBuffer, 512, &bytesInBuf);
		bp = ioBuffer;
	}
	*data = *bp;

	--bytesInBuf;
	++bp;
}	


FRESULT openFile(FIL* file, char* filename, BYTE mode)
{
	FRESULT error;

	if (file->fs)
	{
		f_close(file);
		file->fs = NULL;
	}

	error = f_open(file, filename, mode);
	if (error)
	{
		file->fs = NULL;
	}

	return error;
}




void __ISR(_CHANGE_NOTICE_VECTOR, ipl2) ChangeNotice_Handler(void)
{
	mPORTBRead();
	IFS1CLR = 0x4000; //CLEAR CNB Interrupt FLAG
	IFS0CLR = 0x0008; //CLEAR External Interrupt FLAG 

	disk_status(0);
	LED_RED_ON;
}



FIL destFile;

FRESULT copyFile(char* inName, char* outName)
{
	int error;
	UINT numRead, numWritten = 0;

	error = openFile(&userFile, inName, FA_READ);
	if (error) return error;

	error = openFile(&destFile, outName, FA_WRITE|FA_CREATE_ALWAYS);
	if (error)
	{
		f_close(&userFile);
		userFile.fs = NULL;
		return error;
	}

	do
	{
		f_read(&userFile, ioBuffer, 512, &numRead);
		if (numRead)
		{
			f_write(&destFile, ioBuffer, 512, &numRead);
			numWritten += numRead;
		}
	}
	while(numRead);

	f_close(&userFile);
	userFile.fs = NULL;
	f_close(&destFile);
	destFile.fs = NULL;

	return 0;
}

void Error()
{
	LED_RED_ON;
	while(1){}
}



void TestMode2()
{
	BYTE exit = 0;
	BYTE n = 0xaa;
	BYTE status = PPStatusRead();
	BYTE lastStatus = status;

	while(!exit)
	{
		status = PPStatusRead();
		if (status == lastStatus) continue;

		lastStatus = status;
		Serial_printHex(status);
		if ((status & PPSTAT_HOST_BUFFER_FULL) != 0)
		{
			BYTE dataFromHost = PPRead();
			if ((status & PPSTAT_COMMAND) != 0) 
			{
				if (dataFromHost == CMD_GO_TEST_MODE) exit = 1;

				LED_BLUE_TOGGLE;
				PPWrite(dataFromHost|128);
				PPStatusWrite(0);
			}
			LED_WHITE_TOGGLE;
		}
		else if ((status & PPSTAT_CLIENT_BUFFER_FULL) == 0)
		{
			n ^= 0xff;
			PPWrite(n);
			LED_RED_TOGGLE; // red is read
		}
	}
}

void TestMode3()
{
	BYTE exit = 0;
	BYTE status = PPStatusRead();
	BYTE lastStatus = status;

	while(!exit)
	{
		status = PPStatusRead();
		if (status == lastStatus) continue;

		if ((status & PPSTAT_HOST_BUFFER_FULL) != 0)
		{
			Serial_printHex(status);
			BYTE dataFromHost = PPRead();
			Serial_printHex(dataFromHost);
			status = PPStatusRead();
			Serial_printHex(status);
			PPStatusWrite(0);
			status = PPStatusRead();
			Serial_printHex(status);
			if ((status & PPSTAT_HOST_BUFFER_FULL) != 0)
			{
				LED_RED_ON;
			}
			Serial_NL();
		}
	}
}

void TestMode()
{
	BYTE exit = 0;
	BYTE n = 0xaa;
	BYTE status = PPStatusRead();
	BYTE lastStatus = status;

	PPWrite(n++);
	status = PPStatusRead();
	while(!exit)
	{
		status = PPStatusRead();
		if (status == lastStatus) continue;

		if ((status & PPSTAT_CLIENT_BUFFER_FULL) == 0)
		{
			Serial_printHex(status);
			PPWrite(n++);
			status = PPStatusRead();
			Serial_printHex(status);
			if ((status & PPSTAT_CLIENT_BUFFER_FULL) == 0)
			{
				LED_RED_ON;
			}
			Serial_NL();
		}

		lastStatus = status;
	}
}

extern unsigned char* testvector1;
extern unsigned short crc16_ccitt(const unsigned char *buf, int len, unsigned short crc);

int main(void)
{
	SYSTEMConfig(GetSystemClock(), SYS_CFG_WAIT_STATES | SYS_CFG_PCACHE);

	PPSUnLock;
		InitPPS();
		InitPPS_Special();
	PPSLock; 

	ANSELA = 0;
	ANSELB = 0;
	ANSELC = 0;

	InitPP();
	InitLEDPins();
	InitSerialPins();
	InitSDPins();
	InitJTAGPins_Off();

	UARTConfigure(UARTNUM, UART_ENABLE_PINS_TX_RX_ONLY); 
	UARTSetLineControl(UARTNUM, UART_DATA_SIZE_8_BITS | UART_PARITY_NONE | UART_STOP_BITS_1); 
	UARTSetDataRate(UARTNUM, GetPeripheralClock(), BaudRate); 
	UARTEnable(UARTNUM, UART_ENABLE_FLAGS(UART_PERIPHERAL | UART_TX));   

	Serial_printLineImpl("SD-X V0.91\r\n");
#ifndef WANT_SERIAL
	Serial_printLineImpl("<Silent>");
#endif

	userFile.fs = NULL;

	f_chdrive(0);
	if (f_mount(0, &fatfs) == 0)
	{
		Serial_printLineImpl("MOUNTED");
	}

	beginReadSVF("einsd03.svf");
	f_rename("einsd03.hex", "@einsd03.hex");
	f_rename("einsd03.svf", "@einsd03.svf");

	Serial_printLine("\r\nAway we go");

	if(0)
	{
		TestMode();
	}

	PPRead(); 			// clear buffer flag
	PPStatusWrite(0);	// clear command bit

	AllLEDsOff();

	mode = MODE_INPUT;

	while(1)
	{
		einSDein();
	}
}
