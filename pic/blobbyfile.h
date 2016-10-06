#ifndef __BLOBBY_BLOBBY_BLOBBY_H
#define __BLOBBY_BLOBBY_BLOBBY_H

extern FRESULT GetBlobbyFileType(FIL* userFile, BYTE* blobType);
extern int ReadBlob(FIL* inFile);

#define BLOB_ERROR_UNKNOWN_TYPE 28
#define BLOB_ERROR_UNEXPECTED 29

#endif