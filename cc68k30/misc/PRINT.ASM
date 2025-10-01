; PRINT.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
print_cbuf:
	ds.b	4
print_cmov:  
	link  	A6,#0
	move.w	8(A6),D0
	move.l	print_cbuf,A0
	addq.l	#1,print_cbuf
	move.b	D0,(A0)
	moveq  	#0,D0
	unlk  	A6
	rts  
print_setval:  
	link  	A6,#-2
	movem.l	D2/A2,-(A7)
	move.l	8(A6),A2
	moveq  	#0,D2
	move.l	(A2),A0
	cmp.b	#42,(A0)
	bne  	print_setval_1
	move.l	12(A6),A0
	move.l	(A0),A0
	addq.l	#2,(A0)
	move.w	(A0),D2
	addq.l	#1,(A2)
	bra  	print_setval_2
print_setval_1:  
print_setval_3:  
	move.l	(A2),A0
	move.b	(A0),D0
	ext.w	D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#4,D0
	tst.w	D0
	beq  	print_setval_4
	move.w	D2,D0
	muls  	#10,D0
	move.l	(A2),A0
	addq.l	#1,(A2)
	move.b	(A0),D1
	sub.b	#48,D1
	ext.w	D1
	add.w	D1,D0
	move.w	D0,D2
	bra  	print_setval_3
print_setval_4:  
print_setval_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
print_doprint_prefix:
	ds.b	10
print_doprint_string:
	ds.b	100
print_doprint:  
	link  	A6,#-34
	movem.l	D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
	lea  	12(A6),A0
	move.l	A0,A4
	moveq  	#-1,D5
	move.l	8(A6),A5
	moveq  	#0,D2
print_doprint_1:  
	move.l	12(A6),A0
	tst.b	(A0)
	beq  	print_doprint_2
	move.l	12(A6),A0
	cmp.b	#37,(A0)
	beq  	print_doprint_3
	move.l	12(A6),A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_5
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_5:  
	addq.w	#1,D2
	addq.l	#1,12(A6)
	bra  	print_doprint_1
print_doprint_3:  
	addq.l	#1,12(A6)
	move.l	#print_doprint_string,A2
	clr.w	-20(A6)
	move.w	-20(A6),-14(A6)
	move.w	-14(A6),-10(A6)
	move.w	-10(A6),-8(A6)
	move.w	-8(A6),-6(A6)
	move.w	-6(A6),-4(A6)
	clr.w	-24(A6)
	move.w	-24(A6),D7
	move.w	D5,D3
print_doprint_7:  
	move.l	12(A6),A0
	move.b	(A0),D0
	cmp.b	#45,D0
	beq  	print_doprint_9
	cmp.b	#43,D0
	beq  	print_doprint_10
	cmp.b	#32,D0
	beq  	print_doprint_11
	cmp.b	#35,D0
	beq  	print_doprint_12
	bra  	print_doprint_13
print_doprint_9:  
	addq.l	#1,12(A6)
	move.w	#1,-4(A6)
	bra  	print_doprint_7
print_doprint_10:  
	addq.l	#1,12(A6)
	move.w	#1,-6(A6)
	bra  	print_doprint_7
print_doprint_11:  
	addq.l	#1,12(A6)
	move.w	#1,-8(A6)
	bra  	print_doprint_7
print_doprint_12:  
	addq.l	#1,12(A6)
	move.w	#1,-10(A6)
	bra  	print_doprint_7
print_doprint_13:  
	move.l	12(A6),A0
	cmp.b	#48,(A0)
	bne  	print_doprint_14
	addq.l	#1,12(A6)
	move.w	#1,-14(A6)
print_doprint_14:  
	lea  	16(A6),A0
	move.l	A0,-(A7)
	move.l	A4,-(A7)
	jsr  	print_setval
	addq.w	#8,A7
	move.w	D0,D7
	move.l	12(A6),A0
	cmp.b	#46,(A0)
	bne  	print_doprint_16
	addq.l	#1,12(A6)
	lea  	16(A6),A0
	move.l	A0,-(A7)
	move.l	A4,-(A7)
	jsr  	print_setval
	addq.w	#8,A7
	move.w	D0,D3
print_doprint_16:  
	move.l	12(A6),A0
	cmp.b	#108,(A0)
	bne  	print_doprint_18
	addq.l	#1,12(A6)
	move.w	#1,-20(A6)
print_doprint_18:  
	move.l	12(A6),A0
	move.b	(A0),D0
	cmp.b	#105,D0
	beq  	print_doprint_20
	cmp.b	#100,D0
	beq  	print_doprint_21
	cmp.b	#111,D0
	beq  	print_doprint_22
	cmp.b	#88,D0
	beq  	print_doprint_23
	cmp.b	#120,D0
	beq  	print_doprint_24
	cmp.b	#117,D0
	beq  	print_doprint_25
	cmp.b	#99,D0
	beq  	print_doprint_26
	cmp.b	#115,D0
	beq  	print_doprint_27
	bra  	print_doprint_28
print_doprint_20:  
print_doprint_21:  
	tst.w	-20(A6)
	beq  	print_doprint_30
	move.w	#10,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#4,16(A6)
	move.l	(A0),-(A7)
	jsr  	_ltoa
	add.w	#10,A7
	bra  	print_doprint_31
print_doprint_30:  
	move.w	#10,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#2,16(A6)
	move.w	(A0),D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	_ltoa
	add.w	#10,A7
print_doprint_31:  
	bra  	print_doprint_29
print_doprint_22:  
	tst.w	-20(A6)
	beq  	print_doprint_32
	move.w	#8,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#4,16(A6)
	move.l	(A0),-(A7)
	jsr  	_ultoa
	add.w	#10,A7
	bra  	print_doprint_33
print_doprint_32:  
	move.w	#8,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#2,16(A6)
	move.w	(A0),D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	_ultoa
	add.w	#10,A7
print_doprint_33:  
	bra  	print_doprint_29
print_doprint_23:  
print_doprint_24:  
	tst.w	-20(A6)
	beq  	print_doprint_34
	move.w	#16,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#4,16(A6)
	move.l	(A0),-(A7)
	jsr  	_ultoa
	add.w	#10,A7
	bra  	print_doprint_35
print_doprint_34:  
	move.w	#16,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#2,16(A6)
	move.w	(A0),D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	_ultoa
	add.w	#10,A7
print_doprint_35:  
	bra  	print_doprint_29
print_doprint_25:  
	tst.w	-20(A6)
	beq  	print_doprint_36
	move.w	#10,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#4,16(A6)
	move.l	(A0),-(A7)
	jsr  	_ultoa
	add.w	#10,A7
	bra  	print_doprint_37
print_doprint_36:  
	move.w	#10,-(A7)
	move.l	A2,-(A7)
	move.l	16(A6),A0
	addq.l	#2,16(A6)
	move.w	(A0),D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	_ultoa
	add.w	#10,A7
print_doprint_37:  
	bra  	print_doprint_29
print_doprint_26:  
	move.l	16(A6),A0
	addq.l	#2,16(A6)
	move.w	(A0),D0
	move.l	A2,A0
	addq.w	#1,A2
	move.b	D0,(A0)
	clr.b	(A2)
	tst.w	D7
	beq  	print_doprint_38
	move.w	D7,D0
	bra  	print_doprint_39
print_doprint_38:  
	moveq  	#1,D0
print_doprint_39:  
	move.w	D0,D3
	bra  	print_doprint_29
print_doprint_27:  
	move.l	16(A6),A0
	addq.l	#4,16(A6)
	move.l	(A0),A2
	move.w	D3,D0
	cmp.w	D5,D0
	bne  	print_doprint_40
	move.l	A2,-(A7)
	jsr  	_strlen
	addq.w	#4,A7
	move.w	D0,D3
print_doprint_40:  
	bra  	print_doprint_29
print_doprint_28:  
	move.l	12(A6),A0
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	clr.b	(A2)
print_doprint_29:  
	move.l	A2,-(A7)
	jsr  	_strlen
	addq.w	#4,A7
	move.w	D0,D4
	move.l	12(A6),A0
	cmp.b	#115,(A0)
	bne  	print_doprint_42
	tst.w	D3
	blt  	print_doprint_42
	move.w	D4,D0
	cmp.w	D3,D0
	ble  	print_doprint_44
	move.w	D3,D0
	bra  	print_doprint_45
print_doprint_44:  
	move.w	D4,D0
print_doprint_45:  
	move.w	D0,D4
print_doprint_42:  
	moveq  	#0,D6
	move.l	#print_doprint_prefix,A3
	move.l	12(A6),A0
	cmp.b	#100,(A0)
	beq  	print_doprint_48
	move.l	12(A6),A0
	cmp.b	#105,(A0)
	bne  	print_doprint_46
print_doprint_48:  
	tst.w	-6(A6)
	bne  	print_doprint_51
	cmp.b	#45,(A2)
	bne  	print_doprint_49
print_doprint_51:  
	cmp.b	#45,(A2)
	bne  	print_doprint_52
	move.l	A2,A0
	addq.w	#1,A2
	move.l	A3,A1
	addq.w	#1,A3
	move.b	(A0),(A1)
	subq.w	#1,D4
	bra  	print_doprint_53
print_doprint_52:  
	move.l	A3,A0
	addq.w	#1,A3
	move.b	#43,(A0)
print_doprint_53:  
	addq.w	#1,D6
	bra  	print_doprint_50
print_doprint_49:  
	tst.w	-8(A6)
	beq  	print_doprint_54
	cmp.b	#45,(A2)
	bne  	print_doprint_56
	move.l	A2,A0
	addq.w	#1,A2
	move.l	A3,A1
	addq.w	#1,A3
	move.b	(A0),(A1)
	subq.w	#1,D4
	bra  	print_doprint_57
print_doprint_56:  
	move.l	A3,A0
	addq.w	#1,A3
	move.b	#32,(A0)
print_doprint_57:  
	addq.w	#1,D6
print_doprint_54:  
print_doprint_50:  
print_doprint_46:  
	tst.w	-10(A6)
	beq  	print_doprint_58
	move.l	12(A6),A0
	move.b	(A0),D0
	cmp.b	#111,D0
	beq  	print_doprint_60
	cmp.b	#88,D0
	beq  	print_doprint_61
	cmp.b	#120,D0
	beq  	print_doprint_62
	bra  	print_doprint_63
print_doprint_60:  
print_doprint_61:  
print_doprint_62:  
	move.l	A3,A0
	addq.w	#1,A3
	move.b	#48,(A0)
	addq.w	#1,D6
	move.l	12(A6),A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	_tolower
	addq.w	#2,A7
	moveq  	#120,D1
	cmp.w	D1,D0
	bne  	print_doprint_64
	move.l	A3,A0
	addq.w	#1,A3
	move.b	#120,(A0)
	addq.w	#1,D6
print_doprint_64:  
print_doprint_63:  
print_doprint_58:  
	clr.b	(A3)
	move.l	12(A6),A0
	move.b	(A0),D0
	ext.w	D0
	addq.w	#1,D0
	and.l	#65535,D0
	move.l	#__ctype,A0
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	and.w	#2,D0
	tst.w	D0
	beq  	print_doprint_66
	move.l	#print_doprint_prefix,A3
print_doprint_68:  
	tst.b	(A3)
	beq  	print_doprint_69
	move.b	(A3),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	_toupper
	addq.w	#2,A7
	move.b	D0,(A3)
	addq.w	#1,A3
	bra  	print_doprint_68
print_doprint_69:  
	move.l	A2,A3
print_doprint_70:  
	tst.b	(A3)
	beq  	print_doprint_71
	move.b	(A3),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	_toupper
	addq.w	#2,A7
	move.b	D0,(A3)
	addq.w	#1,A3
	bra  	print_doprint_70
print_doprint_71:  
print_doprint_66:  
	move.l	12(A6),A0
	move.b	(A0),D0
	cmp.b	#105,D0
	beq  	print_doprint_72
	cmp.b	#100,D0
	beq  	print_doprint_73
	cmp.b	#111,D0
	beq  	print_doprint_74
	cmp.b	#88,D0
	beq  	print_doprint_75
	cmp.b	#120,D0
	beq  	print_doprint_76
	cmp.b	#117,D0
	beq  	print_doprint_77
	cmp.b	#115,D0
	beq  	print_doprint_78
	cmp.b	#99,D0
	beq  	print_doprint_79
	bra  	print_doprint_80
print_doprint_72:  
print_doprint_73:  
print_doprint_74:  
print_doprint_75:  
print_doprint_76:  
print_doprint_77:  
	tst.w	-14(A6)
	beq  	print_doprint_82
	tst.w	-4(A6)
	bne  	print_doprint_82
	move.w	D7,D0
	sub.w	D6,D0
	sub.w	D4,D0
	move.w	D0,-24(A6)
print_doprint_82:  
print_doprint_78:  
print_doprint_79:  
	tst.w	-24(A6)
	bge  	print_doprint_84
	clr.w	-24(A6)
print_doprint_84:  
	tst.w	-4(A6)
	bne  	print_doprint_86
	move.w	D4,D0
	add.w	-24(A6),D0
	add.w	D6,D0
	move.w	D0,-12(A6)
print_doprint_88:  
	move.w	D7,A0
	subq.w	#1,D7
	move.w	-12(A6),D0
	cmp.w	A0,D0
	bge  	print_doprint_89
	moveq  	#32,D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_90
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_90:  
	addq.w	#1,D2
	bra  	print_doprint_88
print_doprint_89:  
print_doprint_86:  
	move.l	#print_doprint_prefix,A3
print_doprint_92:  
	tst.b	(A3)
	beq  	print_doprint_93
	move.l	A3,A0
	addq.w	#1,A3
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_94
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_94:  
	addq.w	#1,D2
	bra  	print_doprint_92
print_doprint_93:  
	move.w	-24(A6),-12(A6)
print_doprint_96:  
	move.w	-12(A6),A0
	subq.w	#1,-12(A6)
	cmp.w	#0,A0
	beq  	print_doprint_97
	moveq  	#48,D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_98
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_98:  
	addq.w	#1,D2
	bra  	print_doprint_96
print_doprint_97:  
print_doprint_100:  
	tst.b	(A2)
	beq  	print_doprint_101
	move.l	12(A6),A0
	move.b	(A0),D0
	cmp.b	#115,D0
	beq  	print_doprint_102
	cmp.b	#99,D0
	beq  	print_doprint_103
	bra  	print_doprint_104
print_doprint_102:  
print_doprint_103:  
	move.w	D3,A0
	subq.w	#1,D3
	cmp.w	#0,A0
	bgt  	print_doprint_106
	bra  	print_doprint_105
print_doprint_106:  
print_doprint_104:  
	move.l	A2,A0
	addq.w	#1,A2
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_108
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_108:  
	addq.w	#1,D2
	bra  	print_doprint_100
print_doprint_105:  
print_doprint_101:  
	tst.w	-4(A6)
	beq  	print_doprint_110
	move.w	D4,D0
	add.w	-24(A6),D0
	add.w	D6,D0
	move.w	D0,-12(A6)
print_doprint_112:  
	move.w	D7,A0
	subq.w	#1,D7
	move.w	-12(A6),D0
	cmp.w	A0,D0
	bge  	print_doprint_113
	moveq  	#32,D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_114
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_114:  
	subq.w	#1,D2
	bra  	print_doprint_112
print_doprint_113:  
print_doprint_110:  
	bra  	print_doprint_81
print_doprint_80:  
	move.l	12(A6),A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	(A5)
	addq.w	#2,A7
	cmp.w	D5,D0
	bne  	print_doprint_116
	move.l	D5,D0
	bra  	print_doprint_0
print_doprint_116:  
	addq.w	#1,D2
print_doprint_81:  
	addq.l	#1,12(A6)
	bra  	print_doprint_1
print_doprint_2:  
	move.l	D2,D0
print_doprint_0:  
	movem.l	(A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
	unlk  	A6
	rts  
_printf:  
	link  	A6,#0
	lea  	12(A6),A0
	move.l	A0,-(A7)
	move.l	8(A6),-(A7)
	move.l	#_putch,-(A7)
	jsr  	print_doprint
	add.w	#12,A7
	unlk  	A6
	rts  
_sprintf:  
	link  	A6,#-2
	move.l	D2,-(A7)
	move.l	8(A6),print_cbuf
	lea  	16(A6),A0
	move.l	A0,-(A7)
	move.l	12(A6),-(A7)
	move.l	#print_cmov,-(A7)
	jsr  	print_doprint
	add.w	#12,A7
	move.w	D0,D2
	move.l	print_cbuf,A0
	clr.b	(A0)
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
