CamraView:
	move.l	CameraTarget,a3

;;;	moveq.l	#0,d0
;;;	move.l	d0,d1
;;;	MOVE.L	D0,D2	
	
	Move.w	CAR_XPOS(a3),d0
	Move.w	CAR_YPOS(a3),d1
	
	add.w		#(CAR_BLIT_WIDTH/2)-(SCREENWIDTH/2),d0 ;centre
	add.w		#(CAR_BLIT_HEIGHT/2),d1

	move.w	ScreenBlocksHeight,d2	; reduce by half screen height
	lsr.w		#1,d2
	sub.w		d2,d1

	;-------------------------
	;Limit Camera to map, also limit it to 1 block clear round the edge.
	;This is a brick wall drawn in code, saves calculating later on 
	;to see if any of the cars have left the map area.
	cmp.w		#BLOCK_SIZE,d0
	bge.s		.InsideScreenX
	moveq.l	#BLOCK_SIZE,d0
.InsideScreenX

	cmp.w		#BLOCK_SIZE,d1
	bge.s		.InsideScreenY
	moveq.w	#BLOCK_SIZE,d1
.InsideScreenY

	cmp.w		#(128*16)-SCREENWIDTH-BLOCK_SIZE,d0
	blt.s		.InsideScreenWidth
	move.w	#(128*16)-SCREENWIDTH-BLOCK_SIZE,d0
.InsideScreenWidth

	cmp.w		#(128*16)-SCREENHEIGHT-BLOCK_SIZE,d1
	blt.s		.InsideScreenHeight
	move.w	#(128*16)-SCREENHEIGHT-BLOCK_SIZE,d1
.InsideScreenHeight


	;-------------------------
;
;	bra Dont_CameraCatchup
;
;	;-------*** CAMERA CATCH UP ***
;	tst.l	CameraTimer
;	beq.s	Dont_CameraCatchup
;
;	swap d0
;	swap d1
;
;	sub.l	Map_X,d0
;	asr.l	#3,d0
;	add.l	d0,Map_X
;	sub.l	Map_Y,d1
;	asr.l	#3,d1
;	add.l	d1,Map_Y
;
;	sub.l	#1<<16,CameraTimer
;	move.w	map_x,d0
;	and.w	#$fff0,d0
;	MOVE.W	d0,Bob_Map_x
;	move.w	map_y,d0
;	and.w	#$fff0,d0
;	MOVE.W	d0,Bob_Map_y
;
;	RTS
;	;--------
;Dont_CameraCatchup:

	move.w	d0,Map_X
	move.w	d1,Map_Y

	move.w	map_x,d0
	and.w		#$fff0,d0
	MOVE.W	d0,Bob_Map_x

	move.w	map_y,d0
	and.w		#$fff0,d0
	MOVE.W	d0,Bob_Map_y

	RTS


