; STRING.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
_strcat:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
strcat_1:  
	tst.b	(A2)
	beq  	strcat_2
	addq.w	#1,A2
	bra  	strcat_1
strcat_2:  
strcat_3:  
	move.l	12(A6),A0
	addq.l	#1,12(A6)
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	tst.b	(A1)
	beq  	strcat_4
	bra  	strcat_3
strcat_4:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_strchr:  
	link  	A6,#0
	movem.l	D2/A2,-(A7)
	move.l	8(A6),A2
	move.w	12(A6),D2
strchr_1:  
	move.b	(A2),D0
	ext.w	D0
	move.w	D2,D1
	cmp.w	D0,D1
	beq  	strchr_2
	tst.b	(A2)
	beq  	strchr_2
	addq.w	#1,A2
	bra  	strchr_1
strchr_2:  
	tst.w	D2
	beq  	strchr_3
	move.b	(A2),D0
	ext.w	D0
	tst.w	D0
	bne  	strchr_3
	moveq  	#0,D0
	bra  	strchr_0
strchr_3:  
	move.l	A2,D0
strchr_0:  
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_strcmp:  
	link  	A6,#0
	movem.l	A2/A3,-(A7)
	move.l	8(A6),A2
	move.l	12(A6),A3
strcmp_1:  
	move.b	(A2),D0
	cmp.b	(A3),D0
	bne  	strcmp_2
	tst.b	(A2)
	bne  	strcmp_3
	bra  	strcmp_2
strcmp_3:  
	addq.w	#1,A2
	addq.w	#1,A3
	bra  	strcmp_1
strcmp_2:  
	move.b	(A2),D0
	sub.b	(A3),D0
	movem.l	(A7)+,A2/A3
	unlk  	A6
	rts  
_strcpy:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
strcpy_1:  
	move.l	12(A6),A0
	addq.l	#1,12(A6)
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	tst.b	(A1)
	beq  	strcpy_2
	bra  	strcpy_1
strcpy_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_strcspn:  
	link  	A6,#-6
	movem.l	A2/A3/A4,-(A7)
	move.l	8(A6),A4
	move.w	#0,A2
strcspn_1:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A4,A0
	add.l	D0,A0
	tst.b	(A0)
	beq  	strcspn_2
	move.l	12(A6),A3
strcspn_3:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A4,A0
	add.l	D0,A0
	move.b	(A3),D0
	cmp.b	(A0),D0
	beq  	strcspn_4
	tst.b	(A3)
	beq  	strcspn_4
	addq.w	#1,A3
	bra  	strcspn_3
strcspn_4:  
	tst.b	(A3)
	beq  	strcspn_5
	bra  	strcspn_2
strcspn_5:  
	addq.w	#1,A2
	bra  	strcspn_1
strcspn_2:  
	move.l	A2,D0
	movem.l	(A7)+,A2/A3/A4
	unlk  	A6
	rts  
_strlen:  
	link  	A6,#-2
	move.l	D2,-(A7)
	moveq  	#0,D2
strlen_1:  
	move.l	8(A6),A0
	addq.l	#1,8(A6)
	tst.b	(A0)
	beq  	strlen_2
	addq.w	#1,D2
	bra  	strlen_1
strlen_2:  
	move.l	D2,D0
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_strupr:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
strupr_1:  
	tst.b	(A2)
	beq  	strupr_2
	move.b	(A2),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	_toupper
	addq.w	#2,A7
	move.b	D0,(A2)
	addq.w	#1,A2
	bra  	strupr_1
strupr_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_strlwr:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
strlwr_1:  
	tst.b	(A2)
	beq  	strlwr_2
	move.b	(A2),D0
	ext.w	D0
	move.w	D0,-(A7)
	jsr  	_tolower
	addq.w	#2,A7
	move.b	D0,(A2)
	addq.w	#1,A2
	bra  	strlwr_1
strlwr_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_strncat:  
	link  	A6,#-4
	movem.l	D2/D3/A2,-(A7)
	move.l	8(A6),D2
	move.w	16(A6),D3
	move.l	D2,A2
	tst.w	D3
	bne  	strncat_1
	move.l	D2,D0
	bra  	strncat_0
strncat_1:  
strncat_3:  
	tst.b	(A2)
	beq  	strncat_4
	addq.w	#1,A2
	bra  	strncat_3
strncat_4:  
strncat_5:  
	move.l	12(A6),A0
	addq.l	#1,12(A6)
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	tst.b	(A1)
	beq  	strncat_6
	subq.w	#1,D3
	tst.w	D3
	beq  	strncat_6
	bra  	strncat_5
strncat_6:  
	tst.w	D3
	bne  	strncat_7
	clr.b	(A2)
strncat_7:  
	move.l	D2,D0
strncat_0:  
	movem.l	(A7)+,D2/D3/A2
	unlk  	A6
	rts  
_strncmp:  
	link  	A6,#0
	movem.l	D2/A2/A3,-(A7)
	move.l	8(A6),A2
	move.l	12(A6),A3
	move.w	16(A6),D2
	tst.w	D2
	beq  	strncmp_1
strncmp_3:  
	move.b	(A2),D0
	cmp.b	(A3),D0
	bne  	strncmp_4
	subq.w	#1,D2
	tst.w	D2
	beq  	strncmp_4
	tst.b	(A2)
	bne  	strncmp_5
	bra  	strncmp_4
strncmp_5:  
	addq.w	#1,A2
	addq.w	#1,A3
	bra  	strncmp_3
strncmp_4:  
strncmp_1:  
	move.b	(A2),D0
	sub.b	(A3),D0
	movem.l	(A7)+,D2/A2/A3
	unlk  	A6
	rts  
_strncpy:  
	link  	A6,#-4
	movem.l	D2/D3/A2,-(A7)
	move.w	16(A6),D2
	move.l	8(A6),D3
	move.l	D3,A2
	tst.w	D2
	beq  	strncpy_1
strncpy_3:  
	move.l	12(A6),A0
	addq.l	#1,12(A6)
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	tst.b	(A1)
	beq  	strncpy_4
	subq.w	#1,D2
	tst.w	D2
	beq  	strncpy_4
	bra  	strncpy_3
strncpy_4:  
strncpy_5:  
	subq.w	#1,D2
	tst.w	D2
	ble  	strncpy_6
	move.l	A2,A0
	addq.w	#1,A2
	clr.b	(A0)
	bra  	strncpy_5
strncpy_6:  
strncpy_1:  
	move.l	D3,D0
	movem.l	(A7)+,D2/D3/A2
	unlk  	A6
	rts  
_strpbrk:  
	link  	A6,#-4
	movem.l	A2/A3,-(A7)
	move.l	8(A6),A3
strpbrk_1:  
	tst.b	(A3)
	beq  	strpbrk_2
	move.l	12(A6),A2
strpbrk_3:  
	move.b	(A2),D0
	cmp.b	(A3),D0
	beq  	strpbrk_4
	tst.b	(A2)
	beq  	strpbrk_4
	addq.w	#1,A2
	bra  	strpbrk_3
strpbrk_4:  
	tst.b	(A2)
	beq  	strpbrk_5
	move.l	A3,D0
	bra  	strpbrk_0
strpbrk_5:  
	addq.w	#1,A3
	bra  	strpbrk_1
strpbrk_2:  
	moveq  	#0,D0
strpbrk_0:  
	movem.l	(A7)+,A2/A3
	unlk  	A6
	rts  
_strrchr:  
	link  	A6,#-4
	movem.l	D2/D3/A2,-(A7)
	move.l	8(A6),A2
	move.w	12(A6),D3
	moveq  	#0,D0
	move.l	D0,D2
strrchr_1:  
	tst.b	(A2)
	beq  	strrchr_2
	move.b	(A2),D0
	ext.w	D0
	cmp.w	D3,D0
	bne  	strrchr_3
	move.l	A2,D2
strrchr_3:  
	addq.w	#1,A2
	bra  	strrchr_1
strrchr_2:  
	moveq  	#0,D0
	move.w	D3,D1
	cmp.w	D0,D1
	bne  	strrchr_5
	move.l	A2,D2
strrchr_5:  
	move.l	D2,D0
	movem.l	(A7)+,D2/D3/A2
	unlk  	A6
	rts  
_strspn:  
	link  	A6,#-6
	movem.l	A2/A3/A4,-(A7)
	move.l	8(A6),A4
	move.w	#0,A2
strspn_1:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A4,A0
	add.l	D0,A0
	tst.b	(A0)
	beq  	strspn_2
	move.l	12(A6),A3
strspn_3:  
	move.w	A2,D0
	and.l	#65535,D0
	move.l	A4,A0
	add.l	D0,A0
	move.b	(A3),D0
	cmp.b	(A0),D0
	beq  	strspn_4
	tst.b	(A3)
	beq  	strspn_4
	addq.w	#1,A3
	bra  	strspn_3
strspn_4:  
	tst.b	(A3)
	bne  	strspn_5
	bra  	strspn_2
strspn_5:  
	addq.w	#1,A2
	bra  	strspn_1
strspn_2:  
	move.l	A2,D0
	movem.l	(A7)+,A2/A3/A4
	unlk  	A6
	rts  
strtok_olds1:
	ds.b	4
strtok_oldchar:
	ds.b	1
_strtok:  
	link  	A6,#0
	movem.l	D2/A2/A3,-(A7)
	move.l	8(A6),A2
	move.l	#strtok_olds1,A3
	move.l	12(A6),D2
	moveq  	#0,D0
	move.l	A2,D1
	cmp.l	D0,D1
	bne  	strtok_1
	move.l	(A3),A2
	move.b	strtok_oldchar,(A2)
strtok_1:  
strtok_3:  
	tst.b	(A2)
	beq  	strtok_4
	move.b	(A2),D0
	ext.w	D0
	move.w	D0,-(A7)
	move.l	D2,-(A7)
	jsr  	_strchr
	addq.w	#6,A7
	tst.l	D0
	beq  	strtok_4
	addq.w	#1,A2
	bra  	strtok_3
strtok_4:  
	move.l	A2,(A3)
	tst.b	(A2)
	bne  	strtok_5
	moveq  	#0,D0
	bra  	strtok_0
strtok_5:  
strtok_7:  
	addq.l	#1,(A3)
	move.l	(A3),A0
	tst.b	(A0)
	beq  	strtok_9
	move.l	(A3),A0
	move.b	(A0),D0
	ext.w	D0
	move.w	D0,-(A7)
	move.l	D2,-(A7)
	jsr  	_strchr
	addq.w	#6,A7
	moveq  	#0,D1
	cmp.l	D1,D0
	beq  	strtok_7
strtok_9:  
	move.l	(A3),A0
	move.b	(A0),strtok_oldchar
	move.l	(A3),A0
	clr.b	(A0)
	move.l	A2,D0
strtok_0:  
	movem.l	(A7)+,D2/A2/A3
	unlk  	A6
	rts  
_memcpy:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
memcpy_1:  
	move.w	16(A6),A0
	subq.w	#1,16(A6)
	cmp.w	#0,A0
	beq  	memcpy_2
	move.l	12(A6),A0
	addq.l	#1,12(A6)
	move.l	A2,A1
	addq.w	#1,A2
	move.b	(A0),(A1)
	bra  	memcpy_1
memcpy_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_memmove:  
	link  	A6,#-4
	movem.l	D2/A2/A3/A4,-(A7)
	move.l	8(A6),A2
	move.w	16(A6),D2
	move.l	12(A6),A3
	move.l	A3,D0
	sub.l	A2,D0
	move.w	D2,D1
	and.l	#65535,D1
	cmp.l	D1,D0
	bge  	memmove_1
	move.w	D2,D0
	and.l	#65535,D0
	add.l	D0,A2
	move.w	D2,D0
	and.l	#65535,D0
	add.l	D0,A3
memmove_3:  
	move.w	D2,A0
	subq.w	#1,D2
	cmp.w	#0,A0
	beq  	memmove_4
	move.l	A3,A0
	subq.w	#1,A3
	move.l	A2,A1
	subq.w	#1,A2
	move.b	(A0),(A1)
	bra  	memmove_3
memmove_4:  
	bra  	memmove_2
memmove_1:  
	move.l	A2,A4
memmove_5:  
	move.w	D2,A0
	subq.w	#1,D2
	cmp.w	#0,A0
	beq  	memmove_6
	move.l	A3,A0
	addq.w	#1,A3
	move.l	A4,A1
	addq.w	#1,A4
	move.b	(A0),(A1)
	bra  	memmove_5
memmove_6:  
memmove_2:  
	move.l	A2,D0
	movem.l	(A7)+,D2/A2/A3/A4
	unlk  	A6
	rts  
_memchr:  
	link  	A6,#0
	movem.l	D2/A2,-(A7)
	move.l	8(A6),A2
	move.w	14(A6),D2
memchr_1:  
	move.w	D2,A0
	subq.w	#1,D2
	cmp.w	#0,A0
	beq  	memchr_2
	move.w	12(A6),D0
	cmp.w	(A2),D0
	bne  	memchr_3
	bra  	memchr_2
memchr_3:  
	addq.w	#2,A2
	bra  	memchr_1
memchr_2:  
	tst.w	D2
	beq  	memchr_5
	move.l	A2,D0
	bra  	memchr_6
memchr_5:  
	moveq  	#0,D0
memchr_6:  
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_memset:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	D2,A2
memset_1:  
	move.w	14(A6),A0
	subq.w	#1,14(A6)
	cmp.w	#0,A0
	beq  	memset_2
	move.w	12(A6),D0
	move.l	A2,A0
	addq.w	#1,A2
	move.b	D0,(A0)
	bra  	memset_1
memset_2:  
	move.l	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_memcmp:  
	link  	A6,#0
	movem.l	D2/A2,-(A7)
	move.l	8(A6),A2
	move.w	12(A6),D2
memcmp_1:  
	move.w	(A2),D0
	cmp.w	D2,D0
	bne  	memcmp_2
	move.w	14(A6),A0
	subq.w	#1,14(A6)
	cmp.w	#0,A0
	beq  	memcmp_3
	bra  	memcmp_2
memcmp_3:  
	addq.w	#2,A2
	bra  	memcmp_1
memcmp_2:  
	move.w	(A2),D0
	sub.w	D2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
