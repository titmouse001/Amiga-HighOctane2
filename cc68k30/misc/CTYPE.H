/* CTYPE.H for SIM68K */

#if     !defined(__CTYPE_DEF_)
#define __CTYPE_DEF_

extern unsigned char _ctype[];
                                                  
#define islower(x)  (_ctype[(x) + 1] & 0x01)
#define isupper(x)  (_ctype[(x) + 1] & 0x02)
#define isdigit(x)  (_ctype[(x) + 1] & 0x04)
#define isxdigit(x) (_ctype[(x) + 1] & 0x08)
#define isspace(x)  (_ctype[(x) + 1] & 0x10)
#define ispunct(x)  (_ctype[(x) + 1] & 0x20)
#define iscntrl(x)  (_ctype[(x) + 1] & 0x40)
#define isalpha(x)  (_ctype[(x) + 1] & 0x03)
#define isalnum(x)  (_ctype[(x) + 1] & 0x07)
#define isprint(x)  (_ctype[(x) + 1] & 0x80)
#define isgraph(x)  (_ctype[(x) + 1] & 0x27)
#define isascii(x)  (((x) & 0x80) == 0)

#define toascii(x)  ((x) & 0x7f)
#define _tolower(x) ((x) | 0x20)
#define _toupper(x) ((x) & 0x5f)

int toupper();
int tolower();

#endif
