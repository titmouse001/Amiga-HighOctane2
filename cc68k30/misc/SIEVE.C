/*  SIEVE.C -  Een ingewikkelder C programma
 *  Bepaalt aantal priemgetallen met "Zeef van Erastosthenes"
 *  Compileren met 'CC SIEVE' of 'CC SIEVE -M'
 *  Uitvoeren met 'SIM68K'
 *  Direct uitvoeren met 'CCG SIEVE'
 *
 *  P.J.Fondse  10-12-1995
 */

#include <stdio.h>

#define MAX    10000
#define TRUE   1
#define FALSE  0

char priemgetal[MAX + 1];

int main()
{
    int i, j, n = 1;
 
    for (i = 0; i <= MAX; i++) priemgetal[i] = TRUE;
    for (i = 2; i <= MAX; i++) {
        if (priemgetal[i]) {
            for (j = 2 * i; j <= MAX; j += i) priemgetal[j] = FALSE;
            n++;
        }
    }
    printf("Bereik van 1 tot %d bevat %d priemgetallen\n", MAX, n);
    return 0;
}
