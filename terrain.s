Process_Terrian:
	move.l	MapDataBuffer,a0
	lea	MAPHEADER_DATA(a0),a0	;+24 skip header
	moveq	#MAX_CARS-1,d7 		;loop

	move.l	HitDataBuffer,a1
	lea	CarList,a3
	lea	car_road_grip_table,a4  

CheckLoop:
	move.w	d7,-(sp)
	bsr.s	Check_Scene_Block	
	move.l	BlockAddrUnderCar,CAR_SCENE_ADR(a3) 	;store block addr, MUST BE DONE
							;OUTSIDE check_scene_block!!!
	move.l	CAR_TURN_SKID(a3),d6
	cmp.l	#$10000+($8000/2),d6
	bge.s	skipclearskidsound
		;***CLEAR ANY SKID SOUNDS***
		cmp.w	#SAM_SKID113|SAM_LOOP,CAR_PLAY_SND_LASTNUM(a3)	; playing skid sound?
		bne.s	skipclearskidsound
		move.w	#SAM_STOP,CAR_PLAY_SND_NUM(a3)	;clear
skipclearskidsound:

	lea	CAR_SIZEOF(a3),a3
	move.w	(sp)+,d7
	dbra	d7,Checkloop

	rts
;------------------------------------------------

Check_Scene_Block:

	moveq	#0,d1	; clear for long use later.
	move.l	d1,d2
	move.l	d1,d4	;
	
	move.w	CAR_XPOS(a3),d0
	add.w		#CAR_BLIT_WIDTH/2,d0
	lsr.w	#4,d0
	move.w	CAR_YPOS(a3),d1
	add.w		#CAR_BLIT_HEIGHT/2,d1
	
;;;;;;;;;;;;;;	sub.w	#8,d1

	and.w	#$fff0,d1	;*** was lsr.w #4,d1 ***
	lsl.w	#7-4,d1   	;***	 lsl.w #7,d1 ***
	add.w	d0,d1
	add.w	d1,d1		; Scale to .w index for Map Values
	move.w	(a0,d1.w),d0	; Find Block no# under car
	move.b	(a1,d0.w),d4 	; Index Block no# into HitData table
				; Result = Terrian type.
				; ie 0:Road,1:solid,2:Corner...
	add.w	d4,d4		; word index 
	;---------------------------------------------	

	;*** CAR_FRICTION *** 
	move.l	#$ffff0000,d2   ;will be a small number 0.999 after swap
	move.w	(A4,d4.w),d2    ; car_road_grip_table
	
	;*** Slowly clear tire marks ***
	move.l	CAR_TREDMARKS(a3),d0 
	lsr.l	#1,d0
	move.l	d0,CAR_TREDMARKS(a3)	
	;----------------------------------
	;Skid marks are clear by this time.  e.g. sand,grass...
	;By doing things in this order it save on CPU time.
	;A large skid? it must be oil...
	;(code is a bit messy, can't think of another way!)
	tst.w	CAR_TREDMARKS+2(A3)
	beq.s	.skip
	move.w	#6,d2	;keep skid going when leaving oil
.skip:	
	;----------------------------------

	
	swap	d2
	move.l	d2,CAR_ROAD_GRIP(a3)
	
	;----------------------------------------------------
	; *** WHEN USING CASES BELLOW ***
	; DONT TRASH REGESTERS USED FOR LOOPS,etc.
	;-----------------------------------
	; *** A0:D1 BASE+OFFSET INTO MAP
	; *** D0 = MAP ADR UNDER CAR (a0+d1)
	;-----------------------------------
	move.l	A0,D0  		;MapDataBuffer
	add.l	D1,D0

	move.l	d0,BlockAddrUnderCar
	
	;move.w	HIT_TABLE(PC,D4.W),D4	; 14 cycles
	;jmp	HIT_TABLE(PC,D4.W)	; 14 cycles
	move.w	HIT_TABLE(PC,D4.W),D2	; 14 cycles
	jmp	HIT_TABLE(PC,D2.W)	; 14 cycles
	; This point is never reached!!

HIT_TABLE:
	EVEN
	DC.W	Road-HIT_TABLE,Solid-HIT_TABLE
	DC.W	Corner-HIT_TABLE,Grass-HIT_TABLE
	DC.W	Cone-HIT_TABLE,Mine-HIT_TABLE
	DC.W	Fence-HIT_TABLE,PickUp-HIT_TABLE
	DC.W	Plants-HIT_TABLE,Sand-HIT_TABLE
	DC.W	Bumpy-HIT_TABLE,MudBubble-HIT_TABLE
	DC.W	Rocks-HIT_TABLE,Oil-HIT_TABLE
	DC.W	Water-HIT_TABLE,Lamp-HIT_TABLE
	DC.W	Spike0-HIT_TABLE,Spike1-HIT_TABLE
	DC.W	Car18-HIT_TABLE,Car19-HIT_TABLE
	DC.W	Car20-HIT_TABLE,Car21-HIT_TABLE
	DC.W	Car22-HIT_TABLE
	EVEN
	
;-------------------------------------------------------
Road:	;00

	;add skid pattern + turn sounds 
	move.l	CAR_TURN_SKID(a3),d6
	cmp.l	#$10000+($8000/2),d6
	blt.s	skiproadskid
		move.l	CAR_TREDMARKS(a3),d2
		lsl.l	#1,d2
		or.l	#%1,d2
		move.l	d2,CAR_TREDMARKS(a3)
		
		cmp.w	#SAM_SKID113|SAM_LOOP,CAR_PLAY_SND_LASTNUM(a3) 	; What sample was played last time?
		beq.s	skiproadskid ;;;@NoSkidsFound
		move.w	#SAM_SKID113|SAM_LOOP,CAR_PLAY_SND_NUM(a3)	; SOUND ON
skiproadskid

	RTS
	
;-------------------------------------------------------------

Solid:  ;01

	move.l	#0,CAR_SPEED(a3)
	move.l	CAR_LASTXPOS(a3),CAR_XPOS(A3)
	move.l	CAR_LASTYPOS(a3),CAR_YPOS(a3)

	neg.l	CAR_VELX(a3)
	neg.l	CAR_VELY(a3)
	
	move.l	#%100010011,CAR_TREDMARKS(a3)
	move.l	#$ffff,d0
	jsr	Random
	sub.l	#($ffff/2),d0
	lsl.l	#2,d0	;scale up
	move.l	d0,CAR_TURN_AMOUNT(a3)

	move.w	#SAM_FENDER,CAR_PLAY_SND_NUM(a3)
	
	RTS
;-------------------------------------------------------------
Corner:	;02

	WOBBLE_CAR 	A5,D6
	rts
;-------------------------------------------------------------
Grass:	;03

	WOBBLE_CAR	A5,D6	
	move.l	#1,CAR_TREDMARKS(a3)
	rts
;-------------------------------------------------------------
Cone:	;04 
	WOBBLE_CAR A5,D6

	cmp.l	CAR_SCENE_ADR(a3),d0
	beq.s	Dont_Splat_Cone		; Car is already over cone
	add.w	#SIZE_WORD,Run_Over_Counter
	and.w	#CYCLE_COUNTER,Run_Over_Counter
	lea	Cone_Over_List,a5
	move.w	Run_Over_Counter,d6
	move.w	(a5,d6.w),(a0,d1)
	
	move.w	#SAM_BITS,CAR_PLAY_SND_NUM(a3)
Dont_Splat_Cone:
	
	rts
;-------------------------------------------------------------
Mine:	;05
	;;;;;;;;;WOBBLE_CAR A5,D6
	;-------------------------------------------------------
	add.w	#SIZE_WORD,Run_Over_Counter
	and.w	#CYCLE_COUNTER,Run_Over_Counter
	lea	Mine_Over_List,a5
	move.w	Run_Over_Counter,d6
	move.w	(a5,d6.w),(a0,d1)	; Blast hole in Road
	;-------------------------------------------------------
	move.w	CAR_XPOS(a3),d0
	and.w	#$fff0,d0
	add.w	#8,d0
	move.w	CAR_YPOS(a3),d1
	sub.w	#8,d1
	and.w	#$fff0,d1
	add.w	#8,d1
	
	move.w	#EXP01,d2
	bsr	MakeExplosion	;in d0,d1,d2 
	
	;----------------------------------------------------
	move.l	#%10001001100110110111111111111110,CAR_TREDMARKS(a3)
	move.l	#$ffff,d0
	jsr	Random
	sub.l	#($ffff/2),d0
	lsl.l	#2,d0	;scale up
	move.l	d0,CAR_TURN_AMOUNT(a3)
	rts
;-------------------------------------------------------------
Fence:	;06
	WOBBLE_CAR A5,D6
	add.w	#1,(a0,d1)	;Degrade fence.
	rts
;-------------------------------------------------------------
PickUp:	;07
	move.w	#MAPICON_CLEAR_ROAD,(a0,d1)		; 17 = Normall Road
	rts
;-------------------------------------------------------------
Plants:	;08
	rts
;-------------------------------------------------------------
Sand:	;09
	WOBBLE_CAR A5,D6
	move.l	#1,CAR_TREDMARKS(a3)
	rts
;-------------------------------------------------------------
Bumpy:		;10
	
	WOBBLE_CAR_ALWAYS a5,d6
	move.l	#1,CAR_TREDMARKS(a3)
	rts
;-------------------------------------------------------------
	
MudBubble:	;11
	WOBBLE_CAR A5,D6
	rts
;-------------------------------------------------------------
Rocks:	;12
	WOBBLE_CAR A5,D6
	move.l	#1,CAR_TREDMARKS(a3)
	rts
;-------------------------------------------------------------
Oil:	;13
	move.l	#%10001000010010010010010101010111,CAR_TREDMARKS(a3)
	rts
;-------------------------------------------------------------
Water:	;14


	move.l	#0,CAR_SPEED(a3)
	move.l	CAR_LASTXPOS(a3),CAR_XPOS(A3)
	move.l	CAR_LASTYPOS(a3),CAR_YPOS(a3)
	neg.l	CAR_VELX(a3)
	neg.l	CAR_VELY(a3)
	move.l	#$ffff,d0
	jsr	Random
	sub.l	#($ffff/2),d0
	asl.l	#2,d0	;scale 
	move.l	d0,CAR_TURN_AMOUNT(a3)

	move.w	#SAM_SEA,CAR_PLAY_SND_NUM(a3)
	rts
;-------------------------------------------------------------
Lamp:	;15
	add.w	#1,(a0,d1)	; Damage street lamp (start it flashing)
	bra	Solid
	rts	;rts before this point, just incase code changes later!
;-------------------------------------------------------------
Spike0:	;16 *** Spike Down ***
	rts
;-------------------------------------------------------------
Spike1: ;17 *** Spike Up ***
	RTS
;-------------------------------------------------------------
Car18:
Car19:
Car20:
Car21:
Car22:
	rts
;--------------------------------------------------------------------------
			EVEN
BlockAddrUnderCar:	dc.l	0

CYCLE_COUNTER		EQU	%1111

Run_Over_Counter:	dc.w	0

Cone_Over_List:		dc.w	741,741,716+1,741	; SPLATTED CONE ICONS
			dc.w	741,716+2,716,716+3	; in a random order
							; or 741=animate
			
Mine_Over_List:		dc.w	3,4,5,6	;DAMAGED ROAD ICONS
			dc.w	7,3,4,5
		
car_road_grip_table: 	
			DC.w	2	; ROAD,
			DC.w 	1	; SOLID
			DC.w	3	; CORNER,
			DC.w 	3	; GRASS
			DC.w	4	; CONE,
			DC.w 	6	; MINE  
			DC.w	5	; FENCE,
			DC.w 	1	; PICKUP
			DC.w	3	; PLANTS,
			DC.w	4	; SAND
			DC.w	3	; MUD,
			DC.w 	3	; BUMPY
			DC.w	1	; ROCKS,
			DC.w	6	; OIL
			DC.w	1	; WATER,
			DC.w 	1	; LAMP
			DC.w	1	; SPIKE0 down,
			DC.w 	4	; SPIKE1 up
			;need to put a check in init time to get rid of
			;any invalid numbers in map
			DC.w	3,3,3,3,3,3,3,3,3,3,3,3,3,3	 
			EVEN
			
			
;;DEBUG TEXT  ****** Text List ******
;;text_pnt	dc.l	t0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10
;;		dc.l	t11,t12,t13,t14,t15,t16,t17,t18,t19
;;t0:		dc.b 	"Road  ",0
;;t1:		dc.b 	"Solid ",0
;;t2:		dc.b 	"Corner",0
;;t3:		dc.b 	"Grass ",0
;;t4:		dc.b 	"Cone  ",0
;;t5:		dc.b 	"Mine  ",0
;;t6:		dc.b 	"Fence ",0
;;t7:		dc.b 	"PickUp",0
;;t8:		dc.b 	"Plants",0
;;t9:		dc.b 	"Sand  ",0
;;t10:		dc.b 	"Mud   ",0
;;t11:		dc.b 	"Bumpy ",0
;;t12:		dc.b 	"Rocks ",0
;;t13:		dc.b 	"Oil   ",0
;;t14:		dc.b 	"Water ",0
;;t15:		dc.b 	"Lamp  ",0
;;t16:		dc.b 	"Spike0",0
;;t17:		dc.b 	"Spike1",0
;;t18:		dc.b 	"*******",0
;;t19:		dc.b 	"*******",0

;------------------------------------------------


