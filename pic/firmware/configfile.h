#ifndef __CONFIG_H_
#define __CONFIG_H_


enum
{
	// order needs to be strictly maintained as the items are indexed algorithmically.
	IMGNAME_DEFAULT2,
	IMGNAME_DEFAULT3,
	IMGNAME_BOOTCODE,
	IMGNAME_DOS
};

typedef struct
{
	char* imageNames[4];
	unsigned char flags;
}
config_t;

int loadConfig();
int saveConfig();

#endif // __CONFIG_H_
