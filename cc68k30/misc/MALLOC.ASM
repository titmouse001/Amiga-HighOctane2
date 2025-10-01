; MALLOC.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
malloc_base:
	ds.b	8
malloc_morecore:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.w	8(A6),D2
	cmp.w	#64,D2
	bge  	malloc_morecore_1
	moveq  	#64,D2
malloc_morecore_1:  
	move.w	D2,D0
	mulu  	#8,D0
	move.w	D0,-(A7)
	jsr  	_sbrk
	addq.w	#2,A7
	move.l	D0,A2
	moveq  	#-1,D0
	move.l	A2,D1
	cmp.l	D0,D1
	bne  	malloc_morecore_3
	moveq  	#0,D0
	bra  	malloc_morecore_0
malloc_morecore_3:  
	move.w	D2,2(A2)
	moveq  	#0,D0
	move.l	D0,4(A2)
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,-(A7)
	jsr  	_free
	addq.w	#4,A7
	move.l	__allocp,D0
malloc_morecore_0:  
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
malloc_locate:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	8(A6),D2
	move.l	__allocp,A2
malloc_locate_1:  
	move.l	D2,D0
	cmp.l	A2,D0
	ble  	malloc_locate_3
	move.l	D2,D0
	cmp.l	4(A2),D0
	ble  	malloc_locate_2
malloc_locate_3:  
	move.l	A2,D0
	cmp.l	4(A2),D0
	blt  	malloc_locate_4
	move.l	D2,D0
	cmp.l	A2,D0
	bgt  	malloc_locate_6
	move.l	D2,D0
	cmp.l	4(A2),D0
	bgt  	malloc_locate_4
malloc_locate_6:  
	bra  	malloc_locate_2
malloc_locate_4:  
	move.l	4(A2),A2
	bra  	malloc_locate_1
malloc_locate_2:  
	move.l	A2,D0
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
malloc_adjust:  
	link  	A6,#-2
	movem.l	D2/D3/D4/A2,-(A7)
	move.w	10(A6),D2
	move.l	12(A6),A2
	move.w	8(A6),D3
	move.w	D3,D0
	cmp.w	D2,D0
	beq  	malloc_adjust_3
	move.w	D3,D0
	subq.w	#1,D0
	cmp.w	D2,D0
	bne  	malloc_adjust_1
malloc_adjust_3:  
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	bra  	malloc_adjust_0
malloc_adjust_1:  
	move.w	D3,D0
	cmp.w	D2,D0
	ble  	malloc_adjust_4
	move.w	2(A2),D0
	sub.w	D2,D0
	move.w	D0,D4
	moveq  	#0,D0
	move.l	A2,A0
	move.w	D2,D1
	mulu  	#8,D1
	and.l	#65535,D1
	add.l	D1,A0
	move.l	D0,4(A0)
	move.l	A2,A0
	move.w	D2,D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.w	D4,2(A0)
	move.w	D2,2(A2)
	move.l	A2,A0
	move.w	D2,D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,-(A7)
	jsr  	_free
	addq.w	#4,A7
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	bra  	malloc_adjust_0
malloc_adjust_4:  
	moveq  	#0,D0
malloc_adjust_0:  
	movem.l	(A7)+,D2/D3/D4/A2
	unlk  	A6
	rts  
_realloc:  
	link  	A6,#-16
	movem.l	D2/D3/D4/D5/D6/A2/A3/A4,-(A7)
	move.l	8(A6),D5
	move.w	12(A6),D6
	move.l	#malloc_adjust,A4
	move.l	D5,A0
	moveq  	#8,D0
	and.l	#65535,D0
	sub.l	D0,A0
	move.l	A0,A2
	tst.l	4(A2)
	beq  	realloc_1
	moveq  	#0,D0
	bra  	realloc_0
realloc_1:  
	moveq  	#1,D0
	move.w	D6,D1
	addq.w	#8,D1
	subq.w	#1,D1
	and.l	#65535,D1
	divu  	#8,D1
	add.w	D1,D0
	move.w	D0,D3
	move.w	2(A2),D0
	cmp.w	D3,D0
	beq  	realloc_5
	move.w	2(A2),D0
	subq.w	#1,D0
	cmp.w	D3,D0
	bne  	realloc_3
realloc_5:  
	move.l	D5,D0
	bra  	realloc_0
realloc_3:  
	move.l	A2,-(A7)
	jsr  	malloc_locate
	addq.w	#4,A7
	move.l	D0,A3
	move.w	2(A2),D2
	move.w	D3,D0
	cmp.w	D2,D0
	bge  	realloc_6
	move.l	A2,-(A7)
	move.w	D3,-(A7)
	move.w	D2,-(A7)
	jsr  	(A4)
	addq.w	#8,A7
	bra  	realloc_0
realloc_6:  
	move.l	A2,A0
	move.w	2(A2),D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	cmp.l	4(A3),D0
	bne  	realloc_8
	move.l	4(A3),A0
	move.w	2(A0),D0
	add.w	D0,D2
	move.w	D2,2(A2)
	move.l	4(A3),A0
	move.l	4(A0),4(A3)
	move.l	A3,__allocp
	move.l	A2,-(A7)
	move.w	D3,-(A7)
	move.w	D2,-(A7)
	jsr  	(A4)
	addq.w	#8,A7
	move.l	D0,D4
	tst.l	D4
	beq  	realloc_10
	move.l	D4,D0
	bra  	realloc_0
realloc_10:  
realloc_8:  
	move.l	A3,A0
	move.w	2(A3),D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	cmp.l	A2,D0
	bne  	realloc_12
	move.w	2(A3),D0
	add.w	D0,D2
	move.w	D2,2(A3)
	move.w	2(A2),D0
	subq.w	#1,D0
	mulu  	#8,D0
	move.w	D0,-(A7)
	move.l	D5,-(A7)
	move.l	A3,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,-(A7)
	jsr  	_memcpy
	add.w	#10,A7
	move.l	A3,A2
	move.l	A2,-(A7)
	jsr  	malloc_locate
	addq.w	#4,A7
	move.l	D0,A3
	move.l	4(A2),4(A3)
	moveq  	#0,D0
	move.l	D0,4(A2)
	move.l	A3,__allocp
	move.l	A2,-(A7)
	move.w	D3,-(A7)
	move.w	D2,-(A7)
	jsr  	(A4)
	addq.w	#8,A7
	move.l	D0,D4
	tst.l	D4
	beq  	realloc_14
	move.l	D4,D0
	bra  	realloc_0
realloc_14:  
realloc_12:  
	move.w	D6,-(A7)
	jsr  	_malloc
	addq.w	#2,A7
	move.l	D0,A3
	moveq  	#0,D0
	move.l	A3,D1
	cmp.l	D0,D1
	bne  	realloc_16
	moveq  	#0,D0
	bra  	realloc_0
realloc_16:  
	move.w	D6,-(A7)
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,-(A7)
	move.l	A3,-(A7)
	jsr  	_memcpy
	add.w	#10,A7
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,-(A7)
	jsr  	_free
	addq.w	#4,A7
	move.l	A3,D0
realloc_0:  
	movem.l	(A7)+,D2/D3/D4/D5/D6/A2/A3/A4
	unlk  	A6
	rts  
_sbrk:  
	link  	A6,#-4
	movem.l	D2/A2,-(A7)
	move.l	#__heap,A2
	move.l	(A2),A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	moveq  	#1,D0
	and.l	#65535,D0
	sub.l	D0,A0
	move.l	A0,D0
	moveq  	#8,D1
	subq.w	#1,D1
	not.w	D1
	ext.l	D1
	and.l	D1,D0
	move.l	D0,D2
	move.w	8(A6),D0
	and.l	#65535,D0
	add.l	D0,(A2)
	move.l	__himem,A0
	sub.l	__stklen,A0
	move.l	(A2),D0
	cmp.l	A0,D0
	bge  	sbrk_1
	move.l	D2,D0
	bra  	sbrk_2
sbrk_1:  
	moveq  	#-1,D0
sbrk_2:  
	movem.l	(A7)+,D2/A2
	unlk  	A6
	rts  
_malloc:  
	link  	A6,#-10
	movem.l	D2/A2/A3/A4/A5,-(A7)
	move.l	#__allocp,A4
	move.l	#malloc_base,A5
	moveq  	#1,D0
	move.w	8(A6),D1
	addq.w	#8,D1
	subq.w	#1,D1
	and.l	#65535,D1
	divu  	#8,D1
	add.w	D1,D0
	move.w	D0,D2
	moveq  	#0,D0
	move.l	(A4),D1
	cmp.l	D0,D1
	bne  	malloc_1
	move.l	A5,(A4)
	move.l	A5,4(A5)
	clr.w	2(A5)
malloc_1:  
	move.l	(A4),A3
	move.l	4(A3),A2
malloc_3:  
	move.w	2(A2),D0
	cmp.w	D2,D0
	blt  	malloc_5
	move.w	2(A2),D0
	cmp.w	D2,D0
	bne  	malloc_7
	move.l	4(A2),4(A3)
	bra  	malloc_8
malloc_7:  
	move.l	A2,A0
	move.w	D2,D0
	muls  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,4(A3)
	move.w	2(A2),D0
	sub.w	D2,D0
	move.l	4(A3),A0
	move.w	D0,2(A0)
	move.l	4(A3),A0
	move.l	4(A2),4(A0)
	move.w	D2,2(A2)
malloc_8:  
	moveq  	#0,D0
	move.l	D0,4(A2)
	move.l	A3,(A4)
	move.l	A2,A0
	moveq  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	bra  	malloc_0
malloc_5:  
	move.l	A2,D0
	cmp.l	(A4),D0
	bne  	malloc_9
	move.w	D2,-(A7)
	jsr  	malloc_morecore
	addq.w	#2,A7
	move.l	D0,A2
	moveq  	#0,D0
	move.l	A2,D1
	cmp.l	D0,D1
	bne  	malloc_11
	moveq  	#0,D0
	bra  	malloc_0
malloc_11:  
malloc_9:  
	move.l	A2,A3
	move.l	4(A2),A2
	bra  	malloc_3
malloc_0:  
	movem.l	(A7)+,D2/A2/A3/A4/A5
	unlk  	A6
	rts  
_calloc:  
	link  	A6,#-6
	movem.l	D2/D3,-(A7)
	move.w	8(A6),D0
	mulu  	10(A6),D0
	move.w	D0,D3
	move.w	D3,-(A7)
	jsr  	_malloc
	addq.w	#2,A7
	move.l	D0,D2
	moveq  	#0,D0
	move.l	D2,D1
	cmp.l	D0,D1
	beq  	calloc_1
	move.w	D3,-(A7)
	moveq  	#0,D0
	move.w	D0,-(A7)
	move.l	D2,-(A7)
	jsr  	_memset
	addq.w	#8,A7
calloc_1:  
	move.l	D2,D0
	movem.l	(A7)+,D2/D3
	unlk  	A6
	rts  
_free:  
	link  	A6,#-8
	movem.l	A2/A3,-(A7)
	move.l	8(A6),A0
	moveq  	#8,D0
	and.l	#65535,D0
	sub.l	D0,A0
	move.l	A0,A3
	tst.l	4(A3)
	beq  	free_1
	bra  	free_0
free_1:  
	move.l	__allocp,A2
free_3:  
	move.l	A3,D0
	cmp.l	A2,D0
	ble  	free_5
	move.l	A3,D0
	cmp.l	4(A2),D0
	blt  	free_4
free_5:  
	move.l	A2,D0
	cmp.l	4(A2),D0
	blt  	free_6
	move.l	A3,D0
	cmp.l	A2,D0
	bgt  	free_8
	move.l	A3,D0
	cmp.l	4(A2),D0
	bge  	free_6
free_8:  
	bra  	free_4
free_6:  
	move.l	4(A2),A2
	bra  	free_3
free_4:  
	move.l	A3,A0
	move.w	2(A3),D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	cmp.l	4(A2),D0
	bne  	free_9
	move.l	4(A2),A0
	move.w	2(A0),D0
	add.w	D0,2(A3)
	move.l	4(A2),A0
	move.l	4(A0),4(A3)
	bra  	free_10
free_9:  
	move.l	4(A2),4(A3)
free_10:  
	move.l	A2,A0
	move.w	2(A2),D0
	mulu  	#8,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,D0
	cmp.l	A3,D0
	bne  	free_11
	move.w	2(A3),D0
	add.w	D0,2(A2)
	move.l	4(A3),4(A2)
	bra  	free_12
free_11:  
	move.l	A3,4(A2)
free_12:  
	move.l	A2,__allocp
free_0:  
	movem.l	(A7)+,A2/A3
	unlk  	A6
	rts  
