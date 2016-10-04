#include "command.h"
#include "pp.h"

extern int bi;

int processCommand(unsigned int command)
{
	int mode = MODE_INPUT;
	unsigned int statusReturn = 0;

	switch (command)
	{
		case CMD_RESETBUFFER:
			bi = 0;
			goto acknowledge;

		case CMD_BUFFERREAD:
			mode = MODE_OUTPUT;
			goto acknowledge;

		case CMD_CHDIR:
			goto acknowledge;

		case CMD_OPEN_DIR:
			goto acknowledge;

		case CMD_READ_DIR:
			goto acknowledge;

		case CMD_FILE_OPEN:
			goto acknowledge;

		case CMD_FILE_READ:
			goto acknowledge;

		case CMD_FILE_WRITE:
			goto acknowledge;
	}

acknowledge:
	PPWrite(statusReturn);
	return mode;
}
