#include <plib.h>
#include <ctype.h>

#include "ff.h"
#include "command.h"
#include "serial.h"


DIR dir;
FILINFO dirFile;

extern char ioBuffer[];
extern char* bp;
extern int mode;


int dirState;

// all params to dprintf must be on the same line
#define DPRINTF Serial_printf
//#define DPRINTF //

void strupper(char* dest)
{
	while(*dest)
	{
		*dest = toupper(*dest);
		++dest;
	}
}

void strvalidate(char* p)
{
	char* p2 = p;
	while(*p2)
	{
		unsigned char q = *p2 - 32;
		if (q > 96)
		{
			*p2 = '?';
		}
		++p2;
	}
	strupper(p);
}


void copyNameNormal(char* dest, char*src)
{
	strcpy(dest, src);
}


void copyNameFancy(char* q /*dest*/, char* p /*src*/)
{
	int nc = 0;
	int df = 0;

	if(dirFile.fattrib & AM_RDO)
	{
		*q = '*';
	}
	else
	{
		*q = ' ';
	}

	++q;

	while (*p)
	{
		if (*p == '.')
		{
			df = 1;
			if (nc < 8)
			{
				*q = ' ';
				++q;
				++nc;
				continue;
			}
		}

		if (!df && nc == 8)
		{
			++p;
			continue;
		}

		*q = toupper(*p);
		++nc;
		++p;
		++q;
		if (nc == 12)
		{
			break;
		}
	}

	while(nc < 12)
	{
		*q = 32;
		++nc;
		++q;
	}
	*q = 0;
}

int dirHandler()
{
	int rtn = FR_OK;
	int switchState;

	do	
	{
		switchState = 0;

		switch(dirState)
		{
		case 0:
			{
				int n;

				// new search
				rtn = f_opendir(&dir, ioBuffer + 450);

				DPRINTF("state 0 - new search. opendir returned %d\r\n", rtn);

				// put the full search path in the buffer
				f_getcwd(ioBuffer, 450);
				if (ioBuffer[450])
				{
					n = strlen(ioBuffer);
					if (ioBuffer[n-1] != '/')
					{
						strcat(ioBuffer, "/");
					}
					strcat(ioBuffer, ioBuffer + 450);
				}	
				Serial_print(ioBuffer);
				dirState = 1;

				strvalidate(ioBuffer);
				mode = MODE_OUTPUT;
				bp = ioBuffer;
			}
			break;

		case 1:
			{
				// reading directories
				rtn = f_readdir(&dir, &dirFile);

				DPRINTF("state 1 - reading dirs. readdir returned %d\r\n", rtn);

				if (rtn) return rtn;

				if (dirFile.fname[0] == 0)
				{
					DPRINTF("1 done.\r\n");

					// done dirs
					switchState = TRUE;
					dirState = 2;
					break;
				}
				else
				{
					if (dirFile.fattrib & AM_DIR)
					{
						ioBuffer[0] = '<';
						strcpy(ioBuffer+1, &dirFile.fname[0]);
						strcat(ioBuffer, ">");

						strvalidate(ioBuffer);
						mode = MODE_OUTPUT;
						bp = ioBuffer;
					}
					else
					{
						// go around one more time
						switchState = TRUE;
					}
				}
			}
			break;

		case 2:
			{
				// new search
				rtn = f_opendir(&dir, ioBuffer + 450);
				DPRINTF("state 2 - new search. opendir returned %d\r\n", rtn);
				switchState = TRUE;
				dirState = 3;
			}
			break;	

		case 3:
			{
				// reading files out of the structure
				rtn = f_readdir(&dir, &dirFile);
				DPRINTF("state 3 - reading files. readdir returned %d\r\n", rtn);
				if (rtn) return rtn;

				if (dirFile.fname[0] == 0)
				{
					DPRINTF("3 done.\r\n");
					// finished
					rtn = 0x40;
					break;
				}
				else
				{
					if ((dirFile.fattrib & AM_DIR) == 0)
					{
						memset(ioBuffer, 0, 32);

						//copyNameFancy(ioBuffer, &dirFile.fname[0]);
						copyNameNormal(ioBuffer, &dirFile.fname[0]);

						if (dirFile.fsize < 1024)
						{
							sprintf(ioBuffer+14, "% 5db", (int)dirFile.fsize);
						}
						else
						{
							int fsize = (dirFile.fsize + 1023) / 1024;
							sprintf(ioBuffer+14, "% 5dK", fsize);
						}

						strvalidate(ioBuffer);

						mode = MODE_OUTPUT;
						bp = ioBuffer;
					}
					else
					{
						// go around one more time
						switchState = TRUE;
					}
				}
			}
			break;
		}
	}
	while (switchState);

	return rtn;
}	

int dirBegin()
{
	dirState = 0;
	return dirHandler();
}

