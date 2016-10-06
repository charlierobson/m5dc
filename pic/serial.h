#include "configfile.h"
extern config_t config;

void Serial_printCharImpl(char);
void Serial_NLImpl(void);
void Serial_printImpl(char*);
void Serial_printfImpl(char*,...);
void Serial_printLineImpl(char*);
void Serial_VT100Impl(char*);
void Serial_printHexImpl(BYTE);
void Serial_printHex16Impl(WORD);
void Serial_printBinImpl(BYTE);
void Serial_printBin16Impl(WORD);

#ifdef WANT_SERIAL

#define Serial_printChar Serial_printCharImpl
#define Serial_NL Serial_NLImpl
#define Serial_print Serial_printImpl
#define Serial_printf Serial_printfImpl
#define Serial_printLine Serial_printLineImpl
#define Serial_VT100 Serial_VT100Impl
#define Serial_printHex Serial_printHexImpl
#define Serial_printHex16 Serial_printHex16Impl
#define Serial_printBin Serial_printBinImpl
#define Serial_printBin16 Serial_printBin16Impl

#else

#define Serial_printChar(x)
#define Serial_NL()
#define Serial_print(x)
#define Serial_printf //
#define Serial_printLine(x)
#define Serial_VT100(x)
#define Serial_printHex(x)
#define Serial_printHex16(x)
#define Serial_printBin(x)
#define Serial_printBin16(x)

#endif


#define DBC(x) Serial_printChar(x);
