PRINTDOS 	MACRO 	
		movem.l	a0-6/d0-7,-(sp)
		move.l	\2,d1
		move.l	#\1,d2
		move.l	#\1_SIZE,d3
		CALLSYS	Write,DosBase
		movem.l	(sp)+,a0-6/d0-7
		ENDM
;-----------------------------------------
	
PRINT_F 	MACRO

	movem.l	d0-7/a0-6,-(sp)
	
	lea	\1,a0
	lea	\2,a1
	lea	PrintF_Process,a2	;lable in string.s
	lea	PrintF_Buffer,a3

	move.l	$4.w,a6
	CALL	RawDoFmt
	
	lea	PrintF_Buffer,a0
	move.l	a0,d2
	moveq	#0,d3
	
i\@	addq	#1,d3
	tst.b	(a0)+
	bne.s	i\@
	
	move.l	stdout,d1
	subq	#1,d3

	CALLSYS	Write,DosBase

	movem.l	(sp)+,d0-7/a0-6

	ENDM

;---------------------------------------

txt_str		MACRO
	movem.l	d0-7/a0-2,-(sp)

	lea	\@str,a2
	move.l	\1,d0
	move.l	\2,d1
	bsr	txt
	
	bra.s	\@skipdata
\@str	dc.b	\3,0
	EVEN
\@skipdata
	movem.l	(sp)+,d0-7/a0-2
	ENDM

;--------------------------------------

txt_val		MACRO

	movem.l	d0-7/a0-2,-(sp)
	move.l	\3,d0
	bsr	val2str
	move.l	a0,a2
	move.l	\1,d0
	move.l	\2,d1
	bsr	txt
	movem.l	(sp)+,d0-7/a0-2
	ENDM
	
;---------------------------------------
	
Menutxt_str		MACRO

	movem.l	d0-7/a0-2,-(sp)

	lea	\@str,a2
	move.l	#\1,d0
	move.l	#\2,d1
	bsr	Menutxt
	
	bra.s	\@skipdata
\@str	dc.b	\3,0
	EVEN
\@skipdata
	movem.l	(sp)+,d0-7/a0-2
	ENDM

;-----------------------------------------------


Menutxt_val		MACRO

	movem.l	d0-7/a0-2,-(sp)
	move.l	\3,d0
	bsr	val2str
	move.l	a0,a2
	move.l	\1,d0
	move.l	\2,d1
	bsr	Menutxt
	movem.l	(sp)+,d0-7/a0-2
	ENDM

;----------------------------------------