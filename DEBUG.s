	DebugStuff:
	
	txt_str		#32,#22,"____________"
	txt_str		#32,#32,"____________"
	
	;lea	carlist,a3
	;move.w	CAR_TURN_SKID(a3),d0
	;move.w	CAR_PLAY_SND_LASTNUM(a3),d0
	;move.w	ScreenBlocksHeight,d0
	;move.w	CAR_ROAD_GRIP(a3),d0
	
	
;;;	move.w	BlocksDown,d0
;;;	ext.l d0
;;;	txt_val	#32,#22,d0
	
	move.w	Lastkeypressed,d0
	ext.l d0
	txt_val	#32,#32,d0

	rts

	;---------
	BltWait
	
	move.w	#$09f0,bltcon0+custom
	move.w	#0,bltcon1+custom

	move.w	#$0,bltalwm+custom
	move.w	#$0,bltafwm+custom	
	move.w	#((512/8)*BITPLANES)-12,BLTDMOD+custom
	move.w	#0,bltAmod+custom
	move.l	#(512/8)*64*4+4,d3
	
	add.l		LogicScreenBuffer,d3
	move.l	d3,bltDpt+CUSTOM
	move.l	CollisionBuffer,d3
	move.l	d3,bltApt+CUSTOM
	bLTSIZE	2*3,20*3
	;---------
	BltWait


	rts