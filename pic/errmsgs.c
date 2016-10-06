const char* errmsgs[] =
{
	"OK",
	"DISK ERROR",			/* (1) A hard error occured in the low level disk I/O layer */
	"INTERNAL ERROR",		/* (2) Assertion failed */
	"NOT READY",			/* (3) The physical drive cannot work */
	"FILE NOT FOUND",		/* (4) Could not find the file */
	"NO PATH",				/* (5) Could not find the path */
	"INVALID NAME",			/* (6) The path name format is invalid */
	"ACCESS DENIED",		/* (7) Acces denied due to prohibited access or directory full */
	"OBJECT EXISTS",		/* (8) Acces denied due to prohibited access */
	"INVALID OBJECT",		/* (9) The file/directory object is invalid */
	"WRITE PROTECTED",		/* (10) The physical drive is write protected */
	"INVALID DRIVE",		/* (11) The logical drive number is invalid */
	"NOT ENABLED",			/* (12) The volume has no work area */
	"NO FILESYSTEM",		/* (13) There is no valid FAT volume on the physical drive */
	"MKFS ABORTED",			/* (14) The f mkfs() aborted due to any parameter error */
	"TIMEOUT",				/* (15) Could not get a grant to access the volume within defined period */
	"LOCKED",				/* (16) The operation is rejected according to the file shareing policy */
	"NOT ENOUGH CORE",		/* (17) LFN working buffer could not be allocated */
	"TOO MANY OPEN FILES",	/* (18) Number of open files >  FS SHARE */

	// DSK system errors - the DSK errors start at FR_LAST
	"BAD IMAGE FORMAT",		// 19
	"INVALID SECTOR",		// 20
	"READ ERROR",			// 21

	// CPLD writing errors - start at DSK_LAST (value is added to non-zero returns from cpld_program call
	"UNKNOWN ERROR",		// 22
	"TDO MISMATCH",			// 23
	"MAX RETRIES",			// 24
	"ILLEGAL CMD",			// 25
	"ILLEGAL STATE",		// 26
	"DATA OVERFLOW",		// 27

	// Blobby files error - start at XSVF_LAST
	"UNKNOWN FILE TYPE"		// 28
};
