#include "ff.h"
#include "blobbyfile.h"
#include <setjmp.h>
#include "serial.h"

BYTE blobComplete;
BYTE blobFileType;
int blobbyLoadAddress;

jmp_buf context;

extern BYTE ioBuffer[512];

enum
{
	BFTYPE_SYSTEM,
	BFTYPE_BASIC
};

BYTE bbreadByte(FIL* userFile)
{
	UINT br;
	FRESULT result = f_read(userFile, &ioBuffer[511], 1, &br);
	if (result != FR_OK || br == 0) longjmp(context, result);
	return ioBuffer[511];
}

void bbreadBytes(FIL* userFile, BYTE* dest, int count)
{
	UINT br;
	FRESULT result = f_read(userFile, dest, count, &br);

	if (result != FR_OK) longjmp(context, result);
}

FRESULT GetBlobbyFileType(FIL* userFile, BYTE* blobType)
{
	FRESULT result;

	blobComplete = 0;
	blobFileType = 255;

	result = setjmp(context);
	if (FR_OK == result)
	{
		BYTE b;
		while((b = bbreadByte(userFile)) != 0xa5){;}

		b = bbreadByte(userFile);
		if (b == 0x55)
		{
			bbreadBytes(userFile, ioBuffer, 6);

			blobFileType = BFTYPE_SYSTEM;
			blobbyLoadAddress = 0x4300; // safe(ish) default load address
		}	
		else if (b == 0xd3)
		{
			bbreadBytes(userFile, ioBuffer, 2);

			if (ioBuffer[0] == 0xd3 && ioBuffer[1] == 0xd3)
			{
				blobFileType = BFTYPE_BASIC;
				blobbyLoadAddress = 0x42e9; // default BASIC load address
			}
		}
	}

	*blobType = blobFileType;
	return result;
}




int ReadBlob(FIL* userFile)
{
	FRESULT result;

	if (blobComplete == 1)
	 	return 0x40; // completed OK, no more blobs

	result = setjmp(context);
	if (FR_OK == result)
	{
		switch (blobFileType)
		{
			case BFTYPE_SYSTEM:
			{
				bbreadBytes(userFile, ioBuffer, 4);

				if (*ioBuffer == 0x3c)
				{
					int bsize = ioBuffer[1] ? ioBuffer[1] : 256;

					ioBuffer[0] = ioBuffer[1];	// size (bytes)
					ioBuffer[1] = ioBuffer[2];	// load address l
					ioBuffer[2] = ioBuffer[3];	// load address h

					// read payload + 1 to  account for checksum
					bbreadBytes(userFile, ioBuffer + 3, bsize + 1);
				}
				else if (*ioBuffer == 0x78)
				{
					ioBuffer[0] = 2;			// size (bytes)
					ioBuffer[3] = ioBuffer[1];	// payload - exec address l
					ioBuffer[4] = ioBuffer[2];	//           exec address h
					ioBuffer[1] = 0xdf;			// load address l
					ioBuffer[2] = 0x40;			// load address h

					Serial_printf("Complete - load address %02x%02x\r\n", ioBuffer[4],ioBuffer[3]);
					blobComplete = 1;
				}
				else
				{
					Serial_printf("Bad blob header: %02x\r\n", *ioBuffer);
					return BLOB_ERROR_UNEXPECTED;
				}
			}
			break;

			case BFTYPE_BASIC:
			{
				UINT br;

				result = f_read(userFile, ioBuffer + 3, 256, &br);
				if (result != FR_OK) return result;

				if (br != 0)
				{
					ioBuffer[0] = br & 255;
					ioBuffer[1] = blobbyLoadAddress & 255;
					ioBuffer[2] = blobbyLoadAddress / 256;
					blobbyLoadAddress += br;
				}
				else
				{
					ioBuffer[0] = 2;
					ioBuffer[1] = 0xdf;			// load address l
					ioBuffer[2] = 0x40;			// load address h
					ioBuffer[3] = 0x02;			// 0x3002 is 'BASIC fix-up' entry point
					ioBuffer[4] = 0x30;

					blobComplete = 1;
				}
			}
			break;

			default:
				return BLOB_ERROR_UNKNOWN_TYPE;
		}
	}

	return result;
}
