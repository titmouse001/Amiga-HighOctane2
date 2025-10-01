
;-----------------------------------------
; RandomSeed( SeedValue1, SeedValue2 )

RandomSeed	MACRO
		movem.l	d0-d1,-(sp)
		move.l	#\1,d0
		move.l	#\2,d1
		movem.l	d0/d1,RND
		movem.l	(sp)+,d0-d1
		endm
;------------------------------------------
; RandomSeed = GetRandomSeed()
; OUTPUT: D0/D1

GetRandomSeed	MACRO
		movem.l	RND,d0/d1
		endm
;------------------------------------------

MAX_w	MACRO
	cmp.w	\1,\2
	ble.s	ok\@
	moveq	\1,\2
ok\@
	ENDM
;-----------------------------------------
ABS_w		MACRO

		tst.w	\1
		bgt.s	\@ItsPos
		neg.w	\1
\@ItsPos		
		ENDM
;-----------------------------------------
ABS_w_NO_TST		MACRO
		
		bgt.s	\@ItsPos
		neg.w	\1
\@ItsPos		
		ENDM
;-----------------------------------------
ABS_l		MACRO
		
		tst.l	\1
		bpl.s	\@ItsPos
		neg.l	\1
\@ItsPos		
		ENDM
;----------------------------------------			

ABS_l_NO_TST		MACRO
		bpl.s	\@ItsPos
		neg.l	\1
\@ItsPos		
		ENDM
;-----------------------------------------

RANGE	MACRO

	cmp.l	\2,\3		
	ble.s	\@rangeOk1
	move.l	\2,\3		
\@rangeOk1
	cmp.l	\1,\3		
	bge.s	\@rangeOk2
	move.l	\1,\3		
\@rangeOk2

	ENDM


;--------------------------------------------

;SGN_N_w		MACRO ; CPU Flags must be set before
;
;		beq.s	\@its_zero	;8cy
;		bgt.s	\@its_pos	;8cy
;		move.w	#-\2,\1		;8cy  
;		bra.s	\@skip		;10cy	
;\@its_pos
;		move.w	#\2,\1		;8cy
;		bra.s	\@skip		;10cy
;\@its_zero
;		move.w	#0,\1		;8cy 
;\@skip
;

;try out these for SGN
;1:	add.w	d0,d0
;	subx.w	d1,d1
;	sub.w	d0,d1
;	addx.w	d0,d1

;2:	add.w	d0,d0
;	subx.w	d1,d1
;	sub.w	d0,d1
;	addx.w	d1,d0

;3:	add.w	d0,d0
;	subx.w	d1,d1
;	negx.w	d0
;	addx.w	d1,d1

;		ENDM	
	
;-------------------------------------------------------------------
; USEAGE :- Mulu_20 IN_REG,SCRATCH_REG
Mulu_20		MACRO	

		move.l	\1,\2	;4c
		lsl.l	#4,\1	;14c	...6cy+(2cy*4)
		add.l	\2,\2	;4c	
		add.l 	\2,\2	;4c	
		add.l	\2,\1	;4c	(TOTAL 28 cycles)
		ENDM
;------------------------------------------------------------------
;USEAGE :- Mulu_10	d5 	:- Multiply contents of d5 by 10
Mulu_10		MACRO

		move.l	\1,d7
		add.l	\1,\1
		add.l 	\1,\1
		add.l 	d7,\1
		add.l 	\1,\1

		ENDM
;-------------------------------------------------------------------------

