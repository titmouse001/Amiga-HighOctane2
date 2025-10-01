/* ASSERT.H for SIM68K */

#if !defined(__ASSERT_DEF_)
#define __ASSERT_DEF_

#ifndef NDEBUG
#define assert(expr)\
    if (!(expr)) {\
        printf("Assertion failed: %s, file %s, line %d\n", #expr,\
            __FILE__, __LINE__);\
        exit(1);\
    }
#else
#define assert(expr)
#endif

#endif
