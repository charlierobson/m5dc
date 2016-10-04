// convert FCB -> FAT filename, in place

// FCB:
//
// 00            - user byte (always 0 for einy)
// 01 to 08 incl - filename root
// 09 to 0b incl - extension
//

void FCBtoFAT(char* dst, char* src)
{
	int i;
	char* ext = src + 9;

	++src;  // move source pointer past the user byte

	for (i = 0; i < 8; ++i)
	{
		if (*src == ' ')
			break;

		*dst = *src;
		++dst;
		++src;
	}

	*dst = '.';

	src = ext;

	for(i = 0; i < 3; ++i)
	{
		if (*src == ' ')
			break;

		*dst = *src;
		++dst;
		++src;
	}

	*dst = 0;
}
