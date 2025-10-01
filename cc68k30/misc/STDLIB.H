/* STDLIB.HC for SIM68K */

#if !defined(__STDLIB_DEF_)
#define __STDLIB_DEF_

#define max(a,b) (((a) > (b)) ? (a) : (b))
#define min(a,b) (((a) < (b)) ? (a) : (b))

int abs();
char *lmod();
char *ltoa();
char *ultoa();
char *itoa();
long strtol();
int atoi();
long atol();

#endif
