/* STDIO.C for SIM68K */

#include <stdio.h>

int putch(c)
int c;
{
    if (c == '\n') _putch('\r');
    _putch(c);
    return c;
}
 
int getch()
{
    int c;

    if ((c = _ungetbuf) != -1)
        _ungetbuf = -1;
    else if ((c = _getch()) == '\r') 
        c = '\n';
    return c;
}

int getche()
{
    return putch(getch());
}

int ungetch(c)
int c;
{
    return _ungetbuf = c;
}

int puts(s)
char *s;
{
    int c;

    while (c = *s++) putchar(c);
    putchar('\n');
    return c;
}

char *gets(s)
char *s;
{
    char c, *t = s;

    while ((c = getch()) != '\n') {
        if (c != '\b')
            putchar(*t++ = c);
        else if (t > s) {
            putchar('\b');
            putchar(' ');
            putchar('\b');
            t--;
        }
    }
    putchar('\n');
    *t = '\0';
    return s;
}

