	EVEN


;--------------------------------------------
DisplaySkids:	
	lea	CarList,a3
	REPT	(MAX_CARS)
		bsr	DisplayTireMarks
		lea	CAR_SIZEOF(a3),a3
	ENDR
	rts
;--------------------------------------------
CARSIZE		EQU	(BITPLANES*CAR_BLIT_HEIGHT*CAR_BLIT_BYTEWIDTH)+(CAR_BLIT_HEIGHT*CAR_BLIT_BYTEWIDTH)
FULLCARBLITSIZE	EQU	TOTAL_CAR_FRAMES*CARSIZE

DisplayCars:  ; in d6,d7  (x/y negative overrun's, if any)


	lea	CarList,a3	; get car struct
	lea	CarGfxBuffer1,A1
	add.w	Bob_Map_x,d6	; was move
	add.w	Bob_Map_y,d7	
	
;;;;	sub.w		#OVERRUN,d6	   ; really added later,
;;;;	sub.w		#OVERRUN,d7    ; hidden offscreen overrun.
	
	REPT	(MAX_CARS) 
		moveq.l	#0,d3
		move.l	d3,d4		;zero
		move.l	d4,d5		;zero
		move.w	CAR_XPOS(a3),d3
		move.w	CAR_YPOS(a3),d4
		move.w	CAR_FRAME(a3),d5

		sub.w	d6,d3		;sub Bob_Map_x
		sub.w	d7,d4		;sub Bob_Map_y
		
		move.l	(a1),a0		;gfx data
		bsr	PasteCar32x20	;IN: A0,d3,d4,d5
		lea	4(a1),a1	;next car gfx index
		lea	CAR_SIZEOF(a3),a3
	ENDR

	RTS
	
;----------------------------------------
;	****************************
;	*** 32x20 PASTE BOB 	 ***
;       *** FOR DRAWING CAR ONLY ***
;       *** CONTAINS EXTRA LOGIC ***
;	****************************

;INPUT	d3,d4,d5 = x,y,frame
;	A0 = gfx data
;(bob size is taken as 32x20)

PasteCar32x20:	; code is hardwired, only use to display cars!!!
	
	
	;;;add.w	#OVERRUN,d3	   
	;;;add.w	#OVERRUN,d4    
			
 	tst.w	d4				; DONT IF Y<0 OR Y>SCREEN
	blt.w	bob_error
  	cmp.w	#SCREENHEIGHT+(OVERRUN*2),d4
  	bge.w	bob_error

  	tst.w	d3				; DONT IF X<0 OR X>SCREEN
  	blt.w	bob_error
  	cmp.w	#SCREENWIDTH+(OVERRUN*2),d3
  	bge.w	bob_error

	bsr	UpdateReDrawListForCar ; IN:d3;x,d4;y
	
		
	moveq.l	#0,d1
	move.w	d4,d1 		;bob_ypos
	lsl.l		#8,d1 ;Screen Width = 512 (256 words in size)
	add.l		LogicScreenBuffer,d1

	move.w	d3,d2		;x
	lsr.w		#3,d2
	and.l		#$fffe,d2
	add.l		d2,d1

	move.w  d3,d2		;x
	and.w	#$0f,d2
	ror.w	#4,d2		;place in bits12-15

	;----------------------------
	;;was....	mulu	#(4*20*4)+(4*20),d0
;;;;	move.l	CarGfxBuffer1,d0   
	move.l	a0,d0
	
	;fast mulu to replace above
	lsl.w	#4,d5 	;*16		6cy+(2*4) =14 
	add.l	d5,d0 	;		4
	lsl.w	#3,d5	;...*128	6+(2*3)  =12
	add.l	d5,d0	;		4
	add.w	d5,d5	;...*258	4
	add.l	d5,d0	;		4
	;-----------------------------tot=42
	move.l	d0,d3
	add.l	#4*20*4,d3	;mask

	BLTWAIT
	move.w	d2,bltcon1+custom	;pre-shift B
	add.w	#$0fca,d2
	move.w	d2,bltcon0+custom	;minterms + pre-shift A

	move.w	#$0,bltalwm+custom	;right edge mask (no rap with rotate)
	move.w	#$ffff,bltafwm+custom	;left edge mask
	move.w	#-2,bltamod+custom	;go back extra 16pixels
	move.w	#-2,bltbmod+custom	;blitter uses extra space to shift image
	move.w	#((512/8)*BITPLANES)-6,BLTCMOD+custom
	move.w	#((512/8)*BITPLANES)-6,BLTDMOD+custom

	move.l	d3,bltapt+custom	;
	move.l	d0,bltbpt+custom	;
	move.l	d1,bltcpt+custom	;background
	move.l	d1,bltdpt+custom	;dest

	FASTBLIT_ON
	BLTSIZE 3,20

	REPT	(BITPLANES-1)

		add.l	#(512/8),d1

		BLTWAIT
		move.l	d3,bltapt+custom	;
		move.l	d1,bltcpt+custom ;background
		move.l	d1,bltdpt+custom ;dest
		BLTSIZE	3,20
	ENDR
	BLTWAIT

	FASTBLIT_OFF

	;;;move.w	#0,CAR_VISABLE(a3) 	;0=YES
	rts

bob_error:
	;;;move.w	#1,CAR_VISABLE(a3)	;1=NO
	rts




;-----------------------------------------------------------

UpdateRedrawListForCar:	;D3=X;D4=Y

	MOVEQ.L	#0,D0
	move.l	d0,d1	;clear
	move.l	StoreBlocksLoc1,a2

	move.w	d3,d0	;X
	lsr.w		#4,d0	;/16
	move.w	d4,d1	;Y
	lsr.w		#4,d1	;/16
	
;;;	mulu_20	d1,d2	; state scratch as d2

	moveq.l	#0,d2
	move.w	ScreenBlocksWidth,d2
	lsr.w		#4,d2
	mulu		d2,d1
	
	add.l		d1,d0
	add.l		d0,d0	;word index
	add.L		d0,A2

	add.l		d2,d2	; holds amount to wrap around the map
	sub		#4,d2	; account for the (a2)+ being used later.

	moveq		#-1,d1	;force redraw
	; have to redraw an area of 3x3 blocks under the car
	MOVE.l  	d1,(A2)+	; +4
	move.w	d1,(a2)
	;;;;ADD.l		#(BLOCKS_X*2)-4,A2
	ADD.l		d2,A2
	MOVE.l  	d1,(A2)+	; +4
	move.w	d1,(a2)
	;;;ADD.l		#(BLOCKS_X*2)-4,A2
	add.l		d2,a2
	MOVE.l  	d1,(A2)+
	MOVE.W  	d1,(A2)		; DAM...car gfx is just a few pixels
								; just away from fitting into 2*2
	RTS
	
;----------------------------------------------------------------------
	
UpdateRedrawListForRocket:	;D3=X;D4=Y
	MOVEQ		#0,D0
	move.l	d0,d1
	move.l	StoreBlocksLoc1,a2
	
	move.w	d3,d0	;X
	asr.w		#4,d0
	move.w	d4,d1	;Y
	asr.w		#4,d1

	mulu_20	d1,d2	;d2=scratch
	
	moveq 	#-1,d2 	;force redraw
	add.l		d1,d0
	add.l		d0,d0
	move.L	d2,(a2,d0)
	move.L	d2,BLOCKS_X*2(a2,d0)
	RTS

;-----------------------------------------------
UpdateRedrawListForExp:	;D3=X;D4=Y
	MOVEQ.L	#0,D0
	move.l	d0,d1
	move.l	StoreBlocksLoc1,a2
	
	move.w	d3,d0	;X
	asr.w	#4,d0
	move.w	d4,d1	;Y
	asr.w	#4,d1

	mulu_20	d1,d2	;d2=scratch
	moveq	#-1,d2  ;force redraw
	
	add.L	d1,d0
	add.L	d0,d0
	add.L	d0,A2
	move.L	d2,(a2)+
	move.L	d2,(a2)
	ADD.L	#(BLOCKS_X*2)-4,A2
	move.L	d2,(a2)+
	move.L	d2,(a2)
	ADD.L	#(BLOCKS_X*2)-4,A2
	move.L	d2,(a2)+
	move.L	d2,(a2)
	ADD.L	#(BLOCKS_X*2)-4,A2
	move.L	d2,(a2)+
	move.L	d2,(a2)
	RTS



;	***********************
;	*** 32x32 PASTE BOB ***
;	***********************

;INPUT	d3,d4,d5 = x,y,frame
;(bob size is taken as 32x32)

PasteBob32x32

      add.w	#OVERRUN,d3    
   	add.w	#OVERRUN,d4 		
   	
   tst.w	d4
	blt	bob32x32_error
   cmp.w	#SCREENHEIGHT+OVERRUN,d4
   bgt	bob32x32_error

   tst.w	d3
	blt	bob32x32_error
   cmp.w	#SCREENWIDTH+OVERRUN,d3
   bgt	bob32x32_error
    	
   bsr	UpdateRedrawListForExp
   
   moveq		#0,d1
	move.w	d4,d1 		;bob_ypos

	lsl.l		#8,d1
	add.l		LogicScreenBuffer,d1

	move.w	d3,d2
	lsr.w		#3,d2
	and.l		#$fffe,d2
	add.l		d2,d1

	move.w  d3,d2

	move.l	d1,A1    	;blitto
	and.w		#$0f,d2
	ror.w		#4,d2

	ext.l		d5	;frame
	move.l	BobGfxBuffer,d3
	;-----------------------
	lsl.l	#7,d5		;
	add.l	d5,d3		;
	add.l	d5,d5		;
	add.l	d5,d5		;
	add.l	d5,d3  	;28cy...MULU 640
	;NOTE:640 = WIDTH*(HEIGHT/8)*(BITPLANES+MASK) or (32*(32/8)*(4+1))
	;-----------------------

	move.l	d3,d0
	add.l		#4*32*4,d0	;mask
	
	BLTWAIT
	move.w	d2,bltcon1+custom
	add.w		#$0fca,d2
	move.w	d2,bltcon0+custom

	move.w	#$0,bltalwm+custom
	move.w	#$ffff,bltafwm+custom
	move.w	#-2,bltamod+custom
	move.w	#-2,bltbmod+custom
	move.w	#((512/8)*BITPLANES)-6,BLTCMOD+custom
	move.w	#((512/8)*BITPLANES)-6,BLTDMOD+custom

	move.l	d0,bltapt+custom	;Mask
	move.l	d3,bltbpt+custom	;Bob Gfx Data
	move.l	a1,bltcpt+custom
	move.l	a1,bltdpt+custom	;blitto

	FASTBLIT_ON
	BLTSIZE	3,32

	REPT	(BITPLANES-1)
		lea	512/8(a1),a1
		BLTWAIT
		move.l	d0,bltapt+custom
		move.l	a1,bltcpt+custom
		move.l	a1,bltdpt+custom
		BLTSIZE	3,32
	ENDR

	FASTBLIT_OFF

bob32x32_error:

	rts

;-----------------------------------------------------------


;	***********************
;	*** 16x11 PASTE BOB *** missile
;	***********************

;INPUT	d3,d4,d5 = x,y,frame

PasteBob16x11:
	
	;;;add.w		#OVERRUN,d3    
	;;;add.w		#OVERRUN,d4 	
	
	tst.w		d4	
	blt.w		bob16x11_error				
  	cmp.w		#SCREENHEIGHT+OVERRUN,d4
  	bgt.w		bob16x11_error
  	
  	tst.w		d3
  	blt.w		bob16x11_error
  	cmp.w		#SCREENWIDTH+OVERRUN,d3
 	bgt.w		bob16x11_error
   
  	bsr 		UpdateRedrawListForRocket
  		
  	moveq		#0,d1
	move.w	d4,d1 		;bob ypos

	lsl.l		#8,d1  ;512/8*BITPLANES
	add.l		LogicScreenBuffer,d1

	move.w	d3,d2			;bob xpos
	lsr.w		#3,d2
	and.l		#$fffe,d2
	add.l		d2,d1	; blitto

	and.w		#$0f,d3
	ror.w		#4,d3
	
	move.l	BobGfxBuffer,d0
	ext.l		d5
	;-----------------------------------	
	add.l		d5,d5		;*110
	sub.l		d5,d0
	lsl.l		#3,d5
	sub.l		d5,d0
	lsl.l		#3,d5
	add.l		d5,d0
	;-----------------------------------
	
	move.l	d0,d4
	add.l		#2*11*4,d4	;find mask

	BLTWAIT
	
	move.w	d3,bltcon1+custom
	add.w		#$0fca,d3
	move.w	d3,bltcon0+custom
	
	move.w	#$0,bltalwm+custom
	move.w	#$ffff,bltafwm+custom
	move.w	#-2,bltamod+custom
	move.w	#-2,bltbmod+custom
	move.w	#((512/8)*BITPLANES)-4,BLTCMOD+custom
	move.w	#((512/8)*BITPLANES)-4,BLTDMOD+custom
	move.l	d4,bltapt+custom	;Mask
	move.l	d0,bltbpt+custom	;Bob Gfx Data
	move.l	d1,bltcpt+custom
	move.l	d1,bltdpt+custom	;blitto

	FASTBLIT_ON
	BLTSIZE	2,11

	REPT	(BITPLANES-1)
		add.l	#512/8,d1
		BLTWAIT
		move.l	d4,bltapt+custom
		move.l	d1,bltcpt+custom
		move.l	d1,bltdpt+custom
		BLTSIZE	2,11
	ENDR

	FASTBLIT_OFF

bob16x11_error:
	RTS


;------------------------------------------------
; Upate the logic screen with new blocks.
;**********
BlitBlocks:
;**********

	move.l	MapDataBuffer,a0
	lea	MAPHEADER_DATA(a0),a0	;+24 skip header

	LEA	MapLookUp,a3
	moveq	#0,d3
	
	move.w	bob_Map_x,d3
	lsr.w	#3,d3
	move.w	bob_Map_y,d4 
	lsr.w	#3,d4

	lsl.w	#7,d4
	add.w	d4,d3
	add.l	d3,a0	;get map pos

;;;;;	move.l	LogicScreenBuffer,d6
;;;;;	add.l	#((BLOCK_SIZE*2)/8)+(((512/8)*BITPLANES)*(BLOCK_SIZE*2)),d6 
	
	BltWait
	move.l	#$09F00000,bltcon0+custom
	move.l	#-1,bltafwm+custom
	move.w	#(512/8)-2,bltDmod+custom	
	move.w	#0,bltAmod+custom
	move.l  #bltApt+CUSTOM,a4

;;;;;	move.w	blocksdown,d1
	move.w	ScreenBlocksHeight,d1
	lsr.w		#4,d1
	beq	Dont_Draw

	move.l	StoreBlocksLoc1,a2
	add.l		#((BLOCKS_X*2)*SIZE_WORD)+(2*SIZE_WORD),a2	;OVERRUN


	FASTBLIT_ON
blk2_y:	move.w	#BLOCKS_X-1,d0
blk2_x:
	move.w	(a0)+,d7 ; Icon No

	;--------------------------------
	;TEST AND REDRAW ONLY WHATS CHANGED
	move.w	(a2),d2		;store	
	move.w	d7,(a2)+	;keep icon No
	cmp.w	d2,d7		;Is it the same as the last frame?
	beq.s	NoNeedToDrawBlock
	;--------------------------------

	lsl.w	#2,d7	 	; long index
	move.l	(a3,d7.w),d5	; addr of block (interleaved data)

	BltWait
	movem.l	d5-d6,(a4)	;bltApt+CUSTOM
	BLTSIZE	1,(BLOCK_SIZE*BITPLANES)

NoNeedToDrawBlock:
	addq.l	#2,d6 ;add word to screen buffer
	dbra	d0,blk2_x

	add.l	#((512/8)*4*16)-(BLOCKS_X*2),d6 
	
	lea	(128*2)-(BLOCKS_X*2)(a0),a0
	dbra	d1,blk2_y

	FASTBLIT_OFF

Dont_Draw:

	rts


;-------------------------------------------------------


; Upate the logic screen with new Animated blocks.
;**********
BlitAnimateBlocks:
;**********

	move.l	MapDataBuffer,a0
	lea	MAPHEADER_DATA(a0),a0	;+24 skip header
	
	move.l	AnimBuffer,a1
	LEA	MapLookUp,a3

	moveq	#0,d3
		
	move.w	bob_Map_x,d3
	lsr.w	#3,d3
	move.w	bob_Map_y,d4 
	lsr.w	#3,d4
	

	lsl.w	#7,d4
	add.w	d4,d3
	add.l	d3,a0

;;;;	move.l	LogicScreenBuffer,d6	
;;;;	add.l	#((BLOCK_SIZE*2)/8)+(((512/8)*BITPLANES)*(BLOCK_SIZE*2)),d6

	BltWait
	move.l	#$09F00000,bltcon0+custom
	move.l	#-1,bltafwm+custom

	move.w	#(512/8)-2,bltDmod+custom
	move.w	#0,bltAmod+custom

;;;;	move.w	blocksdown,d1
	move.w	ScreenBlocksHeight,d1
	lsr.w		#4,d1
	beq	Dont_Draw_NoAnim2

	moveq	#0,d3

	move.l #bltApt+CUSTOM,a4

	;;;move.l	StoreBlocksLoc1,a5
	;;;add.l	#(BLOCKS_X*2)*SIZE_WORD+(SIZE_WORD*2),a5	;OVERRUN
	
	
	FASTBLIT_ON
blk_y:
	;;;;;;;move.w	#(BLOCKS_X-1),d0
	move.w	ScreenBlocksWidth,d0
	lsr.w		#4,d0
	subq.w	#1,d0
blk_x:
	move.w	(a0),d7		;Icon No

;===============================================================
;dont really want to put this in a separate routine (branch & ret overheads)
	move.b	0(a1,d7.w),d3	;anim amount

	move.b	d3,d2
	and.w	#%11000000,d2
	tst.w	d2	; check for lock on, do 2x2 blocks
	beq.s	.No_LockOn
	bsr.s	Lock_On
	moveq	#0,d3
	move.w	#FAKE_ANIM_ZERO,d3
.No_LockOn

	and.w	#%00111111,d3
	sub.w	#FAKE_ANIM_ZERO,d3
	add.w	d3,(a0)+ 	;anim cell
;===============================================================

	;---
	;!!!REDRAW ONLY WHATS CHANGED!!!
	move.w	(a5),d2		
	move.w	d7,(a5)+
	cmp.w	d2,d7		;icon no
	beq.s	SkipAnimBlit
	;---

	lsl.w	#2,d7	;to long index
	move.l	(a3,d7.w),d5

	BltWait
	movem.l	d5-d6,(a4)	;bltApt+CUSTOM
	BLTSIZE	1,BLOCK_SIZE*BITPLANES
SkipAnimBlit:
	addq.l	#2,d6 ;add word to screen buffer
	dbra	d0,blk_x

	;;;add.l	#((512/8)*4*16)-(BLOCKS_X*2),d6 ; need to re-size for menus
	moveq.l	#0,d7
	move.w	ScreenBlocksWidth,d7
	lsr.w		#4-1,d7
	add.l		#((512/8)*4*16),d6
	sub.l		d7,d6
	
	;;;lea	(128*2)-(BLOCKS_X*2)(a0),a0
	add.l		#(128*2),a0
	sub.l		d7,a0
	

	dbra	d1,blk_y

	FASTBLIT_OFF

Dont_Draw_NoAnim2:

	rts


;-------------------------------------------------------------------------


; ***********************
; *** LOCK ON ROUTINE ***
; ***********************
TABLE_CENTRE	EQU	ANGLETABLESIZE/2

lock_on:
	;IN d2: %XX000000
	lsr.w	#5,d2
	lea	LockOnTab,a2
	move.w	(a2,d2.w),d3

	; *** find centre of table ***
	move.l #_Angles64+(ANGLETABLESIZE*TABLE_CENTRE)+TABLE_CENTRE,a2

	move.w	d0,d4	;icon xpos
	lsl.w		#4,d4
	sub.w		#((SCREENWIDTH)/2),d4	;centre off 4x4 icons
	sub.w		#8,d4

	move.w	d1,d5	;icon ypos
	lsl.w		#4,d5		;/16
	;;;;;move.w	BlocksDown,d2		
	move.w	ScreenBlocksHeight,d2
	;;;;;lsr.w		#4,d2		;blocksize
	;;;;;lsl.w		#3,d2		;/8
	lsr.w		#4-3,d2
	
	sub.w		d2,d5
	sub.w		#8,d5

	Bra.s	skipscale
DoScale:asr.w	#1,d4
	asr.w	#1,d5
skipscale:
	CMP.w	 #TABLE_CENTRE,D4
	Bge.s	DoScale
	CMP.w	#-TABLE_CENTRE,D4
	Ble.s	DoScale
	CMP.w	 #TABLE_CENTRE,D5
	Bge.s	DoScale
	CMP.w	#-TABLE_CENTRE,D5
	Ble.s	DoScale

	asl.w	#ANGLE_ROTSIZE,d5
	add.w	d5,d4

	move.b	(a2,d4),d4  ;find direction
	
	lsr.b	#1,d4		; 
	and.w	#$fe,d4		; /4*2


	add.w	d4,d3
	move.w	d3,(a0)
	addq.w	#1,d3
	move.w	d3,1*2(a0)
	add.w	#39,d3
	move.w	d3,128*2(a0)
	addq.w	#1,d3
	move.w	d3,129*2(a0)
	RTS

;----------------------------------------------------------



; ********************
; *** PLOT ROUTINE *** (MEGA FAST!!!!)
; ********************
;
; INPUT:	d0.w = X
;		d1.w = Y
;		d2.b = Col
;
plot:	
	tst.w	d0
	blt.s	PlotError
	tst.w	d1
	blt.s	PlotError
	cmp.w	#SCREENWIDTH,d0
	bge.s	PlotError
	cmp.w	#SCREENHEIGHT,d1
	bge.s	PlotError

	move.l	LogicScreenBuffer,a0
	lsl.l	#8,d1

	move.w	d0,d3
	lsr.w	#3,d0
	add.w	d0,d1
	and.l	#$ffff,d1
	add.l   d1,a0
	not.w	d3

	and.w	#$FF,d2	; allow byte value as colour
	add.w	d2,d2			; 4
	MOVE.W	PLOT_TABLE(PC,D2.W),D2	; 14 cycles
	jmp	PLOT_TABLE(PC,D2.W)	; 14 cycles

PLOT_TABLE:
	DC.W	Col_0-PLOT_TABLE,Col_1-PLOT_TABLE
	DC.W	Col_2-PLOT_TABLE,Col_3-PLOT_TABLE
	DC.W	Col_4-PLOT_TABLE,Col_5-PLOT_TABLE
	DC.W	Col_6-PLOT_TABLE,Col_7-PLOT_TABLE
	DC.W	Col_8-PLOT_TABLE,Col_9-PLOT_TABLE
	DC.W	Col_10-PLOT_TABLE,Col_11-PLOT_TABLE
	DC.W	Col_12-PLOT_TABLE,Col_13-PLOT_TABLE
	DC.W	Col_14-PLOT_TABLE,Col_15-PLOT_TABLE

	EVEN

Col_0:	bclr	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bclr	d3,512*3(a0)
PlotError:
	RTS	; rts 16 cycles
Col_1:	bset	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_2:	bclr	d3,512*0(a0)
	bset	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_3:	bset	d3,512*0(a0)
	bset	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_4:	bclr	d3,512*0(a0)
	bclr	d3,5121(a0)
	bset	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_5:	bset	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bset	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_6:	bclr	d3,512*0(a0)
	bset	d3,512*1(a0)
	bset	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_7:	bset	d3,512*0(a0)
	bset	d3,512*1(a0)
	bset	d3,512*2(a0)
	bclr	d3,512*3(a0)
	RTS
Col_8:	bclr	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_9:	bset	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_10:	bclr	d3,512*0(a0)
	bset	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_11:	bset	d3,512*0(a0)
	bset	d3,512*1(a0)
	bclr	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_12:	bclr	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bset	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_13:	bset	d3,512*0(a0)
	bclr	d3,512*1(a0)
	bset	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_14:	bclr	d3,512*0(a0)
	bset	d3,512*1(a0)
	bset	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS
Col_15:	bset	d3,512*0(a0)
	bset	d3,512*1(a0)
	bset	d3,512*2(a0)
	bset	d3,512*3(a0)
	RTS

;;-------------------------------------------------------------------------

;-----------------------------------------------------------------------
; ********************
; *** 2 PLANE PLOT ROUTINE ***
; ********************
;
; INPUT: d0 = X  , d1 = Y
;
PanelPlot_2p:
	move.l	PanelBuffer,a0
	mulu	#(SCREENWIDTH+BLOCK_SIZE)/8*2,d1

	move.w	d0,d3
	lsr.w	#3,d0
	add.w	d0,d1
	not.w	d3

	and.w	#%11,d2
	add.w	d2,d2			; 4
	MOVE.W	FPLOT_TABLE(PC,D2.W),D2	; 14 cycles
	jmp	FPLOT_TABLE(PC,D2.W)	; 14 cycles

FPLOT_TABLE:
	DC.W	FCol_0-FPLOT_TABLE,FCol_1-FPLOT_TABLE
	DC.W	FCol_2-FPLOT_TABLE,FCol_3-FPLOT_TABLE

	EVEN
GAME_BYTE_WIDTH	EQU	(SCREENWIDTH/8+BLOCK_SIZE/8)

FCol_0:	bclr	d3,GAME_BYTE_WIDTH*0(a0,d1.w)
	bclr	d3,GAME_BYTE_WIDTH*1(a0,d1.w)
	RTS
FCol_1:	bset	d3,GAME_BYTE_WIDTH*0(a0,d1.w)
	bclr	d3,GAME_BYTE_WIDTH*1(a0,d1.w)
	RTS
FCol_2:	bclr	d3,GAME_BYTE_WIDTH*0(a0,d1.w)
	bset	d3,GAME_BYTE_WIDTH*1(a0,d1.w)
	RTS
FCol_3:	bset	d3,GAME_BYTE_WIDTH*0(a0,d1.w)
	bset	d3,GAME_BYTE_WIDTH*1(a0,d1.w)
	RTS

;
;-------------------------------------------------------------------------

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


;*** In Game Part ***

HardWare_Scroll:
	;-----------------
	; Horizontal Scroll
	move.w	map_x,d0
	and.w	#$f,d0
	move.w	d0,d1
	lsl.w	#4,d0
	or.w	d1,d0  ; dual field
	not.w	d0
	move.w	d0,Coplist_HScrl
	;------------------
	
	move.l	StoreBlocksLoc1,d0	;SWAP ITEMS
	move.l	StoreBlocksLoc2,d1
	move.l	d0,StoreBlocksLoc2
	move.l	d1,StoreBlocksLoc1

	move.l	LogicScreenBuffer,d0	;SWAP	ITEMS
	move.l	PhysicScreenBuffer,d1 
	move.l	d0,PhysicScreenBuffer
	move.l	d1,LogicScreenBuffer

	add.l		#(BLOCK_SIZE*2)/8+((BLOCK_SIZE*2)*((512/8)*BITPLANES)),d0	; Add Left & Top 

	move.l	#512/8,d2		; Offset to add for next bplane
	lea		Bplanes,a0		; bitplane pointers in copper list
	move.w	#BITPLANES-1,d3
	;-------------------
	;Vertical Scroll
	move.w	map_y,d4
	and.l		#$f,d4
	lsl.l		#8,d4			; MUL 512/8*4
	;-------------------
.Newcopper:
	move.l	d0,d1
	add.l	d4,d1			;add Vertical scroll
	move.w	d1,4(a0)		;Stuff the lo/hi pointers into the
	swap	d1			;bitplane pointers in the copperlist
	move.w	d1,(a0)
	addq.l	#8,a0			;Next set of bitplane pointers
	add.l	d2,d0			;Next bitplane
	dbra	d3,.Newcopper

	;=====================

	move.l	PanelBuffer,d0
	lea	BplanesGamePanel,a0		; bitplane pointers in copper list
	move.w	#2-1,d3				
	;-------------------
	;Vertical Scroll
	move.w	map_y,d4
	lsr.w	#4,d4
	sub.w	#48/2-7,d4
	bge.s	.notneg
	moveq.w	#0,d4
.notneg
	cmp.w	#128-48,d4
	blt.s	.skip
	move.w	#128-48,d4
.skip
	mulu	#(PANEL_WIDTH/8)*2,d4
.Panel
	move.l	d0,d1
	add.l	d4,d1	; add Vertical scroll
	move.w	d1,4(a0)		;Stuff the lo/hi pointers into the
	swap	d1			;bitplane pointers in the copperlist
	move.w	d1,(a0)
	addq.l	#8,a0			;Next set of bitplane pointers
	add.l	#(PANEL_WIDTH)/8,d0	;Next bitplane
	dbra	d3,.Panel
	rts

;\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\


;Draw Skids !!!ONE PLANE!!!!
DrawSkids16x20x1

	moveq		#0,d2
	move.w	CAR_YPOS(a3),d2
	sub.w		Bob_Map_y,d2
	add.w		#(BLOCK_SIZE*2),d2
	
	lsl.l	#8,d2

	add.l	LogicScreenBuffer,d2
	move.w	CAR_XPOS(a3),d4
	add.w		#(BLOCK_SIZE*2),d4
	addq.w	#8,d4	; hack!!! adjust for smaller 16pixel skid width size (skid:16x20, car:32x20)
	move.w	d4,d1
	sub.w		Bob_Map_x,d4	; reason for hack,centres by car size.
	lsr.w		#3,d4		/16*2
	and.l		#$fffe,d4
	add.l		d4,d2
	move.w	CAR_FRAME(a3),d4
	mulu		#(2*20*1),d4		;*40
	add.l		SkidsGfxBuffer,d4
	
	and.w	#$f,d1
	ror.w	#4,d1

	BLTWAIT
	move.w	d1,bltcon1+custom
	add.w	#$0fca,d1
	move.w	d1,bltcon0+custom
	move.w	#$0,bltalwm+custom
	move.w	#$ffff,bltafwm+custom
	move.w	#-2,bltamod+custom
	move.w	#-2,bltbmod+custom
	
	move.w	#((512/8)*BITPLANES)-4,BLTCMOD+custom
	move.w	#((512/8)*BITPLANES)-4,BLTDMOD+custom

	move.l	d4,bltapt+custom	;Mask
	move.l	d4,bltbpt+custom	;Bob Gfx Data
	move.l	d2,bltcpt+custom
	move.l	d2,bltdpt+custom	;blitto
	BLTSIZE	2,20

	RTS

;----------------------------------------------------------------------------
DisplayTireMarks:   ;A3=Car struct (DONT USE A6, TEMP store when ret)

	move.b	CAR_TREDMARKS+3(a3),d7  ;.long
	and.b	#1,d7
	beq	dontDisplayMark

	moveq		#0,d3
	move.w	CAR_YPOS(a3),d3
	sub.w		Bob_Map_y,d3
	add.l		#(BLOCK_SIZE*2),d3	;overrun
	;---------------------------------------------------------
	cmp.w	#BLOCK_SIZE*2,d3		;needed for Y overrun
  	ble	dontDisplayMark
	cmp.w	#SCREENHEIGHT+BLOCK_SIZE*2,d3
	bge	dontDisplayMark
	;scenery icons would become corrupt 
	;at edge of screen (not always valid data in overrun)
	;---------------------------------------------------------
	and.w	#$fff0,d3	;
	lsl.l	#8,d3		; 
	add.l	LogicScreenBuffer,d3

	move.w	CAR_XPOS(a3),d0
	sub.w		Bob_Map_x,d0
	addq.w	#8,d0	; hack!!! adjust for smaller 16pixel skid width size (skid:16x20, car:32x20)
	add.w		#(BLOCK_SIZE*2),d0	;overrun
	;--------------------------------------------------------------
	cmp.w	#BLOCK_SIZE*2,d0	;X offscreen check 
  	ble	dontDisplayMark
  	cmp.w	#SCREENWIDTH+BLOCK_SIZE*2,d0 
	bge	dontDisplayMark
	
	and.w	#$fff0,d0	;
	;--------------------------------------------------------------
	bsr 	DrawSkids16x20x1


	lsr.w	#3,d0		; /16*2
	and.l	#$fffe,d0	; i.e  DIV BY (BLOCK_SIZE * WORD INDEX)
	add.l	d0,d3    	; Find Screen X_location
                        
	move.l	MapDataBuffer,a0
	lea		MAPHEADER_DATA(a0),a0	;+24 skip header
	LEA		MapLookUp,a1		;blit gfx table
	lea		BlocksRestoreList,a2
	move.l	HitDataBuffer,a4
	
	move.w	CAR_XPOS(a3),d0
	addq.w	#8,d0	;  adjust for smaller 16pixel skid width size (skid:16x20, car:32x20)
	lsr.w		#4,d0			; 	/16
	move.w	CAR_YPOS(a3),d1	; next /16 *256 words
	and.w		#$fff0,d1 ; was...lsr.w #4,d1 ; lsl.w #7,d1
	lsl.w		#7-4,d1 

	add.w	d1,d0
	add.w	d0,d0

	;update 2x2 blocks
	bsr.s	ChangeMapAt
	addq.w	#2,d0	;map index
	addq.l	#2,d3	;next screen location
	bsr.s	ChangeMapAt
	addq.w	#2,d0	;map index
	addq.l	#2,d3	;next screen location
	add.w	#(128*2)-(2*2),d0
	add.l	#(((512/8)*BITPLANES)*16)-(2*2),d3
	bsr.s	ChangeMapAt
	addq.w	#2,d0	;map index
	addq.l	#2,d3	;next screen location
	bsr.s	ChangeMapAt
	addq.w	#2,d0	;map index
	addq.l	#2,d3	;next screen location
	
dontDisplayMark:
	RTS
	

;--------------------------------------------------------


ChangeMapAt:
	move.w	(a0,d0.w),d4	;icon no#
	move.b	(a4,d4.w),d1	;hit type *DONT CHANGE*

;*************************************************
;UPDATE THIS: SEPERATE THE BLOCKS INTO SECTIONS, first lot  for non static!
;...hmmm use last bit for quick don't draw test? set up a init time?
;or maybe a lookup table of solid objects to match terrain switch statement.

	cmp.b	#TERRAIN_LAMP,d1
	beq	DoNothing
	cmp.b	#TERRAIN_SOLID,d1
	beq	DoNothing
	cmp.b	#TERRAIN_FENCE,d1
	beq	DoNothing
	cmp.b	#TERRAIN_WATER,d1
	beq	DoNothing
	cmp.w	#EXTRA_BLOCKS_START,d4
	bge	BeforeBlit

	move.w	CountExtraIcons,d2
	;-------------------------------
	move.w	d2,d5
	sub.w	#EXTRA_BLOCKS_START,d5
	lsl.w	#2,d5	;x2 word data

	move.w	0(a2,d5.w),d1		;get map offset
	move.w	2(a2,d5.w),(a0,d1.w)	;restore old map block
	move.w	d0,0(a2,d5.w)	;keep offset in BlockRestoreList
	move.w	d4,2(a2,d5.w)	;keep icon no#
	
	move.b	(a4,d4.w),d1	;get block hit type
	move.b	d1,(a4,d2.w)	;update hitmap list
	move.w	d2,(a0,d0.w)	;place new icon in map
	
	move.w	d2,d4		;copy over this block
	addq.w	#1,d2		;ready for next time around
	move.w	d2,CountExtraIcons
	
	cmp.w	#MAX_BLOCKS,d2
	blt.s	BeforeBlit
	move.w	#EXTRA_BLOCKS_START,CountExtraIcons
BeforeBlit:			;Store Icon with tire mark for later use

	;;;;move.w	(a0,d0.w),d4
	lsl.w	#2,d4	;long index
	BltWait
	move.l	#$09F00000,bltcon0+custom
	move.l	#-1,bltafwm+custom
	move.w	#(512/8)-2,BLTAMOD+custom
	move.w	#0,bltDmod+custom
	move.l	(a1,d4.w),bltDpt+CUSTOM		;a1= Map Look up
	move.l	d3,bltApt+CUSTOM
	BLTSIZE	1,BLOCK_SIZE*BITPLANES	; NOTE: Once icon has been copyied I 
					;  	could just blit one plane 2nd time round
					
DoNothing:
	rts

	EVEN 

;----------------------------------------------------

SetPaletteRoutine

;INPUT	Palette  = a0
;	Copper 	 = a1
;	No. Cols = d0

.pal_loop
	move.w	(a0)+,(a1)
	addq.l	#SIZE_LONG,a1
	dbra	d0,.pal_loop

	rts

;-------------------------------------------

SetSpritePaletteRoutine

	move.l	#$dff1a0,a1
	move.w	#15,d0

.pal_loop
	move.w	(a0)+,(a1)+	;sprite cols
	dbra	d0,.Pal_loop

	rts

;--------------------------------------------------

SetHWSpritePosition:

	clr.l	(a0)	; clear sprite position words
	clr.l	(SPRITE_CAR_HEIGHT+1)*4(a0) ; clear sprite end marker

	move.w	d1,d2
	add.w	#SPRITE_CAR_HEIGHT,d2		;height of sprite

	ror.w	#1,d0	;xpos
	bcc.s	.no_h0
	or.b	#1,3(a0)
.no_h0
	btst	#8,d1	;ypos
	beq.s	.no_e8
	or.b	#4,3(a0)
.no_e8
	btst	#8,d2	;ypos
	beq.s	.no_l8
	or.b	#2,3(a0)
.no_l8
	move.b	d0,1(a0)
	move.b	d1,0(a0)
	move.b	d2,2(a0)

	move.l	(a0),(SPRITE_CAR_HEIGHT+2)*2*2(a0)	;second sprite
	or.b	#$80,(SPRITE_CAR_HEIGHT+2)*2*2+3(a0)

	rts

;----------------------------------------------------------

CarSprite32x20:  

	move.l  CarSpriteBuffer1,a0

	move.w	d5,d2
	mulu	#(SPRITE_CAR_HEIGHT+2)*16,d2	
	add.l	d2,a0
	
	move.w	d3,d0 	;xpos
	move.w	d4,d1	;ypos
	bsr	SetHWSpritePosition
	SET_SPR16H_16COL a0,spr0,spr1

	add.l	#(SPRITE_CAR_HEIGHT+2)*8,a0
	move.w	d3,d0
	move.w	d4,d1
	add.w	#16,d0
	bsr	SetHWSpritePosition
	SET_SPR16H_16COL a0,spr2,spr3

	rts
	
;---------------------------------------------

_ClearGameScreen:
ClearGameScreen:

	movem.l	d0-d1/a0-a1,-(sp)

	move.l LogicScreenBuffer,a0
	move.l PhysicScreenBuffer,a1
	move.w	#((((512/8)*320)*BITPLANES)/4)-1,d0
	moveq	#0,d1 
clear:
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbra	d0,clear
			
	movem.l	(sp)+,d0-d1/a0-a1
	rts
	
	
	
	
	


	
	
	;	move.w	CAR_XPOS(a3),d3
;	move.w	CAR_YPOS(a3),d4
;	move.w	CAR_FRAME(a3),d5
;	sub.w	Map_x,d3
;	sub.w	Map_y,d4
;	add.w	#-2,d3  ; (-2)should not have to do this!
;	add.w	#GAME_YOFF-16,d4
;
;	cmp.w	#-2-SPRITE_CAR_WIDTH,d3
;	blt.w	.CarSpriteOffScreen
;    	cmp.w	#SCREENHEIGHT+GAME_YOFF-16+SPRITE_CAR_HEIGHT,d4
;    	bge.w	.CarSpriteOffScreen
;    	cmp.w	#GAME_YOFF-16-SPRITE_CAR_HEIGHT,d4
;    	blt.w	.CarSpriteOffScreen
;     	cmp.w	#SCREENWIDTH+-2+SPRITE_CAR_WIDTH,d3
;    	bge.w	.CarSpriteOffScreen
;
;	bsr	CarSprite32x20
;	BRA.S	.skip
;.CarSpriteOffScreen
;	move.w	#400,d3
;	move.w	#400,d4
;	bsr	CarSprite32x20
;.skip