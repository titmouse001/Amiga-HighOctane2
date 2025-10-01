; C_ASM.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
_main:  
	link  	A6,#-8
	move.l	D2,-(A7)
	moveq  	#0,D0
	move.l	D0,D2
main_1:  
	moveq  	#10,D0
	move.l	D2,D1
	cmp.l	D0,D1
	bge  	main_2
	move.l	D2,D0
	add.l	D0,-8(A6)
	addq.l	#1,D2
	bra  	main_1
main_2:  
	jsr  	_func2
	move.l	(A7)+,D2
	unlk  	A6
	rts  
_func2:  
	link  	A6,#-2
	move.w	#1,-2(A6)
	unlk  	A6
	rts  
