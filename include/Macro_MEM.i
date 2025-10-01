;------------------------------------------------------
;These two macros check for anything trashing memory
;outside valid ranges +/-
DEBUGMEMCHECK_START	MACRO
	IFNE 	MEMORY_DEBUG_ON
	add.l	#4*1024,Param2	;increase mem size DEBUG ONLY!!!!!!!!!
	ENDC
	ENDM
;------------------------------------------------------
DEBUGMEMCHECK_END	MACRO
	IFNE 	MEMORY_DEBUG_ON
	move.l	Param3,a0
	move.l	Param3,a1
	add.l	Param2,a1		;add size
	sub.l	#2*1024,a1	
	move.l	#((2*1024)/2)-1,d1 ;loop amount
\@loopsetcheckmem
	move.w	#$0f,(a0)+
	move.w	#$0f,(a1)+
	dbra	d1,\@loopsetcheckmem
	
	add.l	#2*1024,Param3	; offest to fake debug location.
	
	ENDC
	ENDM

;----------------------------------------------
;IN: TYPE,SIZE,LOC

ADD_MEM		MACRO	; return in Param3 

	move.l	\1,Param1	; MEM TYPE
	move.l	\2,Param2	; size

	MOVEM.L	D0-7/a0-6,-(SP)
	
	DEBUGMEMCHECK_START	; AUTOMATICALLY USED IN DEBUG VERSION
	Jsr	AddToMemoryList	
	DEBUGMEMCHECK_END	; AUTOMATICALLY USED IN DEBUG VERSION
	
	Move.l	Param3,\3  ;ptr

	MOVEM.L	(SP)+,D0-7/a0-6

	ENDM

;-----------------------------------------------------
;******************************
;*** IN: TYPE,SIZE,LOCATION ***
;******************************

ADD_MEM_PRINTF	MACRO
	ADD_MEM 	\1,\2,\3
	PRINT_F		MSG_RESERVING,Param2
	PRINTDOS	MSG_LF,stdout
	ENDM

;--------------------------------------
;********************
;*** IN: LOCATION ***
;********************

FREEMEMITEM	MACRO
	move.l	\1,Param1
	bsr	FreeMemoryItem
	ENDM

;-------------------------------------------------
;*********************
;*** MEM LONG COPY ***
;*********************
;Input:	Param1=Source
;	Param2=Dest
;	Param3=Bytes
MEM_LONG_COPY	MACRO

	move.l	\1,Param1	; This method allows any regester settup.
	move.l	\2,Param2	;
	move.l	\3,Param3	; 

	bsr	QuickMemCopy

	ENDM
	
;--------------------------------------------------------
