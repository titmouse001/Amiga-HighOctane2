/* PRINT.C - Formatted output for SIM68K */

#include <stdio.h>
#include <ctype.h>

#define ON  1
#define OFF 0

static char *cbuf;

static int cmov(int c)
{
    *cbuf++ = c;
    return 0;
}

static int setval(char **fmt, void **argp)
{
    int n = 0;

    if (**fmt == '*') {
        n = *((int *) *argp)++;
        (*fmt)++;
    } 
    else while (isdigit(**fmt)) n = n * 10 + (*((*fmt)++) - '0');
    return n;
}

static int doprint(int (*rtn)(), char *fmt, char **arg)
{
    int n = 0;
    int ljust, sign, blank, alt, modn, zpad, prec, num, lconv;
    int width, pad, count;
    char *p, *s;
    static char prefix[10];
    static char string[100];

    while (*fmt) {
        if (*fmt != '%') {
            if ((*rtn)(*fmt) == -1) return -1;
            n++;
            fmt++;
            continue;
        }
        fmt++;
        s = string;
        ljust = sign = blank = alt = zpad = lconv = OFF;
        width = pad = 0;
        prec = -1;
        for (;;) {
            switch (*fmt) {
            case '-':
                fmt++;
                ljust = ON;
                continue;
            case '+':
                fmt++;
                sign = ON;
                continue;
            case ' ':
                fmt++;
                blank = ON;
                continue;
            case '#':
                fmt++;
                alt = ON;
                continue;
            }
            break;
        }
        if (*fmt == '0') {
            fmt++;
            zpad = ON;
        }
        width = setval(&fmt, &arg);
        if (*fmt == '.') {
            fmt++;
            prec = setval(&fmt, &arg);
        }
        if (*fmt == 'l') {
            fmt++;
            lconv = ON;
        }
        switch (*fmt) {
        case 'i':
        case 'd':
            if (lconv)
                ltoa(*((long*) arg)++, s, 10);
            else
                ltoa((long) (*((int *) arg)++), s, 10);
            break;
        case 'o':
            if (lconv)
                ultoa(*((long*) arg)++, s, 8);
            else
                ultoa((long) (*((int *) arg)++), s, 8);
            break;
            break;
        case 'X':
        case 'x':
            if (lconv)
                ultoa(*((long*) arg)++, s, 16);
            else
                ultoa((long) (*((int *) arg)++), s, 16);
            break;
            break;
        case 'u':
            if (lconv)
                ultoa(*((long*) arg)++, s, 10);
            else
                ultoa((long) (*((int *) arg)++), s, 10);
            break;
        case 'c':
            *s++ = *((int*) arg)++;
            *s = '\0';
            prec = (width) ? width : 1;
            break;
        case 's':
            s = *((char**) arg)++;
            if (prec == -1) prec = strlen(s);
            break;
        default:
            *s++ = *fmt;
            *s = '\0';
        }
        num = strlen(s);
        if (*fmt == 's' && prec >= 0) num = (num > prec) ? prec : num;
        count = 0;
        p = prefix;
        if (*fmt == 'd' || *fmt == 'i') {
            if (sign || *s == '-') {
                if (*s == '-') {
                    *p++ = *s++;
                    num--;
                }
                else *p++ = '+';
                count++;
            }
            else if (blank) {
                if (*s == '-') {
                    *p++ = *s++;
                    num--;
                }
                else *p++ = ' ';
                count++;
            }
        }
        if (alt) {
            switch (*fmt) {
            case 'o':
            case 'X':
            case 'x':
                *p++ = '0';
                count++;
                if (tolower(*fmt) == 'x') {
                    *p++ = 'x';
                    count++;
                }
            }
        }
        *p = '\0';
        if (isupper(*fmt)) {
            for (p = prefix; *p; p++) *p = toupper(*p);
            for (p = s; *p; p++) *p = toupper(*p);
        }
        switch (*fmt) {
        case 'i':
        case 'd':
        case 'o':
        case 'X':
        case 'x':
        case 'u':
            if (zpad && !ljust)  pad = width - count - num;
        case 's':
        case 'c':
            if (pad < 0) pad = 0;
            if (!ljust) {
                modn = num + pad + count;
                while (modn < width--) {
                    if ((*rtn)(' ') == -1) return -1;
                    n++;
                }
            }
            p = prefix;
            while (*p) {
                if ((*rtn)(*p++) == -1) return -1;
                n++;
            }
            modn = pad;
            while (modn--) {
                if ((*rtn)('0') == -1) return -1;
                n++;
            }
            while (*s) {
                switch (*fmt) {
                case 's':
                case 'c':
                    if (prec-- <= 0) break;
                default:
                    if ((*rtn)(*s++) == -1) return -1;
                    n++;
                    continue;
                }
                break;
            }
            if (ljust) {
                modn = num + pad + count;
                while (modn < width--) {
                    if ((*rtn)(' ') == -1) return -1;
                    n--;
                }
            }
            break;
        default:
            if ((*rtn)(*fmt) == -1) return -1;
            n++;
        }
        fmt++;
    }
    return n;
}

int printf(char *fmt, void *arg)
{
    return doprint(putch, fmt, &arg);
}

int sprintf(char *buf, char *fmt, void *arg)
{
    int n;

    cbuf = buf;
    n = doprint(cmov, fmt, &arg);
    *cbuf = '\0';
    return n;
}

