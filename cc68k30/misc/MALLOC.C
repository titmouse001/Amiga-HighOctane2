/* MALLOC.C for SIM68K */

#include <stdio.h>
#include <malloc.h>
#include <stdlib.h>

#define NALLOC 64

extern HEADER *_allocp;
static HEADER base;

static HEADER *morecore(unsigned int n)
{
    HEADER *p;

    if (n < NALLOC) n = NALLOC;
    p = (HEADER *) sbrk(n * sizeof(HEADER));
    if (p == (HEADER *) -1) return NULL;
    p->size = n;
    p->next = NULL;
    free((void *) (p + 1));
    return _allocp;
}

static HEADER *locate(HEADER *p)
{
    HEADER  *q;

    for (q = _allocp; !(p > q && p <= q->next); q = q->next) {
        if (q >= q->next && (p > q || p <= q->next))
            break;
    }
    return q;
}

static char *adjust(unsigned int size, unsigned int nunits, HEADER *p)
{
    unsigned newsize;

    if (size == nunits || size - 1 == nunits)
        return p + 1;
    if (size > nunits) {
        newsize = p->size - nunits;
        p[nunits].next = NULL;
        p[nunits].size = newsize;
        p->size = nunits;
        free((char *) (p + nunits + 1));
        return p + 1;
    }           
    return NULL;
}

char *realloc(char *ptr, unsigned int size)
{
    HEADER  *p1, *p2, *q;
    unsigned nunits, totalsize;

    p1 = (HEADER *)(ptr - sizeof(HEADER));

    /* check for allocated block */

    if (p1->next) return NULL;

    /* calculate size of request in blocks */

    nunits = 1 + (size + sizeof(HEADER) -1) / sizeof(HEADER);

    /* check to see if request is equal to or one header less than */

    if (p1->size == nunits || p1->size - 1 == nunits) return ptr;
    q = locate(p1);
    totalsize = p1->size;

    /* q points before the new block */

    /* request is smaller */

    if (nunits < totalsize) {
        return adjust(totalsize, nunits, p1);
    }
    /* see if above is in list */

    if (p1 + p1->size == q->next) {
        totalsize += q->next->size;
        p1->size = totalsize;
        q->next = q->next->next;
        _allocp = q;
        if(p2 = adjust(totalsize, nunits, p1)) return p2;
    }
    /* see if below is in list */

    if (q + q->size == p1) {
        totalsize += q->size;
        q->size = totalsize;
        memcpy((char *) (q + 1), ptr, (int) ((p1->size - 1) * sizeof(HEADER)));
        p1 = q;
        q = locate(p1);
        q->next = p1->next;
        p1->next = NULL;
        _allocp = q;        
        if (p2 = adjust(totalsize, nunits, p1)) return p2;
    }
    if ((q = (HEADER *) malloc(size)) == NULL) return NULL;
    memcpy((char *) q, (char *) (p1 + 1), (int) size);
    free((char *) (p1 + 1));
    return (char *) q;
}           

char *sbrk(unsigned int n)
{
    void *brk;

    brk = (_heap + sizeof(HEADER) - 1) & ~(sizeof(HEADER) - 1);
    _heap += n;
    return (_heap < _himem - _stklen) ? brk : -1;
}

char *malloc(unsigned int n)
{
    HEADER *p, *q;
    int nunits;

    nunits = 1 + (n + sizeof(HEADER) - 1) / sizeof(HEADER);
    if (_allocp == NULL) {
        _allocp = &base;
        base.next = &base;
        base.size = 0;
    }
    for (q = _allocp, p = q->next; ; q = p, p = p->next) {
        if (p->size >= nunits) {
            if (p->size == nunits)
                q->next = p->next;
            else {
                q->next = p + nunits;
                q->next->size = p->size - nunits;
                q->next->next = p->next;
                p->size = nunits;
            }
            p->next = NULL;
            _allocp = q;
            return (void *) (p + 1);
        }
        if (p == _allocp) {
            if ((p = morecore((unsigned) nunits)) == NULL) return NULL;
        }
    }
}

char *calloc(unsigned int n, unsigned int size)
{
    char *p;
    unsigned int i;

    if ((p = malloc((i = n * size))) != NULL) memset(p, '\0', i);
    return p;
}

void free(char *ap)
{
    HEADER *p, *q;
    
    p = (HEADER *) (ap - sizeof(HEADER));
    if (p->next) return;
    for (q = _allocp; !(p > q && p < q->next); q = q->next)
        if (q >= q->next && (p > q || p < q->next)) break;
    if (p + p->size == q->next) {
        p->size += q->next->size;
        p->next = q->next->next;
    } 
    else p->next = q->next;
    if (q + q->size == p) {
        q->size += p->size;
        q->next = p->next;
    }
    else q->next = p;
    _allocp = q;
}

