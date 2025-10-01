/*  REVERSE.C  -   Een ander C programma
 *  Type een regel en print met hoofdleters in omgekeerde volgorde
 *  Compileren met 'CC REVERSE' of 'CC REVERSE -M'
 *  Uitvoeren met 'SIM68K'
 *  Direct uitvoeren met 'CCG REVERSE'
 *
 *  P.J.Fondse  10-12-1995
 */

#include <stdio.h>
#include <ctype.h>

char regel[80];

void main()
{
    int i;

    printf("Type een regel\n");
    gets(regel);
    for (i = strlen(regel) - 1; i >= 0; i--) putch(toupper(regel[i]));
    putch('\n');
}
