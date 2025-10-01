LAUNCH_ROCKET	MACRO
	move.l	InterruptTimer,d7
	sub.l		RELOADING_ROCKET(\1),d7		;diff
	cmp.l		#ROCKET_RATE,d7
	blt.s		\@Dont_Launch_Rocket

	move.l	CAR_XPOS(\1),d0
	add.l		#((CAR_BLIT_WIDTH-MISSILE_WIDTH)/2)<<16,d0
	move.l	CAR_YPOS(\1),d1
	add.l		#((CAR_BLIT_HEIGHT-MISSILE_HEIGHT)/2)<<16,d1
	move.l	CAR_FRAME(\1),d2

	move.l	InterruptTimer,RELOADING_ROCKET(\1)
	bsr		LaunchRocket	;RETURNS a0 with rocket
	
\@Dont_Launch_Rocket
	ENDM
;-------------------------------------------
SET_CAR		MACRO

	move.w	\1,Param1 ; car no#
	move.l	\2,Param2 ; car xpos
	move.l	\3,Param3 ; car ypos
	move.w	\4,Param4 ; car type plr/cpu
	
	bsr PlaceCarOnMap

	ENDM
;-------------------------------------------------

ADD_CAR_SPEED	MACRO

	moveq.l	#0,d4	
	move.w 	CAR_MAX_SURFACE_SPEED(\1),d4
	swap 	d4 	
	sub.l 	CAR_SPEED(\1),d4
	asr.l  	\2,d4				;weight of car???
	add.l	d4,CAR_SPEED(\1)

	ENDM

;--------------------------------------------------
	
SUB_CAR_SPEED	MACRO

	moveq.l	#0,d4	
	move.w 	CAR_MAX_SURFACE_SPEED(\1),d4
	swap 	d4 	
	neg.l	d4
	sub.l 	CAR_SPEED(\1),d4
	asr.l  	\2,d4
	add.l	d4,CAR_SPEED(\1)

	ENDM

;----------------------------------------------

LIMIT_CAR_FRAME		MACRO

	AND.L	#$3FFFFF,CAR_FRAME(\1)	;64FRAMES scaled maths for fake floats
					;$3f gives 0to63
	
;	cmp.l	#(TOTAL_CAR_FRAMES-1)<<16,CAR_FRAME(\1)
;	ble.s	skip3\@
;	sub.l	#TOTAL_CAR_FRAMES<<16,CAR_FRAME(\1)
;skip3\@
;	tst.l	CAR_FRAME(\1)
;	bge.s	skip2\@
;	add.l	#TOTAL_CAR_FRAMES<<16,CAR_FRAME(\1)
;skip2\@
	ENDM

;-------------------------------------------
;TOP_TURN	EQU	(1<<16)    ;;;+((1<<16)/2)
;
;LIMIT_CAR_TURN_AMOUNT		MACRO
;
;	cmp.l	#TOP_TURN,CAR_TURN_AMOUNT(\1)
;	ble	turn1\@
;	move.l	#TOP_TURN,CAR_TURN_AMOUNT(\1)
;turn1\@
;	cmp.l	#-TOP_TURN,CAR_TURN_AMOUNT(\1)
;	bge	turn2\@
;	move.l	#-TOP_TURN,CAR_TURN_AMOUNT(\1)
;turn2\@
;	ENDM
;
;-------------------------------------------
		
WOBBLE_CAR	MACRO	
	;a3 nearly always has car struct
	
	move.w	CAR_SPEED(a3),\2
	asl.w	#2,\2		;word index
	lea	WobbleBySpeed_tab2tab,\1
	
	move.l	(\1,\2),\1 		;table from table
	add.w	#1,CAR_WOBBLE_COUNT(a3)      	                                
	and.w	#%1111,CAR_WOBBLE_COUNT(a3)  
	move.w	CAR_WOBBLE_COUNT(a3),\2
	lsl.l	#2,\2			;index                                
	move.l	(\1,\2),\2		;amount to wobble
	add.l	\2,CAR_FRAME(a3)    	

	LIMIT_CAR_FRAME		A3

	ENDM
	
;--------------------------------------------------------------

WOBBLE_CAR_ALWAYS	MACRO	

	;a3 nearly always has car struct
	lea	WobbleTable1,\1

	add.w	#1,CAR_WOBBLE_COUNT(a3)      	                                
	and.w	#%1111,CAR_WOBBLE_COUNT(a3)  
	move.w	CAR_WOBBLE_COUNT(a3),\2
	lsl.l	#2,\2			;index                                
	move.l	(\1,\2),\2		;amount to wobble
	add.l	\2,CAR_FRAME(a3)    	

	LIMIT_CAR_FRAME		A3

	ENDM