;--------------------------------------------------------------
	*** MACHINE SPECIFIC ***
;--------------------------------------------------------------

CUSTOM			EQU	$dff000
LF			EQU	10
NULL			EQU	0

;	********************	;uses devpack includes now.
;	*** exec.library ***
;	********************

;;;allocmem		equ	-198
;;;freemem			equ	-210
;;;oldopenlibrary		equ	-408
;;;;closelibrary		equ	-414

;	********************
;	***  dos.library ***
;	********************

;open			equ	-30
;close			equ	-36
;read			equ	-42
;write			equ	-48
;output			equ	-60
;lock			equ	-84
;unlock			equ	-90
;examine			equ	-102

SIZE_LONG		EQU	4 ;size_of
SIZE_WORD		EQU	2
SIZE_BYTE		EQU	1
