; ****Add explosion to the list****
MakeExplosion:
	move.l	a0,-(sp)
	movem.w 	d0-3,-(sp)

	lea		ExplosionList,a0
	move.w	#MAX_EXPLOSIONS-1,d3
.InitExpLoop
	tst.b		EXP_ENABLE(a0)
	bne.s		.InUse
	
	move.w	d0,EXP_X(a0)
	move.w	d1,EXP_Y(a0)
	move.w	d2,EXP_FRAME(a0)
	move.w	EXP_FRAME(a0),EXP_ENDFRAME(a0)
	add.w		#EXP_FRAMES<<EXP_RATE,EXP_ENDFRAME(a0)
	move.b	#-1,EXP_ENABLE(a0)
	bra		DoneExp
.InUse
	lea		EXP_SIZEOF(a0),a0
	dbra		d3,.InitExpLoop
doneExp:
	movem.w	(sp)+,d0-3
	move.l	(sp)+,a0
	RTS

;-----------------------------------------

DrawExplosions:

	lea	ExplosionList,a3
	move.w	#MAX_EXPLOSIONS-1,d7

DrawExpLoop:
	tst.b	EXP_ENABLE(a3)
	beq.s	ExpNotInUse

	Add.w	#1,EXP_FRAME(a3)
	move.w	EXP_FRAME(a3),d5
	cmp.w	EXP_ENDFRAME(a3),d5
	blt.s	skip_exp
	move.b	#0,EXP_ENABLE(a3)	; Free up
	bra.s	ExpNotInUse
skip_exp:
	lsr.w	#EXP_RATE,d5	; -- slow down anim
	move.w	EXP_X(a3),d3
	sub.w	Bob_Map_x,d3
	move.w	EXP_Y(a3),d4
	sub.w	Bob_Map_y,d4

	move.l  ExplosionBuffer,BobGFxBuffer
	Bsr	Pastebob32x32

ExpNotInUse:
	lea	EXP_SIZEOF(a3),a3
	dbra	d7,DrawExpLoop

	RTS

;--------------------------------------------------
;IN: X:d0, Y:d1, FRAME:d2
LaunchRocket:		

	lea		RocketList,a0
	move.w	#MAX_Rockets-1,d7
.RocketLoop
	tst.b		ROCKET_ENABLE(a0)
	bne.s		.InUse

	move.w	CAR_NUMBER(a3),ROCKET_FIREDBY(a0)
	move.l	d0,ROCKET_X(a0)
	move.l	d1,ROCKET_Y(a0)
	move.l	d2,ROCKET_FRAME(a0)
	
	move.l	CAR_SPEED(a3),ROCKET_SPEED(a0)
	sub.l		#2<<16,ROCKET_SPEED(a0)
	cmp.l		#2<<16,ROCKET_SPEED(a0)
	bge.s		.skip
	move.l	#2<<16,ROCKET_SPEED(a0)
.skip
	move.b	#-1,ROCKET_ENABLE(a0)
	;;;;;;;PLAY_SAMPLE	#SAM_MISSILE,#%0010,#320
	RTS
.InUse
	lea		ROCKET_SIZEOF(a0),a0
	dbra		d7,.RocketLoop
	RTS

;----------------------------------------------------- 
 
DrawRockets:

	move.l	RocketGfxBuffer,BobGfxBuffer
	
	lea		RocketList,a3
	moveq		#MAX_ROCKETS-1,d6

	move.l	HitDataBuffer,a5
	move.l	MapDataBuffer,a6
	lea		MAPHEADER_DATA(a6),a6	;+24 skip header
	lea 		CarDir_x_table,a0
	lea		CarDir_y_table,a1
	
DrawRocketsLoop:

	tst.b		ROCKET_ENABLE(a3)
	beq		NextRocket
	
	lea		CarList,a4
	
	; Hard border around the map now!!!
	; no need for off map check

	;***AddMovement
	move.w	ROCKET_FRAME(a3),d1
	lsl.w		#2,d1

	move.l	ROCKET_SPEED(a3),d0
	add.l		#(1<<16)/4,d0

	cmp.l		#15<<16,d0
	ble.s		.skip
	move.l	#15<<16,d0
.skip
	move.l	d0,ROCKET_SPEED(a3)
	swap d0

	lsl.w	#8,d0 ; no longer need extra table, frames are now 64
	add.w	d0,d1 ; data is (speed*64*4) + (frame*4)

	move.l	(a0,d1.w),D3 ; x
	move.l	(a1,d1.w),d4 ; y
	add.l		d3,ROCKET_X(a3)
	add.l		d4,ROCKET_Y(a3)

	move.w	ROCKET_X(a3),d0
	move.w	ROCKET_Y(a3),d1

	add.w		#MISSILE_WIDTH/2,d0 
	lsr.w		#4,d0
	add.w		#MISSILE_HEIGHT/2,d1
	lsr.w		#4,d1

	add.w		d0,d0
	lsl.w		#7,d1
	add.w		d1,d1
	add.w		d1,d0

	move.w	d0,d1				;index offset
	move.w	(a6,d0.w),d0	;find block
	move.b	(a5,d0.w),d0	;hit type
	cmp.b		#TERRAIN_SOLID,d0
	beq.s		RocketHitSolid
	cmp.b		#TERRAIN_FENCE,d0
	beq.s		RocketHitFence

	bra.s	NoSceneHit
	;-----------------------------
RocketHitFence:	
	add.w		#1,(a6,d1.w)
RocketHitSolid:	
	move.w	ROCKET_X(a3),d0
	sub.w		#16-5,d0
	move.w	ROCKET_Y(a3),d1
	sub.w		#16-5,d1
	
	move.w 	#Exp02,d2
	bsr		MakeExplosion	;in d0,d1,d2 
	move.b	#0,ROCKET_ENABLE(a3)
	bra		NextRocket

NoSceneHit:

	lea	CarList,a4 
	moveq	#MAX_CARS-1,d7
CarHitRocket_loop:

	cmp.w	#CAR_PLR1,CAR_TYPE(a4)
	beq	NoRocketHit

	move.w	CAR_XPOS(a4),d2
	move.w	ROCKET_X(a3),d1
	add.w		#11-8-8,d1
	cmp.w		d2,d1
	blt		NoRocketHit
	add.w		#32-8-8,d2
	cmp.w		d2,d1
	bgt		NoRocketHit
	
	move.w	CAR_YPOS(a4),d1
	move.w	ROCKET_Y(a3),d2
	add.w		#11-8,d2
	cmp.w		d1,d2
	blt		NoRocketHit
	add.w		#20+11-8-8,d1
	cmp.w		d1,d2
	bgt		NoRocketHit
	
	
	;-----------------------
	;explosion pushing car
	move.l	CAR_VELX(a4),d0 
	asl.l		#1,d0
	move.l	CAR_VELY(a4),d1	
	asl.l		#1,d1

	add.l		d3,d3	;double explotion power
	add.l		d3,d0	;add vel
	move.l	d0,CAR_VELX(a4)
	add.l		d4,d4
	add.l		d4,d1	;add vel
	move.l	d1,CAR_VELY(a4)
	
	move.l	#$ffff,d0
	jsr		Random
	sub.l		#($ffff/2),d0
	asl.l		#4,d0	;scale up
	move.l	d0,CAR_TURN_AMOUNT(a4)
	;-----------------------

	move.w	ROCKET_X(a3),d0
	sub.w		#16-5,d0
	move.w	ROCKET_Y(a3),d1
	sub.w		#16-5,d1
	move.w 	#Exp01,d2

	bsr		MakeExplosion	;in d0,d1,d2 
	move.b	#0,ROCKET_ENABLE(a3)
	bra		NextRocket

NoRocketHit:
	Lea		CAR_SIZEOF(a4),a4
	dbra		d7,CarHitRocket_loop

	move.w	ROCKET_X(a3),d3
	move.w	ROCKET_Y(a3),d4  	
	sub.w		Bob_map_x,d3
	sub.w		Bob_map_y,d4
	move.w	ROCKET_FRAME(a3),d5
	
	add.w		#OVERRUN,d3    
	add.w		#OVERRUN,d4 	
	
	Bsr		PasteBob16x11

NextRocket:
	lea		ROCKET_SIZEOF(a3),a3
	dbra		d6,DrawRocketsloop
	
	RTS                        

;;---------------------------------------------------------------
;
;Launch_BlastPixels
;
;	movem.l	d0-7/a0-6,-(sp)
;
;	lea	BlastList,a0
;	move.w	#MAX_BLAST_PIXELS-1,d1
;
;SetBlastLoop
;	move.l	#4096,d0
;	jsr	Random
;	sub.w	#(4096/2),d0
;	asl.w	#8,d0
;	move.w	d0,PIXEL_MX(a0)
;
;	move.l	#4096,d0
;	jsr	Random
;	sub.w	#(4096/2),d0
;	asl.w	#8,d0
;	move.w	d0,PIXEL_MY(a0)
;
;	move.w	Map_X,d0
;	add.w	#(SCREENWIDTH/2)+(OVERRUN/2),d0 ; bob Xpos
;	and.w	#$fff0,d0
;	addq	#8,d0
;	swap 	d0
;	move.l	d0,PIXEL_X(a0)
;
;	move.w	Map_Y,d0
;	add.w	#(SCREENHEIGHT/2)+(OVERRUN/2),d0 ; bob Ypos
;	and.w	#$fff0,d0
;	addq	#8,d0
;	swap	d0
;	move.l	d0,PIXEL_Y(a0)
;
;	move.b	#12,PIXEL_COL(a0)
;	move.w	#200,PIXEL_TIMER(a0)
;
;	lea	BLAST_SIZEOF(a0),a0
;
;	dbra	d1,SetBlastLoop
;
;	movem.l	(sp)+,d0-7/a0-6
;
;	rts

;---------------------------------------------------------

;DrawStars:
;
;	lea	x,a0
;	lea 	y,a1
;	lea	mx,a2
;	lea	my,a3
;	lea	Col,a4
;
;	move.w	STARS,d4
;Loop:
;	;------------------------
;	move.w  (a0),d0
;	move.w	(a1),d1
;	;------------------------
;
;	cmp.w	#SCREENHEIGHT*SCALE,d1
;	blt.s	.skip_launch
;	move.l	#160*2,d0   	;\
;	jsr	Random 	  	; \ NEW
;;	sub.w	#80,d0	  	; / MY
;	move.w	d0,(a3)   	;/
;
;	move.l	#80*3,d0	;\
;	jsr	Random		; \ NEW
;	sub.w	#40*3,d0	; / MX
;	move.w	d0,(a2)		;/
;
;	move.w	#0,(a4)
;
;	move.w	#160*SCALE,d0
;	move.w	d0,(a0)
;	move.w	#100*SCALE,d1
;	move.w	d1,(a1)
;.skip_launch
;	;-------------------------------
;	sub.w	(a2)+,d0	; movement
;	move.w	d0,(a0)+	; store new pos
;
;	lsr.w	#LSR_SCALE,d0	; RESCALE Y
;	sub.w	(a3),d1
;	sub.w	#GRAVITY,(a3)+
;	move.w	d1,(a1)+
;	lsr.w	#LSR_SCALE,d1	; RESCALE X
;
;	move.w	(a4),d2
;	add.w	#16,d2
;	cmp.w	#15*64,d2
;	Bgt.s	.dont_set
;	move.w	#15*64,d2
;.dont_set:
;	move.w	d2,(a4)+
;	lsr.w	#LSR_SCALE,d2
;	and.w	#%1111,d2
;
;	bsr	plot
;	dbra	d4,Loop
;
;	rts
;
;
;ClearStars:
;	lea	x,a0
;	lea 	y,a1
;	lea	clearX,a2
;	lea	clearY,a3
;	move.w	STARS,d4
;.Loop:
;	;------------------------
;	moveq	#0,d2
;
;	move.w  (a2),d0
;	move.w	(a3),d1
;
;	lea	TempSpace,a4
;
;	movem.w	d0-d3,-(sp)
;	move.l	a0,-(sp)
;
;	move.l	LogicAddr,a0
;
;	move.w	d1,d3   ; 4 (clock cycles)
;	add.w	d1,d1	; 4
;	add.w 	d1,d1	; 4
;	add.w 	d3,d1	; 4
;	lsl.w	#5,d1	;16   i.e. 6+(2*5)
;			;---
;			;32 cycles for fast mulu 160
;			;---
;	lsr.w	#3,d0
;	add.w	d0,d1
;	and.l	#$ffff,d1
;	add.l   d1,a0
;	add.l	d1,a4
;
;	move.b	BYTEWIDTH*0(a4),BYTEWIDTH*0(a0)
;	move.b	BYTEWIDTH*1(a4),BYTEWIDTH*1(a0)
;	move.b	BYTEWIDTH*2(a4),BYTEWIDTH*2(a0)
;	move.b  BYTEWIDTH*3(a4),BYTEWIDTH*3(a0)
;
;	movem.w	(sp)+,d0-d3
;	move.l	(sp)+,a0
;
;	move.w  (a0)+,d2
;	move.w	(a1)+,d3
;	;------------------------
;	lsr.w	#LSR_SCALE,d2
;	lsr.w	#LSR_SCALE,d3
;
;	move.w	d2,(a2)+
;	move.w	d3,(a3)+
;
;	dbra	d4,.Loop
;	rts
;

;-------------------------------------------------------
;
;DrawCalcBlastPixels
;	movem.l	d0-7/a0-6,-(sp)
;
;;	move.l	LogicScreenBuffer,a0
;	move.l	LogicScreenBuffer,d5
;	lea	BlastList,a1
;	move.w	#MAX_BLAST_PIXELS-1,d4
;
;	move.w	map_x,d6
;	move.w	map_y,d7
;
;.SetBlastLoop
;	;;;F_PLOT	PIXEL_X(a1),PIXEL_Y(a1),PIXEL_COL(a1)
;	
;	move.w	PIXEL_X(a1),d0
;	move.w  PIXEL_Y(a1),d1
;	move.b  PIXEL_COL(a1),d2
;	bsr	plot
;
;	moveq	#0,d0
;	move.w	PIXEL_MX(a1),d0
;	ext.l	d0
;	add.l	d0,PIXEL_X(a1)
;	moveq	#0,d0
;	move.w	PIXEL_MY(a1),d0
;	ext.l	d0
;	add.l	d0,PIXEL_Y(a1)
;
;	lea	BLAST_SIZEOF(a1),a1
;	dbra	d4,.SetBlastLoop
;
;
;	movem.l	(sp)+,d0-7/a0-6
;
;	rts
