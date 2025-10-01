
READ_ARROW_MAP 	MACRO		;a5=CarTurnToFace
	move.w	CAR_XPOS(a3),d0
	lsr.w	#4,d0
	move.w	CAR_YPOS(a3),d1
	and.w	#$fff0,d1
	lsl.w	#3,d1
	add.w	d1,d0
	MOVE.b	(a4,d0),d0  ;arrow data
	ext.w	d0

	move.w 	CAR_FRAME(a3),d1
	sub.w	d0,d1
	add.w	d1,d1
	move.w	(a5,d1.w),d1			;CarTurnToFace
	move.w	d1,CAR_JOY_DIR(a3)
	ENDM

;------------------------------------------------------

ProcessCars_CPU:
	move.l	ArrowDataBuffer,a4
	lea	CarTurnToFace,a5
	lea	CarList,a3
	move.w	#MAX_CARS-1,d7			;loop
	
	ProcessCPUCarsLoop:
	
	   	cmp.w #CAR_CPU,CAR_TYPE(a3)
	   	;;bne.s	NotCpuCar
			;;READ_ARROW_MAP
			;;or.w	#JOY_UP,CAR_JOY_DIR(a3)
	   	;;NotCpuCar:
	   	lea	CAR_SIZEOF(a3),a3 		;next car
	   	
	dbra	d7,ProcessCPUCarsLoop

	rts
	
;------------------------------------------------------
CAR_VELOCITY	MACRO	; Returns d2,d3
	; Inputs: d0:SPEED,d1:FRAME
	; a0:CarDir_x_table, a1:CarDir_y_table, a2:DRIVESpeed

	lsl.w	#2,d1	     ; use .l index	
;;	add.w	d0,d0	     ; use .w index
;;	add.w	(a2,d0.w),d1 ; DriveSpeed Table

	lsl.w	#8,d0 ; no longer need above table, frames are now 64
	add.w	d0,d1 ; data is (speed*64*4) + (frame*4)
	
	move.l	(a0,d1.w),d2 ; x
	move.l	(a1,d1.w),d3 ; y

	tst.w	d0
	Bpl.s	.pos_speed
	neg.l	d2
	neg.l	d3
.pos_speed

	ENDM

;------------------------------------------------------
HANDBRAKE	macro

	tst.w	CAR_SPEED(a3)
	beq	.DontReduceSpeed
	tst.l	CAR_TREDMARKS(a3)
	bne.s	.skip
	move.l	#%11111111111111110110110011001000,CAR_TREDMARKS(a3)
.skip
	move.l	#0,CAR_SPEED(a3)
.dontReduceSpeed	

	endm
;---------------------------------------------------

ProcessCars_Travel:

	lea 	CarDir_x_table,a0
	lea 	CarDir_y_table,a1
;;	lea	DriveSpeed,a2
	lea	CarList,a3

	move.w	#MAX_CARS-1,d7	;loop
ProcessCarsLoop:

	move.w	CAR_ROAD_GRIP(a3),d6
	add.w	CAR_TURN_SKID(a3),d6
	;------------------------------------
	move.l	CAR_XPOS(a3),CAR_LASTXPOS(a3)
	move.l	CAR_YPOS(a3),CAR_LASTYPOS(a3)
	;------------------------------------
	move.w	CAR_JOY_DIR(a3),d0
	move.l	CAR_TURN_AMOUNT(a3),d3
	moveq	#3,d4
	;------------------------------
	move.w	d0,d1
	and.w	#JOY_LEFT,d1		;***JOY LEFT***
	beq.s	.NoLeftFound		
	sub.l	#$00003000,d3		;turn amount
	
	moveq	#7,d4			
	add.l	#$7ff,CAR_TURN_SKID(a3)
.NoLeftFound
	;------------------------------
	move.w	d0,d1
	and.w	#JOY_RIGHT,d1		;***JOY RIGHT***
	beq.s	.NoRightFound
	add.l	#$00003000,d3		;turn amount
	
	moveq	#7,d4
	add.l	#$7ff,CAR_TURN_SKID(a3)
.NoRightFound

	cmp.w	#8,CAR_SPEED(a3)
	bgt.s	.SkidAtSpeed
	moveq	#3,d4
.SkidAtSpeed

	move.l	CAR_TURN_SKID(a3),d5
	asr.l	d4,d5
	sub.l	d5,CAR_TURN_SKID(a3)
	;-----------------------------
	
	RANGE	#-$ffff,#$ffff,d3
	
	add.l	d3,CAR_FRAME(a3)
	
	move.l	d3,d2
	asr.l	d6,d2   ;damp turn value by road grip
	sub.l	d2,d3   ;apply friction from road
	move.l	d3,CAR_TURN_AMOUNT(a3)

	LIMIT_CAR_FRAME a3

	;------------------------------
	move.w	d0,d1
	and.w	#JOY_UP,d1		;***JOY UP***
	beq	.DontSpeedUp
	add.l	#$7fff,CAR_SPEED(a3)
	and.l	#$1fffff,CAR_SPEED(a3) ; limit speed to 31	
.DontSpeedUp
	;-------------------------------	
	move.w	d0,d1
	and.w	#JOY_DOWN,d1		;***JOY DOWN***
	beq.s	DontReduceSpeed
	HANDBRAKE
DontReduceSpeed:

	move.w	#8,d1	; Less grip, less speed
	sub.w	d6,d1	
	
	move.l	CAR_SPEED(a3),d4
	asr.l	d1,d4
	sub.l	d4,CAR_SPEED(a3)

;DontReduceSpeed:
	;------------------------------------	
	move.l	CAR_VELX(a3),d2
	add.l	d2,CAR_XPOS(a3)
	move.l	CAR_VELY(a3),d3
	add.l	d3,CAR_YPOS(a3)
	;-------------------------------
	move.w	CAR_SPEED(a3),d0
	move.w	CAR_FRAME(a3),d1
	asr.l	d6,d2		;How much skid
	asr.l  	d6,d3		;
	sub.l	d2,CAR_VELX(a3)	; old velocity as skid amount
	sub.l	d3,CAR_VELY(a3)	;(ie. keep going in old direction)
	CAR_VELOCITY 		; IN d0/1 : OUT d2/3
	asr.l	d6,d2		;opposite effect, new velocity 
	asr.l	d6,d3	
	add.l	d2,CAR_VELX(a3); new direction is applied
	add.l	d3,CAR_VELY(a3); This has less effect under bad grip.
	;-------------------------------
	move.w	#0,CAR_JOY_DIR(A3)
	;--------------------------------------------------------

	lea	CAR_SIZEOF(a3),a3 ;next car
	dbra	d7,ProcessCarsLoop
	rts

;--------------------------------------------------------------

;--------------------------------------------------------------
;DoSpeedUp:
;
;		moveq	#0,d4
;
;		move.l	CAR_SPEED(a3),d1
;		move.w 	CAR_MAX_SURFACE_SPEED(a3),d4
;		swap 	d4 
;		add.l	#1<<16,d1
;		cmp.l	d4,d1
;		ble	.limit
;		move.l	d4,d1
;.limit		
;		move.l	d1,CAR_SPEED(a3)
;		moveq	#0,d2
;		cmp.w	#7,CAR_SPEED(a3)	;MAKE THIS TABLE DRIVEN
;		ble.s	.NoTurnSkid
;		move.l	#%1,d2			;SKID MARK PATTERN
;.NoTurnSkid
;		bra	DontReduceSpeed
;--------------------------------------------------------------
