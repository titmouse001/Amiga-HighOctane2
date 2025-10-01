/* STDIO.H for SIM68K */

#if !defined(__STDIO_DEF_)
#define __STDIO_DEF_

#define NULL       0
#define EOF        (-1) 

#define putchar(c) putch(c)
#define getchar()  getche()

extern int _ungetbuf;

int _putch();
int _getch();
int _exit();
int putch();
int getche();
int getch();
int ungetch();
int puts();
char *gets();
int printf();
int sprintf();
int scanf();
int sscanf();

#endif
