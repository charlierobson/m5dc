#include "dsk.h"
#include <string.h>

extern BYTE ioBuffer[];

int parseDSK(FIL* infile, short* sectorOffsets, int* tracks, int* sectors)
{
	int i, j;
	int track;
	UINT numRead;
	int offs = 0;
	int sectorsPerTrack = 10;

	DISK_INFORMATION_BLOCK* dib = (DISK_INFORMATION_BLOCK*)ioBuffer;
	SECTOR_INFORMATION_BLOCK* sib;

	*tracks = 0;
	*sectors = 0;

	f_read(infile, ioBuffer, sizeof(DISK_INFORMATION_BLOCK), &numRead);
	offs += numRead;
	if (numRead != sizeof(DISK_INFORMATION_BLOCK))
	{
		return DSK_READ_ERROR;
	}	

	if (!memcmp(ioBuffer, "EXTENDED", sizeof("EXTENDED")))
	{
		return DSK_FORMAT_ERROR;
	}

	// only handling single sided disks

	if (dib->nSides == 2 || dib->nTracks > 40)
	{
		return DSK_FORMAT_ERROR;
	}

	*tracks = dib->nTracks;

	// only handling 10 sectors per track
	// 0x15  =  21  =  256+20*256  =  sizeof(header)+10*512

	// 10 * 40
	for (i = 0; i < 40 * sectorsPerTrack; ++i)
	{
		sectorOffsets[i] = -1;
	}

	for (i = 0; i < *tracks; ++i)
	{
		if (dib->trackSizeTable[i] != 0x15)
		{
			return DSK_FORMAT_ERROR;
		}
	}

	// ok, work out the sector offsets in the file

	for(track = 0; track < *tracks; ++track)
	{
		long sectorBase;

		f_read(infile, ioBuffer, 256, &numRead);
		offs += numRead;
		if (numRead != 256)
		{
			return DSK_READ_ERROR;
		}

		sib = (SECTOR_INFORMATION_BLOCK*)(ioBuffer+sizeof(TRACK_INFORMATION_BLOCK));
		sectorBase = offs;

		for(j = 0; j < sectorsPerTrack; ++j)
		{
			if (sib->sectorID >= sectorsPerTrack || sectorOffsets[track * sectorsPerTrack + sib->sectorID] != -1)
			{
				return DSK_INVALID_SECTOR;
			}

			sectorOffsets[track * sectorsPerTrack + sib->sectorID] = (short)(sectorBase / 256);
			sectorBase += 512;
			++*sectors;
			++sib;
		}

		if (f_lseek(infile, offs + 5120) != FR_OK)
		{
			return DSK_READ_ERROR;
		}

		offs += sectorsPerTrack * 512;
	}

	return DSK_OK;
}

