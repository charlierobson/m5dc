/// Hardware V0.1

/********************************************************************
 FileName:      HardwareProfile.h
 Dependencies:  See INCLUDES section
 Processor:     PIC32
 Hardware:      The code is natively intended to be used on the 
                  following hardware platforms: 
                  Explorer 16
                  USB Starter Kit
                  Ethernet Starter Kit
                  The firmware may be modified for use on other 
                  platforms by editing this file (HardwareProfile.h)
 Compiler:  	Microchip C32 (for PIC32)
 Company:       Microchip Technology, Inc.

 Software License Agreement:

 The software supplied herewith by Microchip Technology Incorporated
 (the �Company�) for its PIC� Microcontroller is intended and
 supplied to you, the Company�s customer, for use solely and
 exclusively on Microchip PIC Microcontroller products. The
 software is owned by the Company and/or its supplier, and is
 protected under applicable copyright laws. All rights are reserved.
 Any use in violation of the foregoing restrictions may subject the
 user to criminal sanctions under applicable laws, as well as to
 civil liability for the breach of the terms and conditions of this
 license.

 THIS SOFTWARE IS PROVIDED IN AN �AS IS� CONDITION. NO WARRANTIES,
 WHETHER EXPRESS, IMPLIED OR STATUTORY, INCLUDING, BUT NOT LIMITED
 TO, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE APPLY TO THIS SOFTWARE. THE COMPANY SHALL NOT,
 IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL OR
 CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.

********************************************************************/

#ifndef HARDWARE_PROFILE_H
#define HARDWARE_PROFILE_H

#define __PIC32MX1XX_2XX__

// Maximum System frequency of 40MHz for PIC32MX1xx and PIC32MX2xx devices.
#define SYS_FREQ (40000000L)

// Common macros 
// Clock frequency values
// These directly influence timed events using the Tick module.  They also are used for UART and SPI baud rate generation.
#define GetSystemClock()		SYS_FREQ			// Hz
#define GetInstructionClock()	GetSystemClock()	// 
#define GetPeripheralClock()	GetSystemClock()	// Divisor is dependent on the value of FPBDIV set(configuration bits).

#define InitPPS() \
			PPSInput(3, SDI2, RPB13);\
			PPSOutput(2, RPB11, SDO2);\
			PPSOutput(4, RPB10, SS2);\
			PPSOutput(4, RPB9,  U2TX);

// Serial
//
#define BaudRate 9600
#define UARTNUM UART2

#define FATFS_SPI_START_CFG_1_0		(PRI_PRESCAL_64_1 | SEC_PRESCAL_8_1 | MASTER_ENABLE_ON | SPI_CKE_ON)
#define FATFS_SPI_START_CFG_1_1		(PRI_PRESCAL_64_1 | SEC_PRESCAL_8_1 | MASTER_ENABLE_ON | SPI_CKE_ON | SPI_SMP_ON)
#define FATFS_SPI_START_CFG_2		(SPI_ENABLE)

// LEDs are active low

#define LED_RED BIT_1
#define LED_RED_LAT LATBbits.LATB1
#define LED_RED_ON {LED_RED_LAT=0;}
#define LED_RED_OFF {LED_RED_LAT=1;}
#define LED_RED_SET(x) LED_RED_LAT=x
#define LED_RED_TOGGLE mPORTBToggleBits(LED_RED)

#define LED_WHITE BIT_2
#define LED_WHITE_LAT LATBbits.LATB2
#define LED_WHITE_ON {LED_WHITE_LAT=0;}
#define LED_WHITE_OFF {LED_WHITE_LAT=1;}
#define LED_WHITE_SET(x) LED_WHITE_LAT=x
#define LED_WHITE_TOGGLE mPORTBToggleBits(LED_WHITE)

#define LED_BLUE BIT_3
#define LED_BLUE_LAT LATBbits.LATB3
#define LED_BLUE_ON {LED_BLUE_LAT=0;}
#define LED_BLUE_OFF {LED_BLUE_LAT=1;}
#define LED_BLUE_SET(x) LED_BLUE_LAT=x
#define LED_BLUE_TOGGLE mPORTBToggleBits(LED_BLUE)

#define InitLEDPins()\
 			mPORTBSetBits(LED_RED|LED_WHITE|LED_BLUE);\
			mPORTBSetPinsDigitalOut(LED_RED|LED_WHITE|LED_BLUE);

#define AllLEDsOff() mPORTBSetBits(LED_RED|LED_WHITE|LED_BLUE);
#define AllLEDsOn() mPORTBClearBits(LED_RED|LED_WHITE|LED_BLUE);

// JTAG

#define InitJTAGPins_Ready()\
	mPORTASetPinsDigitalOut(JTAG_TDI | JTAG_TCK | JTAG_TMS);\
	mPORTBSetPinsDigitalIn(JTAG_TDO);

#define InitJTAGPins_Off()\
	mPORTASetPinsDigitalIn(JTAG_TDI | JTAG_TCK | JTAG_TMS);\
	mPORTBSetPinsDigitalIn(JTAG_TDO);



#ifdef HARDWARE01
	
	// Parallel port - PORTB
	//
	#define PP_READ_BIT BIT_7
	#define PP_WRITE_BIT BIT_6
	#define PP_STATUS_BIT BIT_5
	
	// SPI configuration defines
	//
	#define SD_SS_BIT BIT_10
	#define SD_SELECT() mPORTBClearBits(BIT_10);
	#define SD_DESELECT() mPORTBSetBits(BIT_10);
	
	// Card detect & write protect
	#define SD_WE_BIT BIT_14               
	#define SD_WE (mPORTBReadBits(SD_WE_BIT))               
	
	#define SD_CD_BIT BIT_12
	#define SD_CD (mPORTBReadBits(SD_CD_BIT))
	
	#define InitSDPins()\
				mPORTBSetPinsDigitalOut(SD_SS_BIT);\
	 			mPORTBSetPinsDigitalIn(SD_WE_BIT|SD_CD_BIT);
	
	// Serial
	#define InitSerialPins()\
				mPORTBSetPinsDigitalOut(BIT_9);\
				mPORTBSetPinsDigitalIn(BIT_8);

	// JTAG
	// portb
	#define JTAG_TDO BIT_0
	// porta
	#define JTAG_TCK BIT_8
	#define JTAG_TMS BIT_4
	#define JTAG_TDI BIT_9

	#define InitPPS_Special()\
			PPSInput(2, U2RX, RPB8);

	#endif // HARDWARE01



#ifdef HARDWARE03

	// Parallel port - PORTB
	//
	#define PP_READ_BIT BIT_8
	#define PP_WRITE_BIT BIT_7
	#define PP_STATUS_BIT BIT_6
	
	// SPI configuration defines
	//
	#define SD_SELECT() mPORTAClearBits(BIT_0);
	#define SD_DESELECT() mPORTASetBits(BIT_0);
	
	// Card detect & write protect
	#define SD_WE_BIT BIT_8
	#define SD_WE (mPORTCReadBits(SD_WE_BIT))
	
	#define SD_CD_BIT BIT_9
	#define SD_CD (mPORTCReadBits(SD_CD_BIT))
	
	#define InitSDPins()\
				mPORTASetPinsDigitalOut(BIT_0);\
				mPORTCSetPinsDigitalIn(SD_WE_BIT|SD_CD_BIT);
	
	// Serial
	#define InitSerialPins()\
				mPORTBSetPinsDigitalOut(BIT_9);\
				mPORTASetPinsDigitalIn(BIT_1);

	// JTAG
	// portb
	#define JTAG_TDO BIT_4
	// porta
	#define JTAG_TCK BIT_3
	#define JTAG_TMS BIT_4
	#define JTAG_TDI BIT_2

	// SWITCHED TO OUTPUT ONLY WHEN NEEDED
	#define InitJTAGPins_Ready()\
		mPORTASetPinsDigitalOut(JTAG_TDI | JTAG_TCK | JTAG_TMS);\
		mPORTBSetPinsDigitalIn(JTAG_TDO);

	#define InitJTAGPins_Off()\
		mPORTASetPinsDigitalIn(JTAG_TDI | JTAG_TCK | JTAG_TMS);\
		mPORTBSetPinsDigitalIn(JTAG_TDO);

	#define InitPPS_Special()\
			PPSInput(2, U2RX, RPA1);
				
#endif // HARDWARE03

#endif  //HARDWARE_PROFILE_H
