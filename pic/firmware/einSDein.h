#include <compiler.h>
#include <hardwareprofile.h>
#include <ctype.h>

#include "ff.h"
#include "pp.h"
#include "command.h"
#include "serial.h"
#include "dsk.h"
#include "diskio.h"
#include "xilinx\micro.h"
#include "configfile.h"
#include "blobbyfile.h"

extern int mode;

extern FATFS fatfs;

extern FIL userFile;
extern FILINFO filInfo;

extern char ioBuffer[512];
extern char* bp;

extern int imageNum;
extern FIL imageFile[2];

extern short* sectorOffsets[2];

extern char* poolPtr;

extern config_t config;

extern int driveAvailable(int);
extern FRESULT openFile(FIL*, char*, BYTE);
extern int reportOKFail(int);
extern int reportError(char*);
extern void FCBtoFAT(char*, char*);
extern int copyFile(char*, char*);
extern void reportInput(char*);
extern int dirBegin();
extern int dirHandler();
extern int mountDiskImage(int, char*);
extern void strupper(char*);

extern void inline einSDein(void);
#define MAINFN inline void einSDein(void)
