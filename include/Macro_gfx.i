
;----------------------------------------------------------------
FASTBLIT_ON	MACRO
		move.w	#$8400,dmacon+custom
		ENDM
;----------------------------------------------------------------
FASTBLIT_OFF	MACRO
		move.w	#$0400,dmacon+custom
		ENDM
;----------------------------------------------------------------
BLTSIZE		MACRO
    		move.w	#(((\2)&$3ff)<<6)+((\1)&$3f),BLTSIZE+custom
		ENDM
;-------------------------------------------
BltWait		Macro
;; 		move.w	#$fff,$dff180
		btst	#6,DMACONR+CUSTOM ;amiga work around
Wait\@:
;;		add.l	#1,debugwaittime
		Btst	#6,DMACONR+CUSTOM
		bne.s	Wait\@
;; 		move.w	#$000,$dff180
		endm
;----------------------------------------------------------
WAIT_VBLS	MACRO
		movem.l	d0-1,-(sp)
		move.l	#\1-1,d0	; wait n lines
\@loop		move.b	6+custom,d1	; read current raster position
\@wait		cmp.b	6+custom,d1
		beq.s	\@wait		; wait until it changes
		dbf	d0,\@loop	; do it again
		movem.l	(sp)+,d0-1
		ENDM
;----------------------------------------------------------------
WaitScreen	MACRO
wait\@		tst.w	ScreenRefreshed
		beq.s	wait\@
		move.w	#0,ScreenRefreshed
		ENDM
;----------------------------------------------------------------
;;;;;;CLR_SCREEN_BUFFER 	MACRO
;;;;;;	BltWait		
;;;;;;	FASTBLIT_ON
;;;;;;	move.w	#0,bltdmod+custom
;;;;;;	move.l	#$01000000,bltcon0+custom
;;;;;;	move.l	\1,BltDpt+CUSTOM
;;;;;;	move.w	#(((256*2)*64)+((320+32)/16)),bltsize+CUSTOM	
;;;;;;	move.l	\1,d0
;;;;;;	add.l 	#((((320+32)/8)*256)*2),d0
;;;;;;	BltWait		
;;;;;;	move.l	d0,bltDpt+CUSTOM
;;;;;;	move.w	#(((256*2)*64)+((320+32)/16)),bltsize+CUSTOM
;;;;;;	BltWait	
;;;;;;	FASTBLIT_OFF
;;;;;;	ENDM
;--------------------------------------------
SCREEN_SWAP	MACRO
	move.l	LogicScreenBuffer,d0
	move.l	PhysicScreenBuffer,d1 
	move.l	d0,PhysicScreenBuffer
	move.l	d1,LogicScreenBuffer
	ENDM
;--------------------------------------------
SET_SCREEN_POINTER 	MACRO
 	lea	\1,a0	
	move.l	\2,d0
	move.l	#\3,d2
	move.w	#\4-1,d3
\@ScreenPointer
	move.l	d0,d1
	move.w	d1,4(a0)		;Stuff the lo/hi pointers into the
	swap	d1			;bitplane pointers in the copperlist
	move.w	d1,(a0)
	addq.l	#8,a0			;Next set of bitplane pointers
	add.l	d2,d0			;Next bitplane
	dbra	d3,\@ScreenPointer	
	ENDM
;------------------------------------------
SET_SPR16H_16COL	MACRO
		;move.l	d7,-(sp)
		move.l	\1,d7
		move.w	d7,\2_l
		swap	d7
		move.w	d7,\2_h
		swap	d7
		add.l	#((SPRITE_CAR_HEIGHT+2)*2*2),d7
		move.w	d7,\3_l
		swap	d7
		move.w	d7,\3_h
		;move.l	(sp)+,d7
		ENDM
;-----------------------------------
SET_SPR128H_16COL	MACRO

		move.l	d7,-(sp)
		move.l	\1,d7
		move.w	d7,\2_l
		swap	d7
		move.w	d7,\2_h
		swap	d7
		add.l	#((128+2)*2*2),d7
		move.w	d7,\3_l
		swap	d7
		move.w	d7,\3_h
		move.l	(sp)+,d7
		ENDM
;-----------------------------------------
SET_SPRITE_PALETTE 	MACRO
	move.l	#\1,a0		
	bsr SetSpritePaletteRoutine	
	ENDM
;-------------------------------------------
SET_PALETTE 	MACRO
	move.l	#\1,a0		
	move.l	#\2,a1
	move.w	#(\3)-1,d0
	bsr SetPaletteRoutine	
	ENDM
;------------------------------------------

;F_PLOT	MACRO
;;	movem.w	d0-d3,-(sp)
;	move.b	\3,d2 ;COLOUR
;	move.w	\1,d0
;;	add.w	XscreenOffset,d0
;;	sub.w	map_x,d0
;	add.w	d6,d0
;	move.w	\2,d1
;;	add.w	YScreenOffset,d1	
;;	sub.w	map_y,d1
;	add.w	d7,d1
;	bsr	plot
;;	movem.w	(sp)+,d0-d3
;	ENDM
;-----------------------------------------

CopperWait	Macro	xpos,ypos
		dc.w	(\2<<8)|(\1>>1)|1
		dc.w	$8000+$7ffe
		endm
;------------------------------------------
CopperMove	Macro
		dc.w	\2,\1
		endm
;------------------------------------------
CopperSkip	Macro	xpos,ypos
		dc.w	(\2<<8)|(\1>>1)|1
		dc.w	$8000+$7fff
		endm
;------------------------------------------
;NAME   :- Copper_Set
;USE    :- Sets up the copperlist, then triggers it
;USEAGE :- Copper_Set	"CopperList"	:- Name of copperlist
Copper_Set	MACRO
		move.l  #\1,$80+custom
		move.w	#0,$88+custom
		ENDM
;-------------------------------------------