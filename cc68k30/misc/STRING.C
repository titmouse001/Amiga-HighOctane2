/* STRING.C - String functions for SIM68K */

#include <stdio.h>
#include <ctype.h>

char *strcat(s, t)
char *s, *t;
{
    char *u;

    for (u = s; *u; u++);
    while (*u++ = *t++) ;
    return s;
}

char *strchr(s, c) 
char *s;
int c;
{
    while (c != *s && *s) s++;
    if (c && *s == 0) return NULL;
    return s;
}

int strcmp(s, t)
char *s,*t;
{
    while (*s == *t) {
        if (*s == '\0') break;
        s++;
        t++;
    }
    return *s - *t;
}

char *strcpy(s, t)
char *s, *t;
{
    char *u = s;

    while (*u++ = *t++) ;
    return s;
}

int strcspn(s, t)
char *s, *t;
{
    int i;
    char *p;

    for (i = 0; s[i]; i++) {
        for (p = t; *p != s[i] && *p; p++) ;
        if (*p) break;
    }
    return i;
}

int strlen(s)
char *s;
{
    int i;

    for (i = 0; *s++; i++);
    return i;
}

char *strupr(s) 
char *s; { 
    char *t;

    for (t = s; *t; t++) *t = toupper(*t);
    return s;
}

char *strlwr(s)
char *s;
{
    char *t;

    for (t = s; *t; t++) *t = tolower(*t);
    return s;
}

char *strncat(s, t, n)
char *s, *t;
int n;
{
    char *u = s;

    if (n == 0) return s;
    while (*u) u++;
    while ((*u++ = *t++) && --n);
    if (!n) *u = '\0';
    return s;
}

int strncmp(s, t, n)
char *s, *t;
int n;
{
    if (n) {
        while (*s == *t && --n) {
            if (*s == '\0') break;
            s++;
            t++;
        }
    }
    return *s - *t;
}

char *strncpy(s, t, n)
char *s, *t;
int n;
{
    char *u = s;

    if (n) {
        while ((*u++ = *t++) && --n) ;
        while (--n > 0) *u++ = '\0';
    }
    return s;
}

char *strpbrk(s, t)
char *s, *t;
{
    char *u;

    for ( ; *s; ++s) {
        for (u = t; *u != *s && *u; u++);
        if (*u) return s;
    }
    return NULL;
}

char *strrchr(s, c)
char *s;
int c;
{
    char *u;

    for (u = NULL; *s; s++) if (*s == c) u = s;
    if (c == '\0') u = s;
    return u;
}

int strspn(s, t)
char *s, *t;
{
    int i;
    char *u;

    for (i = 0; s[i]; ++i) {
        for (u = t; *u != s[i] && *u; u++) ;
        if (!*u) break;
    }
    return i;
}

char *strtok(s, t)
char *s, *t;
{
static char *olds1, oldchar;

    if (s == NULL) {
        s = olds1;
        *s = oldchar;
    }
    while (*s && strchr(t, (int) *s)) s++;
    olds1 = s;
    if (*s == '\0') return NULL;
    do {
        olds1++;
    } while (*olds1 && strchr(t, (int) *olds1) == NULL);
    oldchar = *olds1;
    *olds1 = '\0';
    return s;
}

void *memcpy(s, t, n)
unsigned char *s, *t;
unsigned int n;
{
    char *u = s;

    while (n--) *u++ = *t++;
    return s;
}

void *memmove(s, t, n)
unsigned char *s, *t;
unsigned int n;
{
    char *u;

    if (t - s < n) {
        s += n;
        t += n;
        while (n--) *s-- = *t--;
    }
    else {
        u = s;
        while (n--) *u++ = *t++;
    }
    return s;
}

void *memchr(s, c, n)
unsigned char *s, c;
unsigned int n;
{
    while (n--) {
        if (c == *s) break;
        s++;
    }
    return (n) ? s : NULL;
}

void *memset(s, c, n)
unsigned char *s, c;
unsigned int n;
{
    char *u = s;

    while (n--)
        *u++ = c;
    return s;
}

int memcmp(s, c, n)
unsigned char *s, c;
unsigned int n;
{
    while (*s == c) {
        if (n--) break;
        s++;
    }
    return *s - c;
}


