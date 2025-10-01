; STDIO.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
_putch:  
	link  	A6,#0
	move.l	D2,-(A7)
	move.w	8(A6),D2
	moveq  	#10,D0
	move.w	D2,D1
	cmp.w	D0,D1
	bne  	putch_1
	moveq  	#13,D0
	move.w	D0,-(A7)
	jsr  	__putch
	addq.w	#2,A7
putch_1:  
	move.w	D2,-(A7)
	jsr  	__putch
	addq.w	#2,A7
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_getch:  
	link  	A6,#-2
	move.l	D2,-(A7)
	move.w	__ungetbuf,D2
	cmp.w	#-1,D2
	beq  	getch_1
	move.w	#-1,__ungetbuf
	bra  	getch_2
getch_1:  
	jsr  	__getch
	move.w	D0,D2
	moveq  	#13,D0
	move.w	D2,D1
	cmp.w	D0,D1
	bne  	getch_3
	moveq  	#10,D0
	move.w	D0,D2
getch_3:  
getch_2:  
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_getche:  
	jsr  	_getch
	move.w	D0,-(A7)
	jsr  	_putch
	addq.w	#2,A7
	rts  
_ungetch:  
	link  	A6,#0
	move.w	8(A6),__ungetbuf
	move.l	__ungetbuf,D0
	unlk  	A6
	rts  
_puts:  
	link  	A6,#-2
	move.l	D2,-(A7)
puts_1:  
	move.l	8(A6),A0
	addq.l	#1,8(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,D2
	tst.w	D2
	beq  	puts_2
	move.w	D2,-(A7)
	jsr  	_putch
	addq.w	#2,A7
	bra  	puts_1
puts_2:  
	moveq  	#10,D0
	move.w	D0,-(A7)
	jsr  	_putch
	addq.w	#2,A7
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_gets:  
	link  	A6,#-6
	movem.l	D2/D3/A2/A3,-(A7)
	move.l	8(A6),D2
	move.l	#_putch,A3
	move.l	D2,A2
gets_1:  
	jsr  	_getch
	move.b	D0,D3
	cmp.b	#10,D3
	beq  	gets_2
	cmp.b	#8,D3
	beq  	gets_3
	move.l	A2,A0
	addq.w	#1,A2
	move.b	D3,(A0)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A3)
	addq.w	#2,A7
	bra  	gets_4
gets_3:  
	move.l	A2,D0
	cmp.l	D2,D0
	ble  	gets_5
	moveq  	#8,D0
	move.w	D0,-(A7)
	jsr  	(A3)
	addq.w	#2,A7
	moveq  	#32,D0
	move.w	D0,-(A7)
	jsr  	(A3)
	addq.w	#2,A7
	moveq  	#8,D0
	move.w	D0,-(A7)
	jsr  	(A3)
	addq.w	#2,A7
	subq.w	#1,A2
gets_5:  
gets_4:  
	bra  	gets_1
gets_2:  
	moveq  	#10,D0
	move.w	D0,-(A7)
	jsr  	(A3)
	addq.w	#2,A7
	clr.b	(A2)
	move.l	D2,D0
	movem.l	(A7)+,D2/D3/A2/A3
	unlk  	A6
	rts  
