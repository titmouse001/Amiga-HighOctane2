/* STDLIB.C for SIM68K */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

static char *convert(char *s, unsigned long arg, int base)
{
	int temp = arg % base;

    if (arg >= base) s = convert(s, arg / base, base);
	*s = (temp <= 9) ? temp + '0' : temp + 'a' - 10;
    return s + 1;
}

char *ltoa(long arg, char *s, int base)
{
    char *t = s;

    if (base < 2 || base > 36) return s;
    if (base == 10 && arg < 0L) {
        arg = -arg;
        if (arg < 0L) {
            strcpy(s, "-2147483648");
            return s;
        }
        *t++ = '-';
    }
    t = convert(t, (unsigned long) arg, base);
    *t = '\0';
    return s;
}

char *ultoa(unsigned long arg, char *s, int base)
{
    char *t = s;

    if (base < 2 || base > 36) return s;
    t = convert(t, arg, base);
    *t = '\0';
    return s;
}

char *itoa(int arg, char *s, int base)
{
    return ltoa((long) arg, s, base);
}

long strtol(char *str, char **ptr, int base)
{
    long answer = 0L;
    int sign = 0, parse = 0;

    if (ptr) *ptr = str;
    if (base < 0 || base > 36) return answer;
    while (isspace(*str)) str++;
    if (*str == '-') {
        sign = 1;
        str++;
    } 
    else if (*str == '+') {
        str++;
    }
    if (base == 0) {
        base = 10;
        if (*str == '0') base = (tolower(str[1]) == 'x') ? 16 : 8;
    }
    if (base == 16 && str[0] == '0' && tolower(str[1]) == 'x') str += 2;
    for (;;) {
        if (isdigit(*str)) {
            if(*str - '0' < base) {
                answer *= (long) base;
                answer += (long) (*str++ - '0');
                parse = 1;
            } 
            else break;
        } 
        else if(isalpha(*str) && tolower(*str) - 'a' < base - 10) {
            answer *= (long) base;
            answer += (long) (tolower(*str++) - 'a' + 10);
            parse = 1;
        } 
        else break;
    }
    if (ptr && parse) *ptr = str;
    if (sign) answer = -answer;
    return answer;
}

long atol(char *s)
{
    return strtol(s, (char **) NULL, 10);
}

int atoi(char *s)
{
    return (int) strtol(s, (char **) NULL, 10);
}

int abs(int i)
{
    return (i < 0) ? -i : i;
}

static unsigned long X = 0x12345678;

void srand(unsigned n)
{
    X = 0x12345678L ^ n;
}

int rand()
{
    X = (X << 1) | ((X ^ (X >> 1) ^ (X >> 21) ^ (X >> 31)) & 1);
    return (X - 1) & 0x7FFF;
}










