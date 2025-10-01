/* SCAN.C - Formatted input for SIM68K */

#include <stdio.h>
#include <ctype.h>

#define FALSE  0
#define TRUE   1

int scanf(fmt, arg)
char *fmt, *arg;
{
    return doscan(getche, ungetch, fmt, &arg);
}

static char *hold;

static int sread()
{
    int tc;

    return (tc = (int) (*hold++)) ? tc : EOF;
}

static int sback(val)
int val;
{
    if (val != EOF)
        *--hold = val;
    else
        --hold;
    return val;
}

int sscanf(str, fmt, arg)
char *str, *fmt, *arg;
{
    hold = str;
    return doscan(sread, sback, fmt, &arg);
}

static int count;

static int skip(pfunc)
int (*pfunc)();
{
    int c;

    do {
        c = (*pfunc)();
        count++;
    } while (isspace(c));
    return c;
}

static char *selection(fmt, pfunc, rfunc, len, sup, sp)
char *fmt, *sp;
int (*pfunc)(), (*rfunc)(), len, sup;
{
    int value, i, success, not;

    if (*fmt == '^') {
        not = TRUE;
        fmt++;
    } 
    else not = FALSE;
    while (len--) {
        value = (*pfunc)();
        if (value == EOF)
            break;
        count++;
        for (i = 0, success = FALSE; fmt[i] != ']' || i == 0; i++) {
            if (i != 0 && fmt[i] == ']')
                break;
            if (i && fmt[i] == '-') {
                if (fmt[i - 1] < fmt[i + 1]) {
                    if (value >= fmt[i - 1] && value <= fmt[i + 1]) break;
                    i++;
                    continue;
                }
            }
            if (value == fmt[i]) break;
        }
        if (i == 0 || fmt[i] != ']') success = TRUE;
        if (not) {
            if (success == FALSE) {
                if (sup == FALSE)
                    *sp++ = value;
                continue;
            } 
            else break;
        }
        if (not == FALSE) {
            if (success == TRUE) {
                if (sup == FALSE)
                    *sp++ = value;
                continue;
            } 
            else break;
        }
    }
    if (value != EOF) {
        (*rfunc)(value);
        count--;
    }
    if (sup == FALSE)
        *sp = '\0';
    while (*++fmt != ']') ;
    return ++fmt;
}

int doscan(pfunc, rfunc, fmt, arg)
char *fmt, **arg;
int (*pfunc)(), (*rfunc)();
{
    char *tp, *sp, sar[80];
    int nmatch, negative, sup, flen, point, exponent, sign;
    int tc, temp, lspec, hspec, sspec, processed;
    long mult, tlg;

    nmatch = count = 0;
    while (tc = (int) *fmt++) {
        if (tc == ' ' || tc == '\t' || tc == '\n') { 
            do {
                temp = (*pfunc)();
                count++;
                if (temp == EOF)
                    return (nmatch) ? nmatch : EOF;
            } while (isspace(temp));
            count--;
            (*rfunc)(temp);
            continue;
        }
        processed = sup = FALSE;

        if (tc == '%') {
            tc = (int) *fmt++;
            lspec = sup = sspec = hspec = 0;
            flen = 32767; 
            if (tc == '*') {
                sup = TRUE;
                tc = (int) *fmt++;
            }
            if (isdigit(tc)) { 
                flen = tc - '0';
                while (isdigit(tc = (int) *fmt++))
                    flen = flen * 10 + tc - '0';
            }
            if (tc == 'l' || tc == 'L') {
                lspec = TRUE;
                tc = (int) *fmt++;
            } 
            else if (tc == 'h') {
                hspec = TRUE;
                tc = (int) *fmt++;
            }
            if (tc == '[') { 
                if (sup == FALSE)
                    sp = *arg++;
                fmt = selection(fmt, pfunc, rfunc, flen, sup, sp);
                if (sup == FALSE)
                    nmatch++;
                continue;
            }
            if (tc == 'n') { 
                if (sup == FALSE) {
                    sp = *arg++;
                    *(int *) sp = count;
                    nmatch++;
                }
                continue;
            }
            if (tc == 's') { 
                temp = skip(pfunc);
                if (sup == FALSE)
                    sp = *arg++;
                count++;
                while (flen-- && isspace(temp) == FALSE && temp != EOF) {
                    processed = TRUE;
                    if (sup == FALSE)
                        *sp++ = temp;
                    temp = (*pfunc)();
                    count++;
                }
                if (sup == FALSE) {
                    *sp = '\0';
                    if (processed)
                        nmatch++;
                }
                if (temp == EOF || (sup == 0 && processed == 0))
                    return (nmatch) ? nmatch : (temp == EOF) ? EOF : nmatch;
                count--;
                (*rfunc)(temp);
                continue;
            }                       
            if (tc == 'c') { 
                if (sup == FALSE)
                    sp = *arg++;
                temp = (*pfunc)();
                count++;
                if (flen == 32767) 
                    flen = 1;
                if (temp == EOF && sup == FALSE)
                    nmatch--;
                while (flen-- && temp != EOF) {
                    if (sup == FALSE)
                        *sp++ = temp;
                    temp = (*pfunc)();
                    count++;
                }
                if (temp == EOF) 
                    return (nmatch) ? nmatch : EOF;
                if (sup == FALSE)
                    nmatch++;
                count--;
                (*rfunc)(temp);
                continue;
            }
            if (tc == 'i') {
                temp = skip(pfunc);
                if (temp == '0') {
                    processed = TRUE;
                    temp = (*pfunc)();
                    if (tolower(temp) == 'x') {
                        tc = 'x';
                    } 
                    else {
                        count--;
                        (*rfunc)(temp);
                        tc = 'o';
                    }
                    count++;
                } 
                else {
                    count--;
                    (*rfunc)(temp);
                    tc = 'd';
                }
            }
            if (tc == 'd' || tc == 'u' || tc == 'x' || tc == 'o') {
                temp = skip(pfunc);
                mult = 10l;
                if (tc == 'x')
                    mult = 16L;
                if (tc == 'o')
                    mult = 8L;
                if (sup == FALSE)
                    sp = *arg++;
                negative = FALSE;
                count++;
                if (tc != 'u' && temp == '-') { 
                    temp = (*pfunc)();
                    count++;
                    negative = TRUE;
                    processed = TRUE;
                }
                tlg = 0;
                if (temp == EOF) {
                    return (nmatch) ? nmatch : EOF;
                }
                while (flen-- && ((tc == 'x' && tolower(temp) >= 'a'
                    && toupper(temp) <= 'a') || isdigit(temp))) {
                    if (isdigit(temp) == FALSE) {
                        temp = tolower(temp) - 'a' + 10 + '0';
                    }
                    tlg = tlg * mult + temp - '0';
                    temp = (*pfunc)();
                    count++;
                    processed = TRUE;
                }
                if (temp != EOF) {
                    (*rfunc)(temp);
                    count--;
                    if (processed == FALSE)
                        return nmatch;
                } 
                else if (processed == FALSE) {
                    return (nmatch) ? nmatch : EOF;
                }
                if (negative)
                    tlg = -tlg;
                if (sup == FALSE) {
                    if (lspec) {
                        *(long *)sp = tlg;
                    } 
                    else if (hspec) {
                        *(short *)sp = (short) tlg;
                    } 
                    else {
                        *(int *)sp = (int) tlg;
                    }
                nmatch++;
                }
                if (temp == EOF) 
                    return (nmatch) ? nmatch : EOF;
                continue;
            }
            if (tc == '%') {
                temp = (*pfunc)();
                if (temp == EOF)
                    return (nmatch) ? nmatch : EOF;
                count++;
                if (temp != tc) {
                    (*rfunc)(temp);
                    count--;
                    return nmatch;
                }
                continue;
            }
        }
        temp = (*pfunc)();
        count++;
        if (temp == EOF)
            return (nmatch) ? nmatch : EOF;
        if (temp != tc) {
            (*rfunc)(temp);
            count--;
            return nmatch;
        }
    }
    return nmatch;                             
}








