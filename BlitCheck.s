ProcessCars_Crash:

	lea		carlist,a3
	move.l	a3,a4

	move.l	CarGfxBuffer1,d1  ; if car design changes then so MUST this!!!
	add.l		#4*20*4,d1
	move.l	CollisionBuffer,d2
	add.l		#(32/8)+(20*(96/8)),d2
	
	moveq		#0,d0
;;;;;	move.l	d0,D7
	
	move.w	CAR_FRAME(a3),d0
	;----------------------------
	;;was....	mulu	#(4*20*4)+(4*20),d0
	;;;;;	add.l	d0,d1
	lsl.w	#4,d0 	;*16		6cy+(2*4) =14
	add.l	d0,d1 	;		4
	lsl.w	#3,d0	;...*128	6+(2*3)  =12
	add.l	d0,d1	;		4
	add.w	d0,d0	;...*256	4
	add.l	d0,d1	;		4
	;-----------------------------tot=42

	move.l	d1,a0 ; store
	move.l	d2,a1

;;;	; place car mask in centre of test area
;;;	BltWait	
;;;	move.l	#$09f00000,bltcon0+custom
;;;	move.w	#$ffff,bltalwm+custom
;;;	move.w	#$ffff,bltafwm+custom
;;;	move.w	#(96/8)-(32/8),BLTDMOD+custom
;;;	move.w	#0,bltAmod+custom
;;;	move.l	d1,bltApt+CUSTOM
;;;	move.l	d2,bltDpt+CUSTOM
;;;	FASTBLIT_ON
;;;	BLTSIZE	2,20
	;-----------------------------------------------

	move.w	CAR_XPOS(a3),d0	;keep player coords
	move.w	CAR_YPOS(a3),d1

	move.w	#MAX_CARS-2,d7  ; don't need to test car1
	
TestCrashLoop:
	lea	CAR_SIZEOF(a3),a3
	
	move.w	CAR_XPOS(a3),d4
	sub.w		d0,d4
	move.w	CAR_YPOS(a3),d5
	sub.w		d1,d5
	
	;----
	; quick collision test
	move.w		d4,d2		
	ABS_w_NO_TST	d4
	move.w		d5,d3
	ABS_w_NO_TST	d5
                
	cmp.w	#CAR_BLIT_WIDTH,d4
	bge	NoOverLap
	cmp.w	#CAR_BLIT_HEIGHT,d5
	bge	NoOverLap
	;----



	; place joystick car mask in centre of test area
	; It is possible for this to be drawed more than once (no harm will come of it).
	; It's just NOT WORTH another test here as it will hardly ever happen.
	; plus if a collision was detected it leaves to loop anyway.
	
	BltWait	
	move.l	#$09f00000,bltcon0+custom
	move.w	#$ffff,bltalwm+custom
	move.w	#$ffff,bltafwm+custom
	move.w	#(96/8)-(32/8),BLTDMOD+custom
	move.w	#0,bltAmod+custom
	move.l	a0,bltApt+CUSTOM
	move.l	a1,bltDpt+CUSTOM
	FASTBLIT_ON
	BLTSIZE	2,20




	move.l	CarGfxBuffer1,d4
	add.l		#4*20*4,d4
	move.w	CAR_FRAME(a3),d0	; (the whole long should of been cleared at some point)
;;;;;;;;;	mulu	#(4*20*4)+(4*20),d0
;;;;;;;;;	add.l	d0,d4
	;----------------------------
	lsl.w	#4,d0 	;*16		6cy+(2*4) =14
	add.l	d0,d4 	;		4
	lsl.w	#3,d0	;...*128	6+(2*3)  =12
	add.l	d0,d4	;		4
	add.w	d0,d0	;...*256	4
	add.l	d0,d4	;		4
	;-----------------------------tot=42
	
	move.w	d2,d5 	;d6,d5
	and.w		#$f,d5
	ror.w		#4,d5		;place in bits12-15
	
	BLTWAIT
	
;;;	move.w	#0,bltadat+custom
;;;	move.w	#0,bltbdat+custom
	move.l	#0,bltbdat+custom		;$DFF070=BLTCDAT, *** USING $072=B,$074=A ***
	
	add.w		#$0cc0,d5
	move.w	d5,bltcon0+custom	
	move.w	#0,bltcon1+custom
	
	move.w	#$ffff,bltafwm+custom
	move.w	#$0,bltalwm+custom
;	move.l	#$ffff0000,bltafwm+custom; fwm=$044,lwm=$046

	move.w	#-2,bltAmod+custom
  	move.w	#(96/8)-((32+16)/8),BLTBMOD+custom   

	move.l	CollisionBuffer,d5
	add.l	#(32/8)+(20*(96/8)),d5
;;;;;;;;;muls	#(96/8),d7
;;;;;;;;add.l	d3,d5
	ext.l	d3
	;----------------------
	asl.l	#2,d3
	add.l	d3,d5 
	add.l	d3,d3 
	add.l	d3,d5 
	;------------------


	asr.w	#3,d2
	ext.l	d2
	add.l	d2,d5
	
	move.l	d5,bltBpt+CUSTOM	;UPDATED MASK
	move.l	D4,bltApt+CUSTOM	;CAR FIXED MASK
	BLTSIZE	3,20
	
	BltWait
	FASTBLIT_OFF
	
	;-----------------------------------
;;;;;;;;	move.l	#0,d0
;;;;;;;;	move.w	DMACONR+custom,d0
	btst	#5,DMACONR+CUSTOM
	bne	NoOverLap	; Crash?
	
	;-------------------------------------------------------------------------
	;;;;;lea	CarList,A2				;plr always first in list
 	move.l	#8<<16,CAR_ROAD_GRIP(a3) 		;larger for less grip
	move.l	CAR_LASTXPOS(a4),CAR_XPOS(a4)
	move.l 	CAR_LASTYPOS(a4),CAR_YPOS(a4)
	move.l	CAR_VELX(a4),CAR_VELX(a3)
	move.l	CAR_VELY(a4),CAR_VELY(a3)
	;;;move.l	CAR_SPEED(a4),CAR_SPEED(a3)
	move.l	CAR_SPEED(a4),d6
	asr.l		#3-1,d6
	sub.l		d6,CAR_SPEED(A4)
	move.l	#%1000101010111111,CAR_TREDMARKS(a3) 	;on/off skid pattern
	;--------------------------------------------------------------------------


	move.w	#SAM_FENDER,CAR_PLAY_SND_NUM(a4)	; SOUND ON
NoOverLap:
		
	dbra	d7,TestCrashLoop
	RTS