/* MALLOC.H - memory allocation for SIM68K */

#if !defined(__MALLOC_DEF_)
#define __MALLOC_DEF_

extern void *_himem;
extern void *_heap;
extern long _stklen;

typedef struct header {
    char align[2];
    unsigned size;
    struct header *next;
} HEADER;

void *sbrk();
void *calloc();
void *malloc();
void *realloc();
void free();

#endif
