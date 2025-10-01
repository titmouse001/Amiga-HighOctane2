
	************	Entry: d0,d1 = x,y,
	*** TEXT ***	       a2 = pointer to ascii string
	************

Txt: 	movem.l	d0-d5/a0-a2,-(sp)
	lsr	#3,d0
	and.l	#$ffff,d0
 	mulu	#((PANEL_WIDTH)/8)*2,d1
	add.l	d1,d0
next_char:
	moveq	#0,d2
	move.b	(a2)+,d2 ; c
	tst.b	d2
	beq.s	null_char

	move.l	FixedPanelBuffer,a0
 	add.l	d0,a0

	lsl.w	#3,d2
	add	d2,d2
	move.l	FontBuffer,a1
	add.l	d2,a1		; a1 - address of char to print

	moveq	#7,d3
next_data:
  	move.w	(a1)+,d1
  	lsr.w	#8,d1

    	move.b	d1,(a0)
	move.b	d1,(PANEL_WIDTH/8)(a0)
	lea	(PANEL_WIDTH/8)*2(a0),a0

	dbra	d3,next_data

	add.w	#1,d0
	bra	next_char
null_char:
	movem.l	(sp)+,d0-d5/a0-a2
	rts


;-----------------------------------------------------
;
;	************	Entry: d0,d1 = x,y,
;	*** TEXT ***	       a2 = pointer to ascii string
;	************

MenuTxt:
	movem.l	d0-d5/a0-a2,-(sp)

	lsr	#3,d0
	and.l	#$ffff,d0

	lsl.l	#8,d1  ;512/8*BITPLANES
;;;;;;;	mulu	#((320/8)+(OVERRUN*2/8))*4,d1
	add.l	d1,d0

.next_char

	moveq	#0,d2
	move.b	(a2)+,d2 
	tst.b	d2
	beq.s	.null_char

	move.l	LogicScreenBuffer,a0
	add.l	d0,a0


	lsl.w	#3,d2
	add	d2,d2
	move.l	FontBuffer,a1
	add.l	d2,a1		; a1 - address of char to print

	moveq	#7,d3
.next_data
  	move.w	(a1)+,d1
 	lsr.w	#8,d1

;  	move.b	d1,512/8*0(a0)
  	move.b 	d1,512/8*1(a0) ; 2=white
;  	move.b	d1,512/8*2(a0)
;  	move.b	d1,512/8*3(a0)
  	
;;;;	move.b	d1,(320/8)+(OVERRUN*2/8)(a0)

;;;	lea	((320/8)+(OVERRUN*2/8))*4(a0),a0

	lea (512/8*BITPLANES)(a0),a0		

	dbra	d3,.next_data

	add.w	#1,d0
	bra	.next_char
.null_char
	movem.l	(sp)+,d0-d5/a0-a2
	rts


