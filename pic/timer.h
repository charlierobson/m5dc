// 16 bit timer, good for times < 800ms
void timerInit(int milliseconds);
int timerExpired();

// 32 bit timer, good foe aeons
void timer32Init(int milliseconds);
int timer32Expired();
