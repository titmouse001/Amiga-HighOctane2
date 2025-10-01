	

;-------------------------------------------------------------------------
; FUNCTION:    returns a random integer in the range 0 to UpperLimit-1
;
;    RndNum = Random( UpperLimit )
;      D0		  D0
;
; INPUTS:    UpperLimit - a long(or short will do) in the range 0-65535
; RESULT:    a random integer is returned to you, real quick!
; BUGS/LIMITATIONS:  	range was limited to 0-65535 to avoid problems with 
;			the DIVU instruction which can return real wierd values 
;			if the result is larger than 16 bits.
;

_Random_ASM:	; 'c' code helper line
Random		move.w	d0,-(sp)	save range
		beq.s	10$		range of 0 returns 0 always
		bsr.s	LongRnd		get a longword random number
		clr.w	d0		use upper word (it's most random)
		swap	d0
		divu.w	(sp),d0		divide by range...
		clr.w	d0
		swap	d0		...and use remainder for the result
10$		addq.l	#2,sp		scrap range on stack
		rts

; this is the main random number generation routine. Not user callable

LongRnd		movem.l	d1-d3,-(sp)	
		movem.l	RND,d0/d1	D0=LSB's, D1=MSB's of random number
		andi.b	#$0e,d0		ensure upper 59 bits are an...
		ori.b	#$20,d0		...odd binary number
		move.l	d0,d2
		move.l	d1,d3
		add.l	d2,d2		accounts for 1 of 17 left shifts
		addx.l	d3,d3		[D2/D3] = RND*2
		add.l	d2,d0
		addx.l	d3,d1		[D0/D1] = RND*3
		swap	d3		shift [D2/D3] additional 16 times
		swap	d2
		move.w	d2,d3
		clr.w	d2
		add.l	d2,d0		add to [D0/D1]
		addx.l	d3,d1
		movem.l	d0/d1,RND	save for next time through
		move.l	d1,d0		most random part to D0
		movem.l	(sp)+,d1-d3
		rts

;-------------------------------------------------------------------------

_random:  
	link  	A6,#-4
	move.l	D2,-(A7)  //DO i NEED TO SAVE THIS???
	move.l	8(A6),D0
	bsr.s		random	; d0=random(d0);
	move.l	(A7)+,D2
	unlk  	A6
	rts  



;-------------------


; MULDIV.ASM - 32 bit multiply and divide functions for CC68K

ULMUL:
       link    A6,#0
       movem.l D0/D1,-(A7)
       move.l  8(A6),D1
       move.l  12(A6),D0
       bra.s   lmul_3
LMUL:
       link    A6,#0
       movem.l D0/D1,-(A7)
       move.l  8(A6),D1
       move.l  12(A6),D0
       tst.l   D0
       bpl.s   lmul_1
       neg.l   D0
       tst.l   D1
       bpl.s   lmul_2
       neg.l   D1
       bra.s   lmul_3
lmul_1:
       tst.l   D1
       bpl.s   lmul_3
       neg.l   D1
lmul_2:
       bsr.s   domul
       neg.l   D1
       negx.l  D0
       bra.s   lmul_4
lmul_3:
       bsr.s   domul
lmul_4:
       move.l  D1,8(A6)
       movem.l (A7)+,D0/D1
       unlk    A6
       rts
domul:
       cmpi.l  #$FFFF,D1
       bhi.s   domul_1
       cmpi.l  #$FFFF,D0
       bhi.s   domul_2
       mulu    D0,D1
       rts
domul_1:
       cmpi.l  #$FFFF,D0
       bhi.s   domul_4
       bra.s   domul_3
domul_2
       exg     D0,D1
domul_3:
       move.l  D2,-(A7)
       move.l  D1,D2
       swap    D2
       mulu    D0,D1
       mulu    D0,D2
       swap    D2
       clr.w   D2
       add.l   D2,D1
       move.l  (A7)+,D2
       rts
domul_4:
       movem.l D2/D3,-(A7)
       move.l  D1,D2
       move.l  D1,D3
       mulu    D0,D1
       mulu    D0,D2
       swap    D0
       mulu    D0,D3
       add.l   D3,D2
       clr.w   D2
       swap    D2
       add.l   D2,D1
       movem.l (A7)+,D2/D3
       rts
ULDIV:
       link    A6,#0
       movem.l D0/D1,-(A7)
       move.l  8(A6),D1
       move.l  12(A6),D0
       bra.s   ldiv_3
LDIV:
       link    A6,#0
       movem.l D0/D1,-(A7)
       move.l  8(A6),D1
       move.l  12(A6),D0
       tst.l   D0
       bpl.s   ldiv_1
       neg.l   D0
       tst.l   D1
       bpl.s   ldiv_2
       neg.l   D1
       bsr.s   dodiv
       neg.l   D1
       bra.s   ldiv_4
ldiv_1:
       tst.l   D1
       bpl.s   ldiv_3
       neg.l   D1
       bsr.s   dodiv
       neg.l   D0
       bra.s   ldiv_4
ldiv_2:
       bsr.s   dodiv
       neg.l   D0
       neg.l   D1
       bra.s   ldiv_4
ldiv_3:
       bsr.s   dodiv
ldiv_4:
       move.l  D0,8(A6)
       move.l  D1,12(A6)
       movem.l (A7)+,D0/D1
       unlk    A6
       rts
dodiv:
       cmpi.l  #$FFFF,D1
       bhi.s   dodiv_2
       cmpi.l  #$FFFF,D0
       bhi.s   dodiv_1
       divu    D1,D0
       move.l  D0,D1
       clr.w   D1
       swap    D1
       andi.l  #$FFFF,D0
       rts
dodiv_1:
       movem.w D0/D2,-(A7)
       clr.w   D0
       swap    D0
       divu    D1,D0
       move.w  D0,D2
       move.w  (A7)+,D0
       divu    D1,D0
       swap    D0
       clr.l   D1
       move.w  D0,D1
       move.w  D2,D0
       swap    D0
       move.w  (A7)+,D2
       rts
dodiv_2:
       movem.l D2/D3/D4,-(A7)
       move.l  D1,D2
       clr.w   D2
       swap    D2
       addq.l  #1,D2
       move.l  D0,D3
       move.l  D1,D4
       move.l  D2,D1
       bsr.s   dodiv_1
       move.l  D4,D1
       divu    D2,D1
       divu    D1,D0
       andi.l  #$FFFF,D0
dodiv_3:
       move.l  D4,D1
       move.l  D4,D2
       swap    D2
       mulu    D0,D1
       mulu    D0,D2
       swap    D2
       add.l   D2,D1
       sub.l   D3,D1
       bhi.s   dodiv_4
       neg.l   D1
       cmp.l   D1,D4
       bhi.s   dodiv_5
       addq.l  #1,D0
       bra.s   dodiv_3
dodiv_4:
       subq.l  #1,D0
       bra.s   dodiv_3
dodiv_5:
       movem.l (A7)+,D2/D3/D4
       rts

