#ifndef WIN32
#include "einSDein.h"
#endif

#ifndef FR_DISK_ERROR
#define FR_DISK_ERROR 1
#endif

//
// Things to test on real einSDein hardware
//
// READ/WRITE for files - does the disposition work the way it's expected to?
// Is there an error returned by f_read if you attempt to read past EOF?

extern unsigned short crc16_ccitt(const unsigned char *buf, int len, unsigned short crc);

extern void TestMode();

MAINFN
{
	static int gfbytes;
	UINT numRead;
	BYTE status, data;

	status = PPStatusRead();
	if (status & PPSTAT_HOST_BUFFER_FULL)
	{
		// host has sent a byte.

		mode = MODE_INPUT;
		data = PPRead();

		if ((status & PPSTAT_COMMAND) == 0)
		{
			// byte was marked as data
			*bp = data;
			++bp;
		}
		else
		{
			// byte was marked as command

			Serial_printf("Command %d\r\n", data);

			BYTE error = 0;
			LED_WHITE_ON;

			switch(data)
			{
				case CMD_INTERFACE_DETECT:
					Serial_printLine("Detect");
					error = 0x42;
					break;

				case CMD_INTERFACE_STATUS:
				{
					Serial_printLine("Get status");

					error = disk_status(0);
					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				case CMD_INTERFACE_GETBOOTCODE:
					// only return boot code if there is a card and the boot flag is set
					Serial_print("Get boot code");
					error = disk_status(0) || (config.flags & 0x80) == 0x00 || config.imageNames[IMGNAME_BOOTCODE] == 0;
					if (!error)
					{
						error = openFile(&userFile, config.imageNames[IMGNAME_BOOTCODE], FA_READ);
						if (!error)
						{
							f_read(&userFile, ioBuffer, 512, &numRead);
						}
					}
					reportOKFail(error);
					mode = MODE_OUTPUT;
					bp = ioBuffer;
					break;

				case CMD_INTERFACE_GETDOS:
					// Open the dos code file; EXPOSE START END and EXEC
					Serial_print("Get dos");
					error = openFile(&userFile, config.imageNames[IMGNAME_DOS], FA_READ);
					if (!error)
					{
						error = f_read(&userFile, ioBuffer, 512, &numRead);
					}
					reportOKFail(error);
					mode = MODE_OUTPUT;
					bp = ioBuffer;
					break;

				case CMD_INTERFACE_GETVSN:
					strcpy(ioBuffer,"1.10");
					mode = MODE_OUTPUT;
					bp = ioBuffer;
					break;

					case CMD_BUFFER_PTR_RESET:
					//Serial_printLine("reset");
					bp = ioBuffer;
					break;

				// like buffer ptr reset, except buffer is pre-warmed with a 0 at index 0
				case CMD_BUFFER_FLUSH:
					//Serial_printLine("flush");
					bp = ioBuffer;
					*bp = 0;
					break;

				case CMD_BUFFER_READ:
					//Serial_printLine("read");
					mode = MODE_OUTPUT;
					bp = ioBuffer;
					break;

				case CMD_DIR_READ_BEGIN:
				{
					reportInput("Dir start");

					// preserve the pattern for when we start the search for files
					strcpy(ioBuffer + 450, ioBuffer);

					// begin!
					error = reportOKFail(dirBegin());
					// mode is set by dirfn
				}
				break;

				// get next dir entry
				case CMD_DIR_READ_NEXT:
				{
					error = dirHandler();

					Serial_print("Dir next ");
					Serial_printLine(ioBuffer);

					if ((error & 0x3f) == 0) break;
					error = reportOKFail(error);
					// mode is set by dirfn
				}
				break;

				case CMD_DIR_MKDIR:
				{
					reportInput("Make directory");
					error = reportOKFail(f_mkdir(ioBuffer));
				}
				break;

				case CMD_DIR_CHDIR:
				{
					reportInput("Change directory");
					error = reportOKFail(f_chdir(ioBuffer));
				}
				break;

				case CMD_DIR_GETCWD:
				{
					Serial_print("Get CWD");
					error = reportOKFail(f_getcwd(ioBuffer, 450));
					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				// open for reading
				case CMD_FILE_OPEN_READ:
				{
					gfbytes = 0;
					reportInput("File open read");
					reportOKFail(openFile(&userFile, ioBuffer, FA_READ)); break; }
					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				// open for reading
				case CMD_FILE_OPEN_READ_BLOBBY:
				{
					BYTE blobbyFileType = 255;

					reportInput("File open read Blobby");

					error = openFile(&userFile, ioBuffer, FA_READ);
					if (!error)
					{
						error = GetBlobbyFileType(&userFile, &blobbyFileType);
					}

					Serial_printf("\r\nbft: %d err: %d", blobbyFileType, error);

					error = reportOKFail(error);
					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				// open for writing - will truncate existing files
				case CMD_FILE_OPEN_WRITE:
					reportInput("File open write");

					error = reportOKFail(openFile(&userFile, ioBuffer, FA_WRITE|FA_CREATE_ALWAYS));
					if (error) break;

					f_lseek(&userFile, userFile.fsize);

					bp = ioBuffer;
					break;

				// read 512b from file
				case CMD_FILE_READ_512:
				{
					unsigned short crc;
					memset(ioBuffer, 0, 512);

					Serial_print("File read 512");
					error = reportOKFail(f_read(&userFile, ioBuffer, 512, &numRead));

					crc = crc16_ccitt((const unsigned char*)ioBuffer, 512, -1);
					Serial_printf("  crc=%04x\r\n", crc);
					if (gfbytes < 1024)
					{
						int i;
						for(i = 0; i < 256; ++i)
						{
							Serial_printHex(ioBuffer[i]);
							if ((i & 15)==15) Serial_NL();
						}
					}
					gfbytes += 512;

					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				case CMD_FILE_READ_BLOB:
				{
					error = ReadBlob(&userFile);
					if (error != 0x40) error = reportOKFail(error);

					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				case CMD_FILE_READ_256:
				{
					Serial_print("File read 256");

					error = reportOKFail(f_read(&userFile, ioBuffer, 256, &numRead));

					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				case CMD_FILE_WRITE:
				{
					int bufferSize = bp - ioBuffer;

					Serial_print("File write: (0x");
					Serial_printHex(bufferSize);
					Serial_print("b) ");

					UINT numWrit;
					error = reportOKFail(f_write(&userFile, ioBuffer, bufferSize, &numWrit));
					f_sync(&userFile);

					bp = ioBuffer;
				}
				break;

				// rename a file
				case CMD_FILE_RENAME:
				{
					char* toName = ioBuffer + strlen(ioBuffer) + 1;

					Serial_print("File rename: \"");
					Serial_print(ioBuffer);
					Serial_printLine("\" to ");
					Serial_print(toName);
					Serial_printLine("\" - ");

					error = reportOKFail(f_rename(ioBuffer, toName));
				}
				break;

				// delete a file
				case CMD_FILE_DELETE:
				{
					reportInput("File delete");

					error = reportOKFail(f_unlink(ioBuffer));
				}
				break;

				// duplicate a file
				case CMD_FILE_COPY:
				{
					Serial_print("File copy: \"");
					char* toFile = ioBuffer + strlen(ioBuffer) + 1;

					Serial_print(ioBuffer);
					Serial_print("\" to \"");
					Serial_print(toFile);
					Serial_printLine("\" - ");

					error = copyFile(ioBuffer, toFile);
					Serial_printLine(":(");
					error = reportOKFail(error);
				}
				break;

				// close the file
				case CMD_FILE_CLOSE:
				{
					Serial_print("File close");

					error = reportOKFail(f_close(&userFile));
					userFile.fs = NULL;
				}
				break;

				case CMD_DBG_HUSH:
				{
					Serial_printImpl(ioBuffer);

					if ((*ioBuffer | 32)== 'y')
					{
						config.flags &= ~0x40;
					}
					if ((*ioBuffer | 32)== 'n')
					{
						config.flags |= 0x40;
					}
					Serial_printHexImpl(config.flags);
				}
				break;

				case CMD_DBG_DCHAR:
				{
					--bp;
					Serial_printChar('[');
					Serial_printChar(*bp);
					Serial_printChar(']');
				}
				break;

				case CMD_DBG_LED:
				{
					// CAREFUL HERE! Ensure that either the LED macros are a single instruction
					//  or that they're bracketted..
					//
					char x = *bp;
					if (x & 1) LED_RED_ON else LED_RED_OFF
					x >>= 1;
					if (x & 1) LED_WHITE_ON else LED_WHITE_OFF
					x >>= 1;
					if (x & 1) LED_BLUE_ON else LED_BLUE_OFF
				}
				break;

				case CMD_DBG_HEX8:
				{
					bp = ioBuffer;
					Serial_printHex(*bp);
				}
				break;

				case CMD_DBG_HEX16:
				{
					Serial_printf("CMD_DBG_HEX16: %02x%02x\r\n", *(bp-2), *(bp-1));
				}
				break;

				case CMD_DBG_REGS:
				{
					bp = ioBuffer;
					Serial_print("a: ");
					Serial_printHex(*bp++);
					Serial_print(" hl: ");
					Serial_printHex(*bp++);
					Serial_printHex(*bp++);
					Serial_print(" bc: ");
					Serial_printHex(*bp++);
					Serial_printHex(*bp++);
					Serial_print(" de: ");
					Serial_printHex(*bp++);
					Serial_printHex(*bp++);
					bp = ioBuffer;
				}
				break;

				case CMD_DBG_HEXDUMP:
				{
					int i;
					char flags;
					
					bp = ioBuffer;
					flags = *bp++;
					for (i = 0; i < 18; ++i)
					{
						Serial_printHex(*bp++);
						if (i)
						{
							Serial_printChar(' ');
						}
					}
					if ((flags &0x80) == 0)
					{
						Serial_NL();
					}	
					bp = ioBuffer;
				}
				break;

				case CMD_DBG_SHOW_BP:
				{
					Serial_printf("%d bytes in buffer\r\n", bp - ioBuffer);
					error = 123;
					strcpy(ioBuffer, "1234567890");
					mode = MODE_OUTPUT;
					bp = ioBuffer;
				}
				break;

				case CMD_GO_TEST_MODE:
				{
					TestMode();
				}
				break;

				default:
					//report("unknown command: ", data);
					break;
			}

			PPWrite(error);
			LED_WHITE_OFF;

			PPStatusWrite(PPSTAT_CLIENT_READY);
		}
	}
	else if ((status & PPSTAT_CLIENT_BUFFER_FULL) == 0 && mode == MODE_OUTPUT)
	{
		// the output buffer is clear, and we're in output mode. fill the output buffer.

		PPWrite(*bp);
		++bp;
	}
}