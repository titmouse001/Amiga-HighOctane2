	
; convert a long number to a string
; Entry: d0 - number
; exit: a0 - pointer to ascii string
Val2Str
	movem.l	d0-d7/a1-a6,-(sp)
	lea	NumberStrBuff,a0
	lea	NumberList,a1

	tst.l	d0
	bpl.s	@not_minus
	move.b	#'-',(a0)+
	neg.l	d0
@not_minus

	cmp.l	#0,d0
	bne.s	@try_again
	move.b	#'0',(a0)
	move.b	#0,1(a0)
	bra.s	@end

@try_again
	cmp.l	(a1),d0
	bhs.s	@got_start
	adda	#4,a1
	bra	@try_again
@got_start

@next_digit
	move.b	#'0',(a0)
@again
	cmp.l	(a1),d0
	blo.s	@cont
	sub.l	(a1),d0
	add.b	#1,(a0)
	bra	@again
@cont
	adda	#1,a0
	adda	#4,a1
	tst.l	(a1)
	bne	@next_digit
	move.b	#0,(a0)

@end
	lea	NumberStrBuff,a0
	movem.l	(sp)+,d0-d7/a1-a6
	rts
		EVEN

NumberList
	dc.l	1000000000
	dc.l	100000000
	dc.l	10000000
	dc.l	1000000
	dc.l	100000
	dc.l	10000
	dc.l	1000
	dc.l	100
	dc.l	10
	dc.l	1
	dc.l	0


NumberStrBuff		ds.b	16
NumberStrBuff_size	EQU	*-NumberStrBuff
	
		EVEN

ClearNumberStrBuff

	move.l	a0,-(sp)
	move.l	#NumberStrBuff,a0
	
	move.l	#NULL,SIZE_LONG*0(a0)
	move.l 	#NULL,SIZE_LONG*1(a0)
	move.l	#NULL,SIZE_LONG*2(a0)
	move.l	#NULL,SIZE_LONG*3(a0)

	move.l	(sp)+,a0	
	rts



	
;----------------------------
PrintF_Process
	move.b	d0,(a3)+
	rts	
;----------------------------

