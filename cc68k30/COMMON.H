#ifndef _COMMON_H_
#define _COMMON_H_

#ifndef TRUE
#define TRUE	(1)
#endif

#ifndef FALSE
#define	FALSE	(0)
#endif


/*
 * these types make more sense as lower case as they 
 * are extentions to the C language (almost)
 */
typedef long				int32;
typedef short				int16;
typedef signed char		int8;
typedef unsigned long	uint32;
typedef unsigned short	uint16;
typedef unsigned char	uint8;

/* .. but these are here for compatibality*/
typedef unsigned char   uchar;
typedef unsigned short  ushort;
typedef unsigned int    uint;
typedef unsigned long   ulong;
typedef long				bool;
typedef unsigned char	byte;


#define	INT32_MAX		(LONG_MAX)
#define	INT32_MIN		(LONG_MIN)
#define	UINT32_MAX		(ULONG_MAX)

#define	INT16_MAX		(SHORT_MAX)
#define	INT16_MIN		(SHORT_MIN)
#define	UINT16_MAX		(USHORT_MAX)

#define	INT8_MAX		(SCHAR_MAX)
#define	INT8_MIN		(SCHAR_MIN)
#define	UINT8_MAX		(UCHAR_MAX)


#endif
