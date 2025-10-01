		****************
		*** JOYSTICK ***
		****************


Joy0:	

	lea	CarList,a3
	btst	#7,$bfe001	; FIRE
	bne.s	Joy0NoFireButton

	or.w	#JOY_UP,CAR_JOY_DIR(A3)	


Joy0NoFireButton		

;;		Move.w  $DFF00A,d0	; JOY0DAT
		Move.w  $DFF00C,d0	; JOY1DAT
		

	
		; -- *** JOY DOWN ***
		Move.w	d0,d1
		move.w  d0,d2	
		and.w	#1,d1          	\
		and.w	#2,d2            \
		lsr.w	#1,d2            bit0 EOR bit1
		Eor.w	d2,d1           /
		Beq.s	NO_DOWN0				
		or.w	#JOY_DOWN,CAR_JOY_DIR(A3)
		bra.s	NO_UP0
 	NO_DOWN0:  
   		;-- *** JOY UP ***
   		Move.w	d0,d1
   		move.w	d0,d2
   		and.w	#256,d1		\
		and.w	#512,d2		 \
		lsr.w	#1,d2 		  Bit8 EOR Bit9
		Eor.w	d1,d2	  	 / 
		Beq.s	NO_UP0			
		LAUNCH_ROCKET	a3
	NO_UP0:
		; *** RIGHT ***   	
  		Btst	#1,d0
   		Beq.s	NO_RIGHT0
   		or.w	#JOY_RIGHT,CAR_JOY_DIR(A3)
		RTS
   	NO_RIGHT0:
   		; *** LEFT ***
   		Btst	#9,d0
   		Beq.s	NO_LEFT0
   		or.w	#JOY_LEFT,CAR_JOY_DIR(A3)
   		RTS
   	NO_LEFT0:   
   	
  	Rts

;------------------------------------------------------

; 	*********************
; 	*** Mouse Routine ***
; 	*********************
;
; 	OUTPUT: VAR MouseX 
;	      	MouseY   

DoMouse
	move.b 	$dff00b,d0	;(X) direct mouse coords, but 0-255 range only!
	move.b	d0,d2
	move.b 	$dff00a,d1	;(Y)
	move.b	d1,d3

	sub.b	OldMouseX,d0	; Distance of X
	ext.w	d0
	sub.b	OldMouseY,d1	; Distance of Y
	ext.w	d1

	move.b	d2,OldMouseX
	move.b	d3,OldMouseY

	cmp.w	#127,d0		;wrap around x
	blt.s	DoneX
	sub.w	#256,d0
	bra.s	DoneX
XNeg:	cmp.w	#-127,d0
	bgt.s	DoneX
	add.w	#256,d0
DoneX:
	cmp.w	#127,d1		;wrap around y
	blt.s	Clip
	sub.w	#256,d1
	bra.s	Clip
YNeg:	cmp.w	#-127,d1
	bgt.s	Clip
	add.w	#256,d1

Clip:	
	move.w	_MouseX,d2
	add.w	d0,d2
	move.w	_MouseY,d3
	add.w	d1,d3
	
	;-------------------
	; LIMIT MOUSE ON X
	tst.w	d2
	bge.s	MinLimitX
	move.w	#0,d2
MinLimitX
	cmp.w	#320+22,d2
	ble.s	MaxLimitX
	move.w	#320+22,d2
MaxLimitX	
	;-------------------
	; LIMIT MOUSE ON Y
	tst.w	d3
	bge.s	MinLimitY
	move.w	#0,d3
MinLimitY
	cmp.w	#255,d3
	ble.s	MaxLimitY
	move.w	#255,d3
MaxLimitY
	;-------------------

	move.w	d2,_MouseX
	move.w	d3,_MouseY
	
	rts


;------------------------------------------
;Support function for c programs
;i.e  if ( MouseButton () )
;			Dosomething();

_MouseButton
		move.l	#0,d0
		btst	#6,$bfe001
		bne	.skip
		move.l	#1,d0
.skip

		rts
;--------------------------------------------