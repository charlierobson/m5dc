#include "configfile.h"
#include "ff.h"
#include "serial.h"

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

config_t config;


extern char ioBuffer[512];


char pool[512];
char* poolPtr;

extern FIL userFile;

extern void strupper(char*);
extern FRESULT openFile(FIL* file, char* filename, BYTE mode);


// pull a name/value pair from a whitespace delimited list.
// no spaces allowed.
//
char* getValue(char *input, char **paramName, char **paramValue)
{
	int count;

	if (input == NULL || *input == 0 || paramName == NULL || paramValue == NULL)
	{
		return NULL;
	}

	// advance paramName until a non-whitespace character or end of data is found
	while(*input && *input < 33)
	{
		++input;
	}

	// end of data?
	if (*input == 0)
	{
		return NULL;
	}

	// probably the start of the parameter name
	*paramName = input;
	count = 0;

	// advance until delimiter or end of line is found
	while(*input > 32 && *input != '=')
	{
		++input;
		++count;
	}

	// line only valid if it contains an '='
	if (count == 0 || *input != '=')
	{
		return NULL;
	}

	// advance to (hopefully) the first character of the value
	++input;

	*paramValue = input;
	count = 0;

	while (*input > 32)
	{
		++input;
		++count;
	}

	if (count == 0)
	{
		return NULL;
	}

	// terminate the name and values
	*((*paramValue)-1) = 0;

	// if there are further characters to process then terminate the value,
	// and point past it.
	if (*input)
	{
		*input = 0;
		++input;
	}

	return input;
}




int loadConfig()
{
	int error;

	// if the config file is missing or otherwise corrupt, we'll enable serial debugging
	memset((void*)&config, 0, sizeof(config_t));
	config.flags = 0x40;

 	error = openFile(&userFile, "config.ini", FA_READ);
	if (!error)
	{
		UINT numRead;
		char* p = ioBuffer;
		char *paramName, *paramValue;

		f_read(&userFile, ioBuffer, 512, &numRead);

		error = numRead >= 512;
		if (!error)
		{
			poolPtr = pool;

			ioBuffer[numRead] = 0;
			strupper(ioBuffer);

			// the config structure holds pointers to variably sized strings.
			// This is necessary to be able to cope with variable path lengths for the images...
			config.imageNames[IMGNAME_DEFAULT2] = "DEFAULT2.DSK";
			config.imageNames[IMGNAME_DEFAULT3] = "DEFAULT3.DSK";
			config.imageNames[IMGNAME_BOOTCODE] = "BOOT.BIN";
			config.imageNames[IMGNAME_DOS] = "DOS250.BIN";
			config.flags = 0;

			while ((p = getValue(p, &paramName, &paramValue)) != NULL)
			{
				int copy = FALSE;

				Serial_print(paramName);
				Serial_print(" : ");
				Serial_printLine(paramValue);

				if (strcmp(paramName, "DEFAULT2") == 0)
				{
					config.imageNames[IMGNAME_DEFAULT2] = poolPtr;
					copy = TRUE;
				}
				else if (strcmp(paramName, "DEFAULT3") == 0)
				{
					config.imageNames[IMGNAME_DEFAULT3] = poolPtr;
					copy = TRUE;
				}
				else if (strcmp(paramName, "BOOTIMG") == 0)
				{
					config.imageNames[IMGNAME_BOOTCODE] = poolPtr;
					copy = TRUE;
				}
				else if (strcmp(paramName, "DOSIMG") == 0)
				{
					config.imageNames[IMGNAME_DOS] = poolPtr;
					copy = TRUE;
				}
				else if (strcmp(paramName, "FLAGS") == 0)
				{
					config.flags = strtol(paramValue, NULL, 0);
				}

				if (copy)
				{
					strcpy(poolPtr, paramValue);
					poolPtr += strlen(poolPtr) + 1;
				}
			}
		}
	}

	return error;
}



int saveConfig()
{
	UINT len;
	UINT numWritten;

	int error;

	sprintf(ioBuffer, "default2=%s\r\ndefault3=%s\r\nbootimg=%s\r\ndosimg=%s\r\nflags=0x%02x\r\n", 
		config.imageNames[IMGNAME_DEFAULT2], config.imageNames[IMGNAME_DEFAULT3],
		config.imageNames[IMGNAME_BOOTCODE], config.imageNames[IMGNAME_DOS], config.flags);

	len = strlen(ioBuffer);
	error = openFile(&userFile, "config.ini", FA_WRITE);
	if (!error)
	{
		error = f_write(&userFile, ioBuffer, len, &numWritten);
		f_close(&userFile);
	}
	return error;
}
