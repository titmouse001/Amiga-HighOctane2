#include <stdio.h>

char buffer[256];

void main()
{
    char letter;
    int n;

    gets(buffer);
    hoofdletters(buffer);
    for (letter = 'A'; letter <= 'Z'; letter++)
        if ((n = tellen(letter, buffer)) != 0) histgrm(letter, n);
}

void hoofdletters(char *s)
{
    for (; *s; s++) *s = toupper(*s);
}

int tellen(int c, char *s)
{
    int i = 0;

    for (; *s; s++) if (*s == c) i++;
    return i;
}

void histgrm(int c, int n)
{
    putchar(c);
    putchar(' ');
    while (n--) putchar('*');
    putchar('\n');
}

