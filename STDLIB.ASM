; STDLIB.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
stdlib_convert:  
	link  	A6,#-2
	movem.l	D2/D3/D4/A2,-(A7)
	move.w	16(A6),D3
	move.l	8(A6),A2
	move.l	12(A6),D4
	move.l	D4,-(A7)
	move.w	D3,D0
	and.l	#65535,D0
	move.l	D0,-(A7)
	jsr  	ULDIV
	move.l	4(A7),D0
	addq.w	#8,A7
	move.w	D0,D2
	move.w	D3,D0
	and.l	#65535,D0
	move.l	D4,D1
	cmp.l	D0,D1
	blt  	stdlib_convert_1
	move.w	D3,-(A7)
	move.l	D4,-(A7)
	move.w	D3,D0
	and.l	#65535,D0
	move.l	D0,-(A7)
	jsr  	ULDIV
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	D0,-(A7)
	move.l	A2,-(A7)
	jsr  	stdlib_convert
	add.w	#10,A7
	move.l	D0,A2
stdlib_convert_1:  
	cmp.w	#9,D2
	bgt  	stdlib_convert_3
	move.w	D2,D0
	moveq  	#48,D1
	add.w	D1,D0
	bra  	stdlib_convert_4
stdlib_convert_3:  
	move.w	D2,D0
	moveq  	#97,D1
	add.w	D1,D0
	sub.w	#10,D0
stdlib_convert_4:  
	move.b	D0,(A2)
	move.l	A2,A0
	moveq  	#1,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	movem.l	(A7)+,D2/D3/D4/A2
	unlk  	A6
	rts  
_ltoa:  
	link  	A6,#-4
	movem.l	D2/D3/D4/A2,-(A7)
	move.l	12(A6),D2
	move.l	8(A6),D3
	move.w	16(A6),D4
	move.l	D2,A2
	cmp.w	#2,D4
	blt  	ltoa_3
	cmp.w	#36,D4
	ble  	ltoa_1
ltoa_3:  
	move.l	D2,D0
	bra  	ltoa_0
ltoa_1:  
	cmp.w	#10,D4
	bne  	ltoa_4
	tst.l	D3
	bge  	ltoa_4
	move.l	D3,D0
	neg.l	D0
	move.l	D0,D3
	tst.l	D3
	bge  	ltoa_6
	move.l	#stdlibS0,-(A7)
	move.l	D2,-(A7)
	jsr  	_strcpy
	addq.w	#8,A7
	move.l	D2,D0
	bra  	ltoa_0
ltoa_6:  
	move.l	A2,A0
	addq.w	#1,A2
	move.b	#45,(A0)
ltoa_4:  
	move.w	D4,-(A7)
	move.l	D3,-(A7)
	move.l	A2,-(A7)
	jsr  	stdlib_convert
	add.w	#10,A7
	move.l	D0,A2
	clr.b	(A2)
	move.l	D2,D0
ltoa_0:  
	movem.l	(A7)+,D2/D3/D4/A2
	unlk  	A6
	rts  
_ultoa:  
	link  	A6,#-4
	movem.l	D2/D3/A2,-(A7)
	move.l	12(A6),D2
	move.w	16(A6),D3
	move.l	D2,A2
	cmp.w	#2,D3
	blt  	ultoa_3
	cmp.w	#36,D3
	ble  	ultoa_1
ultoa_3:  
	move.l	D2,D0
	bra  	ultoa_0
ultoa_1:  
	move.w	D3,-(A7)
	move.l	8(A6),-(A7)
	move.l	A2,-(A7)
	jsr  	stdlib_convert
	add.w	#10,A7
	move.l	D0,A2
	clr.b	(A2)
	move.l	D2,D0
ultoa_0:  
	movem.l	(A7)+,D2/D3/A2
	unlk  	A6
	rts  
_itoa:  
	link  	A6,#0
	move.w	14(A6),-(A7)
	move.l	10(A6),-(A7)
	move.w	8(A6),D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	_ltoa
	add.w	#10,A7
	unlk  	A6
	rts  
_strtol:  
	link  	A6,#-8
	movem.l	D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
	move.l	8(A6),A2
	move.w	16(A6),D2
	move.l	12(A6),A3
	moveq  	#48,D6
	move.l	#_tolower,A4
	move.l	#__ctype,A5
	moveq  	#16,D7
	moveq  	#0,D3
	moveq  	#0,D5
	moveq  	#0,D4
	cmp.w	#0,A3
	beq  	strtol_1
	move.l	A2,(A3)
strtol_1:  
	tst.w	D2
	blt  	strtol_5
	cmp.w	#36,D2
	ble  	strtol_3
strtol_5:  
	move.l	D3,D0
	bra  	strtol_0
strtol_3:  
strtol_6:  
	move.b	(A2),D0
	ext.w	D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	A5,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	D7,D0
	tst.w	D0
	beq  	strtol_7
	addq.w	#1,A2
	bra  	strtol_6
strtol_7:  
	cmp.b	#45,(A2)
	bne  	strtol_8
	moveq  	#1,D5
	addq.w	#1,A2
	bra  	strtol_9
strtol_8:  
	cmp.b	#43,(A2)
	bne  	strtol_10
	addq.w	#1,A2
strtol_10:  
strtol_9:  
	tst.w	D2
	bne  	strtol_12
	moveq  	#10,D2
	move.b	(A2),D0
	cmp.b	D6,D0
	bne  	strtol_14
	moveq  	#1,D0
	and.l	#65535,D0
	move.l	A2,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A4)
	addq.w	#2,A7
	moveq  	#120,D1
	cmp.w	D1,D0
	bne  	strtol_16
	move.w	D7,D0
	bra  	strtol_17
strtol_16:  
	moveq  	#8,D0
strtol_17:  
	move.w	D0,D2
strtol_14:  
strtol_12:  
	move.w	D2,D0
	cmp.w	D7,D0
	bne  	strtol_18
	moveq  	#0,D0
	and.l	#65535,D0
	move.l	A2,A0
	add.l	D0,A0
	move.b	(A0),D0
	cmp.b	D6,D0
	bne  	strtol_18
	moveq  	#1,D0
	and.l	#65535,D0
	move.l	A2,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A4)
	addq.w	#2,A7
	moveq  	#120,D1
	cmp.w	D1,D0
	bne  	strtol_18
	moveq  	#2,D0
	and.l	#65535,D0
	add.l	D0,A2
strtol_18:  
strtol_20:  
	move.b	(A2),D0
	ext.w	D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	A5,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	beq  	strtol_22
	move.b	(A2),D0
	sub.b	D6,D0
	ext.w	D0
	cmp.w	D2,D0
	bge  	strtol_24
	move.w	D2,D0
	ext.l	D0
	move.l	D3,-(A7)
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D3
	addq.w	#8,A7
	move.l	A2,A0
	addq.w	#1,A2
	move.b	(A0),D0
	sub.b	D6,D0
	ext.w	D0
	ext.l	D0
	add.l	D0,D3
	moveq  	#1,D4
	bra  	strtol_25
strtol_24:  
	bra  	strtol_21
strtol_25:  
	bra  	strtol_23
strtol_22:  
	move.b	(A2),D0
	ext.w	D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	A5,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#3,D0
	tst.w	D0
	beq  	strtol_26
	move.b	(A2),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A4)
	addq.w	#2,A7
	moveq  	#97,D1
	sub.w	D1,D0
	move.w	D2,D1
	sub.w	#10,D1
	cmp.w	D1,D0
	bge  	strtol_26
	move.w	D2,D0
	ext.l	D0
	move.l	D3,-(A7)
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D3
	addq.w	#8,A7
	move.l	A2,A0
	addq.w	#1,A2
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A4)
	addq.w	#2,A7
	moveq  	#97,D1
	sub.w	D1,D0
	add.w	#10,D0
	ext.l	D0
	add.l	D0,D3
	moveq  	#1,D4
	bra  	strtol_27
strtol_26:  
	bra  	strtol_21
strtol_27:  
strtol_23:  
	bra  	strtol_20
strtol_21:  
	cmp.w	#0,A3
	beq  	strtol_28
	tst.w	D4
	beq  	strtol_28
	move.l	A2,(A3)
strtol_28:  
	tst.w	D5
	beq  	strtol_30
	move.l	D3,D0
	neg.l	D0
	move.l	D0,D3
strtol_30:  
	move.l	D3,D0
strtol_0:  
	movem.l	(A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
	unlk  	A6
	rts  
_atol:  
	link  	A6,#0
	move.w	#10,-(A7)
	moveq  	#0,D0
	move.l	D0,-(A7)
	move.l	8(A6),-(A7)
	jsr  	_strtol
	add.w	#10,A7
	unlk  	A6
	rts  
_atoi:  
	link  	A6,#0
	move.w	#10,-(A7)
	moveq  	#0,D0
	move.l	D0,-(A7)
	move.l	8(A6),-(A7)
	jsr  	_strtol
	add.w	#10,A7
	unlk  	A6
	rts  
_abs:  
	link  	A6,#0
	move.l	D2,-(A7)
	move.w	8(A6),D2
	tst.w	D2
	bge  	abs_1
	move.w	D2,D0
	neg.w	D0
	bra  	abs_2
abs_1:  
	move.w	D2,D0
abs_2:  
	move.l	(A7)+,D2
	unlk  	A6
	rts  
stdlib_X:
	dc.l	305419896
_srand:  
	link  	A6,#0
	move.l	#305419896,D0
	move.w	8(A6),D1
	and.l	#65535,D1
	eor.l	D1,D0
	move.l	D0,stdlib_X
	unlk  	A6
	rts  
_rand:  
	move.l	A2,-(A7)
	move.l	#stdlib_X,A2
	move.l	(A2),D0
	asl.l	#1,D0
	move.l	(A2),D1
	move.l	D0,-(A7)
	move.l	(A2),D0
	asr.l	#1,D0
	eor.l	D0,D1
	move.l	(A2),D0
	move.l	D1,-(A7)
	moveq  	#21,D1
	asr.l	D1,D0
	move.l	(A7)+,D1
	eor.l	D0,D1
	move.l	(A2),D0
	move.l	D1,-(A7)
	moveq  	#31,D1
	asr.l	D1,D0
	move.l	(A7)+,D1
	eor.l	D0,D1
	moveq  	#1,D0
	and.l	#65535,D0
	and.l	D0,D1
	move.l	(A7)+,D0
	or.l	D1,D0
	move.l	D0,(A2)
	move.l	(A2),D0
	moveq  	#1,D1
	and.l	#65535,D1
	sub.l	D1,D0
	move.w	#32767,D1
	and.l	#65535,D1
	and.l	D1,D0
	move.l	(A7)+,A2
	rts  
stdlibS0:
	dc.b	45,50,49,52,55,52,56,51,54,52,56,0
