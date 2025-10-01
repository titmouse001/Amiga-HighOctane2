	EVEN

____NOTUSED____Lev4AudioInterrupt:
	;Triggered by the hardware, after the samples
	;have finnished playing...

	movem.l	d0-d7/a0-6,-(sp)

	move.w	INTREQR+CUSTOM,d0
	and.w	#%11110000000,d0
	move.w	d0,INTREQ+CUSTOM
	
	lsr.w	#7,d0
	move.l	#CUSTOM+aud0,a1
	moveq	#4-1,d7
.snd_loop
	lsr.w	d0
	bcc	.skip
	nop
	;move.w	#0,ac_vol(a1)
.skip
	lea	ac_SIZEOF(a1),a1
	dbra	d7,.snd_loop
	
	txt_val		#32,#22,InterruptTimer


	movem.l	(sp)+,d0-d7/a0-6

	nop
	nop
	rte
	nop
	nop

;--------------------------------------------------------------------------

;###################
Lev3CopperInterruptGame:
;###################

	add.l	#1,InterruptTimer

;	lea	spr0_h,a1
;	move.l	#128,d3
;	move.w	map_x,d0
;	and.w	#$000f,d0
;	neg.w	d0
;	add.w	#-1+(17*16),d0S
;	move.w	map_y,d1
;	and.w	#$000f,d1
;	neg.w 	d1
;	add.w	#GAME_YOFF-16+0,d1
;	move.l  BigSpriteBuffer1,a0
;	bsr	SetHWSpritePosition2


;	;----------------------
;	tst.w	UpdatePanel
;	beq.s	.SkipPanel
;
;	movem.l	d0-d7/a0-6,-(sp)
;	bsr	MovePanel
;	movem.l	(sp)+,d0-d7/a0-6
;
;	move.w	#0,UpdatePanel
;.SkipPanel
;	;----------------------

	jsr	mt_music


	move.w	#-1,ScreenRefreshed

;;;	movem.l	(sp)+,d0-d7/a0-6

	;;move.w	#$10,INTREQ+CUSTOM	;reset interrupt
	move.w	#$10+$40,INTREQ+CUSTOM	;reset interrupt



	nop
	nop
	rte
	nop
	nop

;###################
Lev3CopperInterruptMenu:
;###################



	movem.l	d0-d7/a0-6,-(sp)

	add.l	#1,InterruptTimer
;;;;	not.b	ToggleEveryFrame

	bsr 	DoMouse
	move.l	PointerBuffer,a0
	move.w	_MouseX,d0
	move.w	_MouseY,d1
	add.w	#MENU_XOFF-1,d0
	add.w	#MENU_YOFF,d1
	bsr	SetHWSpritePosition

;	move.w #$f0f,$dff180
	jsr	mt_music
	
	
;;;;;;	tst.w	Music_Playing
;;;;;;	Beq.s	.skipMusic
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	jsr 	mt_music
;;;;;;.skipMusic
	
;	move.w #$0,$dff180

	
	move.w	#-1,ScreenRefreshed

	movem.l	(sp)+,d0-d7/a0-6
	

	move.w	#$10,INTREQ+CUSTOM	;reset interrupt
	
	nop
	nop
	rte
	nop
	nop



;------------------------------------------------------------------------------

;###################
;Lev2"CIA-A"Interrupt:
;###################

Level2		movem.l	d0-d7/a0-a6,-(sp)	 preserve irq reg`s..

		lea	$DFF000.l,a6		* hardware base..
		move.w	$1E(a6),d0		* intreqr
		and.w	#8,d0			* level 2 request ?
		beq.s	Exit_Lev2

		btst	#3,$BFED01.l		* from keyboard?
		beq.s	_Exit_Lev2

		lea	kb_temp(pc),a1
		move.b	$BFEC01,d0		* get key
		bset	#6,$BFEE01		* start ciaa
		not.w	d0
		ror.b	#1,d0
		bsr	GetKeycodes

		lea	$dff006,a1
		moveq	#4-1,d2
key6:		move.b	(a1),d3
key1:		cmp.b	(a1),d3			; wait 4 rasters... before ciaa
		beq.b	key1			; stop.. ack`ing keyboard
		dbf	d2,key6

		bclr	#6,$BFEE01.l		; stop ciaa - acknowlege kb
		
_Exit_Lev2	
			;;;;;move.w	#8,$9C(a6)		; clear irq bit..
			movem.l	(sp)+,d0-d7/a0-a6	 ; restore irq reg`s..
			move.w	#8,$9C+CUSTOM		; clear irq bit..
			bra	doneCIA					;just incase IRQ is call before stack is put back!
		
Exit_Lev2		
		movem.l	(sp)+,d0-d7/a0-a6	 ; restore irq reg`s..
doneCIA
		nop		* NB: these nop`s are here for 040/060
		nop		* cache compatibility! you should do
		rte		* the same for any other hardware irq`s
		nop		* like a Level3 that you setup to make
		nop		* sure your code works on MC680x0!


;-------------------------------------------------------------------------

MovePanel:

	move.w	ScreenBlocksHeight,d0
;;;	move.w	d0,d1
;;;	lsr.w		#4,d1
;;;	addq.w	#1,d1
;;;	Move.w	d1,BlocksDown

	add.w		#GAME_YOFF-1,d0	
	move.w	d0,d1		

	lsl.w	#8,d1
	add.w	#(0<<8)+(446>>1)|1,d1
	move.w 	d1,gamecopwait

	move.w	d0,d1

	lsl.w	#8,d1
	add.w	#(1<<8)+(446>>1)|1,d1
	move.w 	d1,gamecopwait_blankline

	move.w	d0,d1
	cmp.w	#255,d1
	blt.w	.InsideRange

	move.w	#(47<<8)+(0>>1)|1,gamecopwait2
	move.w	#(47<<8)+(0>>1)|1,gamecopwait3
	Bra.s	.No_More
.InsideRange

	add.w	#48+2,d1
	cmp.w	#255,d1
	bgt.s	.VblCounterReset

	lsl.w	#8,d1
	or.w	#1,d1
	move.w	d1,gamecopwait2
	move.w	d1,gamecopwait3
	bra.s	.no_more

.VblCounterReset
	move.w	#(255<<8)+(446>>1)|1,gamecopwait2

	sub.w	#255-48-1,d0
	lsl.w	#8,d0
	or.w	#1,d0
	move.w	d0,gamecopwait3

.No_More
	rts