#include <plib.h>
#include <hardwareprofile.h>

// only for times < 800ms
void timerInit(int milliseconds)
{
	int period = GetPeripheralClock() / 256 / 1000 * milliseconds;

 	OpenTimer1(T1_ON | T1_IDLE_CON | T1_PS_1_256 | T1_SOURCE_INT, period);
 	mT1ClearIntFlag();
}

int timerExpired()
{
	return mT1GetIntFlag();
}



// 32 bit timer
void timer32Init(int milliseconds)
{
	int period = GetPeripheralClock() / 256 / 1000 * milliseconds;

 	OpenTimer23(T23_ON | T23_IDLE_CON | T23_PS_1_256 | T1_SOURCE_INT, period);
 	mT23ClearIntFlag();
}

int timer32Expired()
{
	return mT23GetIntFlag();
}
