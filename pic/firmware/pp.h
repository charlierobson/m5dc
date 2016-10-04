// CPLD parallel port implementation

extern void InitPP();

extern unsigned char PPStatusRead();
extern void PPStatusWrite(unsigned char data);

extern unsigned char PPRead();
extern void PPWrite(unsigned char data);

extern void PPWaitInputBufferFull();
extern void PPWaitOutputBufferEmpty();

#define PPSTAT_CLIENT_READY 0

// status bit mask = 1 means data is present & unread
static const unsigned char PPSTAT_HOST_BUFFER_FULL = 1;
static const unsigned char PPSTAT_CLIENT_BUFFER_FULL = 2;
static const unsigned char PPSTAT_COMMAND = 4;
