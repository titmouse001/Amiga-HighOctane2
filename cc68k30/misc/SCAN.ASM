; SCAN.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
_scanf:  
	link  	A6,#0
	lea  	12(A6),A0
	move.l	A0,-(A7)
	move.l	8(A6),-(A7)
	move.l	#_ungetch,-(A7)
	move.l	#_getche,-(A7)
	jsr  	_doscan
	add.w	#16,A7
	unlk  	A6
	rts  
scan_hold:
	ds.b	4
scan_sread:  
	link  	A6,#-2
	move.l	D2,-(A7)
	move.l	scan_hold,A0
	addq.l	#1,scan_hold
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,D2
	tst.w	D2
	beq  	scan_sread_1
	move.w	D2,D0
	bra  	scan_sread_2
scan_sread_1:  
	moveq  	#-1,D0
scan_sread_2:  
	move.l	(A7)+,D2
	unlk  	A6
	rts  
scan_sback:  
	link  	A6,#0
	move.l	D2,-(A7)
	move.w	8(A6),D2
	cmp.w	#-1,D2
	beq  	scan_sback_1
	move.w	D2,D0
	subq.l	#1,scan_hold
	move.l	scan_hold,A0
	move.b	D0,(A0)
	bra  	scan_sback_2
scan_sback_1:  
	subq.l	#1,scan_hold
scan_sback_2:  
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_sscanf:  
	link  	A6,#0
	move.l	8(A6),scan_hold
	lea  	16(A6),A0
	move.l	A0,-(A7)
	move.l	12(A6),-(A7)
	move.l	#scan_sback,-(A7)
	move.l	#scan_sread,-(A7)
	jsr  	_doscan
	add.w	#16,A7
	unlk  	A6
	rts  
scan_count:
	ds.b	2
scan_skip:  
	link  	A6,#-2
	move.l	A2,-(A7)
scan_skip_1:  
	move.l	8(A6),A0
	jsr  	(A0)
	move.w	D0,A2
	addq.w	#1,scan_count
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#16,D0
	tst.w	D0
	bne  	scan_skip_1
	move.l	A2,D0
	move.l	(A7)+,A2
	unlk  	A6
	rts  
scan_selection:  
	link  	A6,#-8
	movem.l	D2/D3/D4/D5/D6/A2/A3/A4,-(A7)
	move.l	8(A6),A3
	move.w	22(A6),D5
	move.l	24(A6),A4
	moveq  	#93,D6
	cmp.b	#94,(A3)
	bne  	scan_selection_1
	moveq  	#1,D3
	addq.w	#1,A3
	bra  	scan_selection_2
scan_selection_1:  
	moveq  	#0,D3
scan_selection_2:  
scan_selection_3:  
	move.w	20(A6),A0
	subq.w	#1,20(A6)
	cmp.w	#0,A0
	beq  	scan_selection_4
	move.l	12(A6),A0
	jsr  	(A0)
	move.w	D0,D2
	cmp.w	#-1,D2
	bne  	scan_selection_5
	bra  	scan_selection_4
scan_selection_5:  
	addq.w	#1,scan_count
	move.w	#0,A2
	moveq  	#0,D4
scan_selection_7:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	cmp.b	D6,D0
	bne  	scan_selection_9
	cmp.w	#0,A2
	bne  	scan_selection_8
scan_selection_9:  
	cmp.w	#0,A2
	beq  	scan_selection_10
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	cmp.b	D6,D0
	bne  	scan_selection_10
	bra  	scan_selection_8
scan_selection_10:  
	cmp.w	#0,A2
	beq  	scan_selection_12
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	cmp.b	#45,(A0)
	bne  	scan_selection_12
	move.w	A2,D0
	subq.w	#1,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	A3,A1
	add.l	D0,A1
	move.b	(A0),D0
	cmp.b	(A1),D0
	bge  	scan_selection_14
	move.w	A2,D0
	subq.w	#1,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D2,D1
	cmp.w	D0,D1
	blt  	scan_selection_16
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D2,D1
	cmp.w	D0,D1
	bgt  	scan_selection_16
	bra  	scan_selection_8
scan_selection_16:  
	addq.w	#1,A2
	bra  	scan_selection_7
scan_selection_14:  
scan_selection_12:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D2,D1
	cmp.w	D0,D1
	bne  	scan_selection_18
	bra  	scan_selection_8
scan_selection_18:  
	addq.w	#1,A2
	bra  	scan_selection_7
scan_selection_8:  
	cmp.w	#0,A2
	beq  	scan_selection_22
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A3,A0
	add.l	D0,A0
	move.b	(A0),D0
	cmp.b	D6,D0
	beq  	scan_selection_20
scan_selection_22:  
	moveq  	#1,D4
scan_selection_20:  
	tst.w	D3
	beq  	scan_selection_23
	tst.w	D4
	bne  	scan_selection_25
	tst.w	D5
	bne  	scan_selection_27
	move.w	D2,D0
	move.l	A4,A0
	addq.w	#1,A4
	move.b	D0,(A0)
scan_selection_27:  
	bra  	scan_selection_3
scan_selection_25:  
	bra  	scan_selection_4
scan_selection_23:  
	tst.w	D3
	bne  	scan_selection_29
	cmp.w	#1,D4
	bne  	scan_selection_31
	tst.w	D5
	bne  	scan_selection_33
	move.w	D2,D0
	move.l	A4,A0
	addq.w	#1,A4
	move.b	D0,(A0)
scan_selection_33:  
	bra  	scan_selection_3
scan_selection_31:  
	bra  	scan_selection_4
scan_selection_29:  
	bra  	scan_selection_3
scan_selection_4:  
	cmp.w	#-1,D2
	beq  	scan_selection_35
	move.w	D2,-(A7)
	move.l	16(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	subq.w	#1,scan_count
scan_selection_35:  
	tst.w	D5
	bne  	scan_selection_37
	clr.b	(A4)
scan_selection_37:  
scan_selection_39:  
	addq.w	#1,A3
	move.b	(A3),D0
	cmp.b	D6,D0
	beq  	scan_selection_40
	bra  	scan_selection_39
scan_selection_40:  
	addq.w	#1,A3
	move.l	A3,D0
	movem.l	(A7)+,D2/D3/D4/D5/D6/A2/A3/A4
	unlk  	A6
	rts  
_doscan:  
	link  	A6,#-122
	movem.l	D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
	move.l	8(A6),A4
	moveq  	#-1,D4
	clr.w	scan_count
	move.w	scan_count,D2
doscan_1:  
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
	cmp.w	#0,A3
	beq  	doscan_2
	moveq  	#32,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_5
	moveq  	#9,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_5
	moveq  	#10,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_3
doscan_5:  
doscan_6:  
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_8
	tst.w	D2
	beq  	doscan_10
	move.w	D2,D0
	bra  	doscan_11
doscan_10:  
	move.w	D4,D0
doscan_11:  
	bra  	doscan_0
doscan_8:  
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#16,D0
	tst.w	D0
	bne  	doscan_6
	subq.w	#1,scan_count
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	bra  	doscan_1
doscan_3:  
	moveq  	#0,D3
	move.w	D3,D6
	moveq  	#37,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_12
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
	clr.w	-110(A6)
	move.w	-110(A6),-112(A6)
	move.w	-112(A6),D3
	move.w	D3,-108(A6)
	move.w	#32767,D5
	moveq  	#42,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_14
	moveq  	#1,D3
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
doscan_14:  
	move.w	A3,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	beq  	doscan_16
	move.w	A3,D0
	moveq  	#48,D1
	sub.w	D1,D0
	move.w	D0,D5
doscan_18:  
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
	move.w	A3,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	beq  	doscan_19
	move.w	D5,D0
	muls  	#10,D0
	add.w	A3,D0
	moveq  	#48,D1
	sub.w	D1,D0
	move.w	D0,D5
	bra  	doscan_18
doscan_19:  
doscan_16:  
	moveq  	#108,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_22
	moveq  	#76,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_20
doscan_22:  
	move.w	#1,-108(A6)
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
	bra  	doscan_21
doscan_20:  
	moveq  	#104,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_23
	move.w	#1,-110(A6)
	move.l	16(A6),A0
	addq.l	#1,16(A6)
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,A3
doscan_23:  
doscan_21:  
	moveq  	#91,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_25
	tst.w	D3
	bne  	doscan_27
	move.l	20(A6),A0
	addq.l	#4,20(A6)
	move.l	(A0),A5
doscan_27:  
	move.l	A5,-(A7)
	move.w	D3,-(A7)
	move.w	D5,-(A7)
	move.l	12(A6),-(A7)
	move.l	A4,-(A7)
	move.l	16(A6),-(A7)
	jsr  	scan_selection
	add.w	#20,A7
	move.l	D0,16(A6)
	tst.w	D3
	bne  	doscan_29
	addq.w	#1,D2
doscan_29:  
	bra  	doscan_1
doscan_25:  
	moveq  	#110,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_31
	tst.w	D3
	bne  	doscan_33
	move.l	20(A6),A0
	addq.l	#4,20(A6)
	move.l	(A0),A5
	move.w	scan_count,(A5)
	addq.w	#1,D2
doscan_33:  
	bra  	doscan_1
doscan_31:  
	moveq  	#115,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_35
	move.l	A4,-(A7)
	jsr  	scan_skip
	addq.w	#4,A7
	move.w	D0,A2
	tst.w	D3
	bne  	doscan_37
	move.l	20(A6),A0
	addq.l	#4,20(A6)
	move.l	(A0),A5
doscan_37:  
	addq.w	#1,scan_count
doscan_39:  
	move.w	D5,A0
	subq.w	#1,D5
	cmp.w	#0,A0
	beq  	doscan_40
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#16,D0
	tst.w	D0
	bne  	doscan_40
	move.w	A2,D0
	cmp.w	D4,D0
	beq  	doscan_40
	moveq  	#1,D6
	tst.w	D3
	bne  	doscan_41
	move.w	A2,D0
	move.l	A5,A0
	addq.w	#1,A5
	move.b	D0,(A0)
doscan_41:  
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	bra  	doscan_39
doscan_40:  
	tst.w	D3
	bne  	doscan_43
	clr.b	(A5)
	tst.w	D6
	beq  	doscan_45
	addq.w	#1,D2
doscan_45:  
doscan_43:  
	move.w	A2,D0
	cmp.w	D4,D0
	beq  	doscan_49
	tst.w	D3
	bne  	doscan_47
	tst.w	D6
	bne  	doscan_47
doscan_49:  
	tst.w	D2
	beq  	doscan_50
	move.w	D2,D0
	bra  	doscan_51
doscan_50:  
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_52
	move.w	D4,D0
	bra  	doscan_53
doscan_52:  
	move.w	D2,D0
doscan_53:  
doscan_51:  
	bra  	doscan_0
doscan_47:  
	subq.w	#1,scan_count
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	bra  	doscan_1
doscan_35:  
	moveq  	#99,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_54
	tst.w	D3
	bne  	doscan_56
	move.l	20(A6),A0
	addq.l	#4,20(A6)
	move.l	(A0),A5
doscan_56:  
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	cmp.w	#32767,D5
	bne  	doscan_58
	moveq  	#1,D5
doscan_58:  
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_60
	tst.w	D3
	bne  	doscan_60
	subq.w	#1,D2
doscan_60:  
doscan_62:  
	move.w	D5,A0
	subq.w	#1,D5
	cmp.w	#0,A0
	beq  	doscan_63
	move.w	A2,D0
	cmp.w	D4,D0
	beq  	doscan_63
	tst.w	D3
	bne  	doscan_64
	move.w	A2,D0
	move.l	A5,A0
	addq.w	#1,A5
	move.b	D0,(A0)
doscan_64:  
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	bra  	doscan_62
doscan_63:  
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_66
	tst.w	D2
	beq  	doscan_68
	move.w	D2,D0
	bra  	doscan_69
doscan_68:  
	move.w	D4,D0
doscan_69:  
	bra  	doscan_0
doscan_66:  
	tst.w	D3
	bne  	doscan_70
	addq.w	#1,D2
doscan_70:  
	subq.w	#1,scan_count
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	bra  	doscan_1
doscan_54:  
	moveq  	#105,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_72
	move.l	A4,-(A7)
	jsr  	scan_skip
	addq.w	#4,A7
	move.w	D0,A2
	moveq  	#48,D0
	move.w	A2,D1
	cmp.w	D0,D1
	bne  	doscan_74
	moveq  	#1,D6
	jsr  	(A4)
	move.w	D0,A2
	move.w	A2,-(A7)
	jsr  	_tolower
	addq.w	#2,A7
	moveq  	#120,D1
	cmp.w	D1,D0
	bne  	doscan_76
	moveq  	#120,D0
	move.w	D0,A3
	bra  	doscan_77
doscan_76:  
	subq.w	#1,scan_count
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	moveq  	#111,D0
	move.w	D0,A3
doscan_77:  
	addq.w	#1,scan_count
	bra  	doscan_75
doscan_74:  
	subq.w	#1,scan_count
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	moveq  	#100,D0
	move.w	D0,A3
doscan_75:  
doscan_72:  
	moveq  	#100,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_80
	moveq  	#117,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_80
	moveq  	#120,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_80
	moveq  	#111,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_78
doscan_80:  
	move.l	A4,-(A7)
	jsr  	scan_skip
	addq.w	#4,A7
	move.w	D0,A2
	move.l	#10,-118(A6)
	moveq  	#120,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_81
	move.l	#16,-118(A6)
doscan_81:  
	moveq  	#111,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_83
	move.l	#8,-118(A6)
doscan_83:  
	tst.w	D3
	bne  	doscan_85
	move.l	20(A6),A0
	addq.l	#4,20(A6)
	move.l	(A0),A5
doscan_85:  
	clr.w	-92(A6)
	addq.w	#1,scan_count
	moveq  	#117,D0
	move.w	A3,D1
	cmp.w	D0,D1
	beq  	doscan_87
	moveq  	#45,D0
	move.w	A2,D1
	cmp.w	D0,D1
	bne  	doscan_87
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	move.w	#1,-92(A6)
	moveq  	#1,D6
doscan_87:  
	moveq  	#0,D0
	move.l	D0,D7
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_89
	tst.w	D2
	beq  	doscan_91
	move.w	D2,D0
	bra  	doscan_92
doscan_91:  
	move.w	D4,D0
doscan_92:  
	bra  	doscan_0
doscan_89:  
doscan_93:  
	move.w	D5,A0
	subq.w	#1,D5
	cmp.w	#0,A0
	beq  	doscan_94
	moveq  	#120,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_96
	move.w	A2,-(A7)
	jsr  	_tolower
	addq.w	#2,A7
	moveq  	#97,D1
	cmp.w	D1,D0
	blt  	doscan_96
	move.w	A2,-(A7)
	jsr  	_toupper
	addq.w	#2,A7
	moveq  	#97,D1
	cmp.w	D1,D0
	ble  	doscan_95
doscan_96:  
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	beq  	doscan_94
doscan_95:  
	move.w	A2,D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	bne  	doscan_97
	move.w	A2,-(A7)
	jsr  	_tolower
	addq.w	#2,A7
	moveq  	#97,D1
	sub.w	D1,D0
	add.w	#10,D0
	moveq  	#48,D1
	add.w	D1,D0
	move.w	D0,A2
doscan_97:  
	move.l	D7,-(A7)
	move.l	-118(A6),-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.w	A2,D1
	ext.l	D1
	add.l	D1,D0
	moveq  	#48,D1
	sub.l	D1,D0
	move.l	D0,D7
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	moveq  	#1,D6
	bra  	doscan_93
doscan_94:  
	move.w	A2,D0
	cmp.w	D4,D0
	beq  	doscan_99
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	subq.w	#1,scan_count
	tst.w	D6
	bne  	doscan_101
	move.l	D2,D0
	bra  	doscan_0
doscan_101:  
	bra  	doscan_100
doscan_99:  
	tst.w	D6
	bne  	doscan_103
	tst.w	D2
	beq  	doscan_105
	move.w	D2,D0
	bra  	doscan_106
doscan_105:  
	move.w	D4,D0
doscan_106:  
	bra  	doscan_0
doscan_103:  
doscan_100:  
	tst.w	-92(A6)
	beq  	doscan_107
	move.l	D7,D0
	neg.l	D0
	move.l	D0,D7
doscan_107:  
	tst.w	D3
	bne  	doscan_109
	tst.w	-108(A6)
	beq  	doscan_111
	move.l	D7,(A5)
	bra  	doscan_112
doscan_111:  
	tst.w	-110(A6)
	beq  	doscan_113
	move.l	D7,D0
	move.w	D0,(A5)
	bra  	doscan_114
doscan_113:  
	move.l	D7,D0
	move.w	D0,(A5)
doscan_114:  
doscan_112:  
	addq.w	#1,D2
doscan_109:  
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_115
	tst.w	D2
	beq  	doscan_117
	move.w	D2,D0
	bra  	doscan_118
doscan_117:  
	move.w	D4,D0
doscan_118:  
	bra  	doscan_0
doscan_115:  
	bra  	doscan_1
doscan_78:  
	moveq  	#37,D0
	move.w	A3,D1
	cmp.w	D0,D1
	bne  	doscan_119
	jsr  	(A4)
	move.w	D0,A2
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_121
	tst.w	D2
	beq  	doscan_123
	move.w	D2,D0
	bra  	doscan_124
doscan_123:  
	move.w	D4,D0
doscan_124:  
	bra  	doscan_0
doscan_121:  
	addq.w	#1,scan_count
	move.w	A2,D0
	cmp.w	A3,D0
	beq  	doscan_125
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	subq.w	#1,scan_count
	move.l	D2,D0
	bra  	doscan_0
doscan_125:  
	bra  	doscan_1
doscan_119:  
doscan_12:  
	jsr  	(A4)
	move.w	D0,A2
	addq.w	#1,scan_count
	move.w	A2,D0
	cmp.w	D4,D0
	bne  	doscan_127
	tst.w	D2
	beq  	doscan_129
	move.w	D2,D0
	bra  	doscan_130
doscan_129:  
	move.w	D4,D0
doscan_130:  
	bra  	doscan_0
doscan_127:  
	move.w	A2,D0
	cmp.w	A3,D0
	beq  	doscan_131
	move.w	A2,-(A7)
	move.l	12(A6),A0
	jsr  	(A0)
	addq.w	#2,A7
	subq.w	#1,scan_count
	move.l	D2,D0
	bra  	doscan_0
doscan_131:  
	bra  	doscan_1
doscan_2:  
	move.l	D2,D0
doscan_0:  
	movem.l	(A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
	unlk  	A6
	rts  
