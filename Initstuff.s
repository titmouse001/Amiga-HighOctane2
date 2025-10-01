ICON_PLACE_CAR_PLR	EQU	2  ; place at icon block no#.
ICON_PLACE_CAR_CPU	EQU	1
ICON_BLANK_ROAD		EQU	0

;--------------------------------------------------------------------
InitialiseGameSystem:	
	RANDOMSEED	12345,54321
	bset	#1,$bfe001	;low pass filter off
	;                
	move.w	#%1000001111101111,DMACON+CUSTOM	;sprite/blitter/Copper/Bitplane

	ENABLE_LEVEL2_INTERRUPT	Level2

	;;ENABLE_LEVEL4_INTERRUPT	Lev4AudioInterrupt
	
	RTS

;-------------------------------------------------------------------------

;		 *************
;		 *** INTRO ***
;		 *************

DoIntro:

	bsr	Set_Menu_Screen
	SET_PALETTE 	   TitlePalette,MenuCol_CopperList,1<<BITPLANES 

	PLAY_MUSIC	MOD_TITLE


	TitleScreen:
		WAITSCREEN
		SCREEN_SWAP		
		;;;;;SET_SCREEN_POINTER	MenuBplanes,LogicScreenBuffer,(512)/8,BITPLANES
	MOUSE_BUTTON	TitleScreen

	RELEASE_MOUSE

	RTS

;----------------------------------------------------------------------

GameInit:

	bsr	DrawSmallPanelMap
	bsr	MakeMaplookup
	bsr	InitBlocksRestoreList
	bsr	InitStoreOldBlocks	;Force it to draw
	
	;--------------------------------
	move.w	#1,Map_x
	move.w	#1,Map_y
	;--------------------------------
	Bsr PlaceCars
	;-------------------------------------------	
	move.l	#CarList+CAR_SIZEOF*0,CameraTarget
;;;;	move.w	#CAMERA_FOLLOW_CAR,CameraTargetType
	;------------------------------------------
	move.l	#0,CameraTimer
	;------------------------------------------

	PLAY_MUSIC	MOD_INGAME1 ;;DISK_ingameMod01

	bsr	HardWare_Scroll 
	bsr 	Set_Game_Screen
	
	ENABLE_LEVEL3_INTERRUPT	Lev3CopperInterruptGame

;;;;	bsr	BlitBlocks
;;;;	bsr	HardWare_Scroll 
;;;;	bsr	BlitBlocks


	rts

;-------------------------------------------

Set_Game_Screen:

	move.w		#0,BPLCON3+custom	; NO AGA SPRITES
	
	SET_SCREEN_POINTER	BplanesGamePanel,PanelBuffer,PANEL_WIDTH/8,2
	SET_SCREEN_POINTER	BplanesFixedGamePanel,FixedPanelBuffer,PANEL_WIDTH/8,2
	SET_SCREEN_POINTER	Bplanes,LogicScreenBuffer,512/8,BITPLANES
	
	SET_SPRITE_PALETTE  	GamePalette
	SET_PALETTE 	    	GamePalette,Col_CopperList,1<<BITPLANES 	;SCREENCOLOURS
	
	bsr			DoPanel
	
	move.w	#((42+208)<<8)|(446>>1)|1,Gamecopwait

	move.w	#(GAME_XOFF+(BLOCKS_X*BLOCK_SIZE))&$FF,D0			
	move.w	#(((GAME_YOFF+GAME_YSIZE)*256)&$FF00),D1
	or.w		D0,D1
	;---------------------------------------------------------------------------
	; Hide the first column of blocks .i.e +BLOCK_SIZE, as H/W scroll is used.
	; Display window start/stop. x=129, y=44, w=320, h=256+1

	move.w	#GAME_XOFF+BLOCK_SIZE+(GAME_YOFF<<8),DIWSTRT+CUSTOM	; set display window start
	move.w	D1,DIWSTOP+CUSTOM				; set display window stop
  	
	; *** Amiga reference says: "move.w	#(((GAME_XOFF)/2)-8.5),d0"  *** 
	move.w	#(GAME_XOFF-17)/2,d0 ; hope this works!
	move.w	d0,ddfstrt+custom
	add.w		#(8*((BLOCKS_X*BLOCK_SIZE)/16))-1,d0				
	move.w	d0,ddfstop+custom
	;-------------------------------------------------------------------------------

;;;;	move.w		#SCREENHEIGHT+GAME_YOFF-1,d0
;;;;	bsr			DoPanel
	COPPER_SET	GameCopperlist
	

	rts

;---------------------------------------------------------

Set_Menu_Screen:

;;;ADD MACRO SET_SCREEN & pass in params

	move.w	#0,BPLCON3+custom			; NO AGA SPRITES

	SET_SCREEN_POINTER	MenuBplanes,LogicScreenBuffer,(512)/8,BITPLANES
	SET_SPR16H_16COL 		PointerBuffer,Mspr0,Mspr1
	SET_SPRITE_PALETTE 	GamePalette
	SET_PALETTE 	  	 	GamePalette,MenuCol_CopperList,1<<BITPLANES 	;SCREENCOLOURS
	
	move.w	#(GAME_YOFF<<8)+MENU_XOFF,DIWSTRT+CUSTOM
	move.w	#(((GAME_YOFF+256)&$ff)<<8)+((MENU_XOFF+MENU_XSIZE)&$ff),diwstop+CUSTOM
	move.w	#((MENU_XOFF/2)-8)&$fff8,d0
	move.w	d0,ddfstrt+custom
	add.w		#8*((MENU_XSIZE/16)-1),d0
	move.w	d0,ddfstop+custom
	
	Copper_Set	MenuCopperlist
	
	ENABLE_LEVEL3_INTERRUPT	Lev3CopperInterruptMenu

	rts

;-------------------------------------------

MakeMaplookup:

	lea	MapLookUp,a0
	move.w	#EXTRA_BLOCKS_START-1,d0
	move.l	IconBuffer,d1
loop1:	move.l	d1,(a0)+
	add.l	#SIZE_WORD*BITPLANES*BLOCK_SIZE,d1
	dbra	d0,loop1
	
	move.w	#MAX_BLOCKS-EXTRA_BLOCKS_START-1,d0
	move.l	ReDrawIconsBuffer,d1
loop2:	move.l	d1,(a0)+
	add.l	#SIZE_WORD*BITPLANES*BLOCK_SIZE,d1
	dbra	d0,loop2

	RTS

;-------------------------------------------

DrawSmallPanelMap:

	;------------------------------------
	; DRAW SCALED MAP IN PANEL SCREEN
	
	move.l	MapDataBuffer,a4
	move.w	MAPHEADER_WIDTH(a4),d7;  *** GET MAP WIDTH ***
	move.w	MAPHEADER_HEIGHT(a4),d6; *** GET MAP HEIGHT ***
	lea	MAPHEADER_DATA(a4),a4	;+24 skip header
	move.l	HitDataBuffer,a1
	move.l	PanelBuffer,a2

;;	add.l	#128*128*2,a4
	moveq.l	#0,d0
	move.w	d7,d0
	mulu	d6,d0
	lsl.l	#1,d0
	add.l	d0,a4

	subq	#1,d7
	subq	#1,d6

loop_Y1:
	move.w	d7,d5
	move.w	#SOMETHINGVERYHARD,(a4)		;create hard edge around map
	move.w	#SOMETHINGVERYHARD,127*2(a4)
loop_X1:
	cmp.w d7,d6
	beq.s	.doit
	tst.w d6
	bne.s .skip
.doit
	move.w	#SOMETHINGVERYHARD,(a4)
.skip

	move.w	d5,d0
	add.w	#SCREENWIDTH/2+BLOCK_SIZE-(128/2),d0
	move.w	d6,d1

	move.w	-(a4),d4
	move.b	(a1,d4),d4
;;	cmp.b	#TERRAIN_CORNER,d4
;;	bne.s	.skipcol
	move.b	d4,d2
	and.b	#%11,d2

	bsr PanelPlot_2p ; trashes a0,d2,d3

;;.skipcol
	dbra	d5,loop_X1
	dbra	d6,loop_Y1

	rts

;-----------------------------------------------------
; This fixes the problem of the first skid mark
; trashing the first cell of the map when it restores a block.

InitBlocksRestoreList:

	move.l	MapDataBuffer,a0
	lea	MAPHEADER_DATA(a0),a0	;+24 skip header
	move.w	(a0),d1 ;first icon
	lea	BlocksRestoreList,a2
	move.w	#(MAX_BLOCKS-EXTRA_BLOCKS_START)-1,d0
.loop
	move.w	#0,(a2)+ ;offset
	move.w	#SOMETHINGVERYHARD,(a2)+		 ;set all to first icon
	dbra	d0,.loop ;until -1

	RTS

;----------------------------

InitStoreOldBlocks:
	move.w	#(32*32)-1,d0

	lea	StoreOldBlocks1,a0
	lea	StoreOldBlocks2,a1

	moveq.w	#-1,d1
.loop
	move.w	d1,(a0)+
	move.w	d1,(a1)+
	dbra	d0,.loop

	RTS

;----------------------------

PlaceCars:

;;	SET_CAR	#0,#(10*16)<<16,#(10*16)<<16,#CAR_PLR1
;;	SET_CAR	#1,#(16*16)<<16,#(11*16)<<16,#CAR_CPU
;;	SET_CAR	#2,#(22*16)<<16,#(12*16)<<16,#CAR_CPU
;;	SET_CAR	#3,#(33*16)<<16,#(13*16)<<16,#CAR_CPU
;;	rts
	
	move.l	MapDataBuffer,a0
	move.w	MAPHEADER_WIDTH(a0),d6	; *** GET MAP WIDTH ***
	move.w	MAPHEADER_HEIGHT(a0),d1	; *** GET MAP HEIGHT ***
	lea	MAPHEADER_DATA(a0),a0	;+24 skip header
	subq	#1,d1
	subq	#1,d6
	moveq.l	#0,d4
	moveq.l	#MAX_CARS-1,d5
loopy
	move.l	d6,d0
loopx
	;----------------------------------------
	; *** PLACES CARS ***

	move.w	d6,d2
	addq	#1,d2
	sub.w	d0,d2
	lsl.w	#4,d2	;*BLOCKSIZE
	ext.l	d2
	swap	d2	;<<16

	move.w	d6,d3
	addq	#1,d3
	sub.w	d1,d3
	lsl.w	#4,d3
	ext.l	d3
	swap 	d3

	cmp.w	#ICON_PLACE_CAR_PLR,(a0)	;block/icon number only used to mark car starting point
					;looks like normal bit of road.
					;...changed now have to replace block with blank road
					;makes map design easer.	
	bne	SkipPlr1
	; car number,x,y,player type	;0,1....
	move.w	ICON_BLANK_ROAD,(a0)	; replace design helping icon with road
	SET_CAR	d4,d2,d3,#CAR_PLR1	;Place Player cars
	addq.l 	#1,d4			;first in the list...
skipPlr1:
	cmp.w	#ICON_PLACE_CAR_CPU,(a0)
	bne	skipCpuCars		;3,2...
	move.w	ICON_BLANK_ROAD,(a0)
	SET_CAR	d5,d2,d3,#CAR_CPU	;Place Cpu Cars Last
	subq.l 	#1,d5			;in the list....
skipCpuCars:

	addq	#2,a0
	dbra	d0,loopx
	dbra	d1,loopy

	rts

;---------------------------------------------------

PlaceCarOnMap
	movem.l	a3/d6-7,-(sp)
	
	;IN:	Param1 ; car no#
	;	Param2 ; car xpos
	;	Param3 ; car ypos
	;	Param4 ; car type plr/cpu
	

	lea	CarList,a3	;car structure
	
	;-----------------------------------------
	;this part issues a sound channel for each car.
	moveq.l	#0,d7
	move.w	Param1,d7
	move.w	#%0001,d6
	lsl.w	d7,d6
	move.w	d6,CAR_SNDCHANBIT(a3)	; Each car uses its own sound channel	
	;-----------------------------------------
	
	mulu	#CAR_SIZEOF,d7	; CarNum * Structure size
	add.l	d7,a3		; index into correct car data

	move.w	Param1,CAR_NUMBER(a3)
	move.l	Param2,CAR_XPOS(a3)	
	move.l	Param3,CAR_YPOS(a3)
	move.w	Param4,CAR_TYPE(a3)	

	move.l	#0,CAR_FRAME(a3)
	move.l	#0,CAR_SPEED(a3)
	move.l	#0,CAR_VELX(a3)
	move.l	#0,CAR_VELY(a3)

	move.l	#0,CAR_ROAD_GRIP(a3)
	move.l	#0,CAR_TURN_SKID(a3)
	
	movem.l	(sp)+,a3/d6-7
	
	RTS

;-----------------------------------------------------

SetUpSceneAnimations:

	move.l	AnimBuffer,a0
	
	move.w	#MAX_BLOCKS-1,d0
.Zeroloop:
	move.b	#0,(a0)+
	dbra	d0,.ZeroLoop
	
	
	move.l	AnimBuffer,a0
	
	move.b	  #0,(740)+0(a0) ;
	move.b	  #1,(740)+1(a0) ;Spin Cone
	move.b	  #1,(740)+2(a0) ;
	move.b	  #1,(740)+3(a0) ;
	move.b	  #1,(740)+4(a0) ;
	move.b	  #1,(740)+5(a0) ;
	move.b	  #1,(740)+6(a0) ;
	move.b	  #1,(740)+7(a0) ;
	move.b	  #1,(740)+8(a0) ;
	move.b	  #1,(740)+9(a0) ;
	move.b	  #-10,(740)+10(a0) ; stop anim 
	
	
	move.b	  #0,(720)+0(a0) ;
	move.b	  #1,(720)+1(a0) ;flash street light
	move.b	  #1,(720)+2(a0) ;
	move.b	  #1,(720)+3(a0) ;
	move.b	  #1,(720)+4(a0) ;
	move.b	  #1,(720)+5(a0) ;
	move.b	  #1,(720)+6(a0) ;
	move.b	  #-6,(720)+7(a0) ; keep anim going
	
	
	
	move.b	   #1,(808)+0(a0) ;
	move.b	   #1,(808)+1(a0) ;Arrow ->
	move.b	   #1,(808)+2(a0) ;
	move.b	   #1,(808)+3(a0) ;
	move.b	   #1,(808)+4(a0) ;
	move.b	  #-5,(808)+5(a0) ;

	move.b	   #1,(828)+0(a0) ;
	move.b	   #1,(828)+1(a0) ;Arrow <-
	move.b	   #1,(828)+2(a0) ;
	move.b	   #1,(828)+3(a0) ;
	move.b	   #1,(828)+4(a0) ;
	move.b	  #-5,(828)+5(a0) ;

	move.b	   #1,(848)+0(a0) ;
	move.b	   #1,(848)+1(a0) ;Arrow 
	move.b	   #1,(848)+2(a0) ;
	move.b	   #1,(848)+3(a0) ;
	move.b	   #1,(848)+4(a0) ;
	move.b	  #-5,(848)+5(a0) ;	
	
	move.b	   #1,(868)+0(a0) ;
	move.b	   #1,(868)+1(a0) ;Arrow 
	move.b	   #1,(868)+2(a0) ;
	move.b	   #1,(868)+3(a0) ;
	move.b	   #1,(868)+4(a0) ;
	move.b	  #-5,(868)+5(a0) ;

	
	move.b	    #1,(794-20)+0(a0) ;fire
	move.b	    #1,(794-20)+1(a0) ;
	move.b	   #-2,(794-20)+2(a0) ;
	move.b	    #1,(794)+0(a0) ;fire
	move.b	    #1,(794)+1(a0) ;
	move.b	   #-2,(794)+2(a0) ;


	move.b	    #1,(790-20)+0(a0) ;smoke
	move.b	    #1,(790-20)+1(a0) ;
	move.b	   #-2,(790-20)+2(a0) ;
	move.b	    #1,(790)+0(a0) ;smoke
	move.b	    #1,(790)+1(a0) ;
	move.b	   #-2,(790)+2(a0) ;
	
	move.b	    #2,(760)+0(a0) ;water
	move.b	    #2,(760)+2(a0) ;
	move.b	    #2,(760)+4(a0) ;
	move.b	    #2,(760)+6(a0) ;
	move.b	   #-2*4,(760)+8(a0) ;
	move.b	    #2,(761)+0(a0) ;water
	move.b	    #2,(761)+2(a0) ;
	move.b	    #2,(761)+4(a0) ;
	move.b	    #2,(761)+6(a0) ;
	move.b	   #-2*4,(761)+8(a0) ;
	move.b	    #2,(780)+0(a0) ;water
	move.b	    #2,(780)+2(a0) ;
	move.b	    #2,(780)+4(a0) ;
	move.b	    #2,(780)+6(a0) ;
	move.b	   #-2*4,(780)+8(a0) ;
	move.b	    #2,(781)+0(a0) ;water
	move.b	    #2,(781)+2(a0) ;
	move.b	    #2,(781)+4(a0) ;
	move.b	    #2,(781)+6(a0) ;
	move.b	   #-2*4,(781)+8(a0) ;

	
	
	move.b   #TANK,(980)+0(a0) ;	SPECIAL LOCK ON 
	move.b   #TANK,(980)+2(a0) ;
	move.b   #TANK,(980)+4(a0) ;
	move.b   #TANK,(980)+6(a0) ;
	move.b   #TANK,(980)+8(a0) ;
	move.b   #TANK,(980)+10(a0) ;
	move.b   #TANK,(980)+12(a0) ;
	move.b   #TANK,(980)+14(a0) ;
	move.b   #TANK,(980)+16(a0) ;
	move.b   #TANK,(980)+18(a0) ;
	
	move.b   #TANK,(980)+20(a0) ;
	move.b   #TANK,(980)+22(a0) ;
	move.b   #TANK,(980)+24(a0) ;
	move.b   #TANK,(980)+26(a0) ;
	move.b   #TANK,(980)+28(a0) ;
	move.b   #TANK,(980)+30(a0) ;
	move.b   #TANK,(980)+32(a0) ;
	move.b   #TANK,(980)+34(a0) ;	
	

	move.b   #GUN_TURRET,(1060)+0(a0) ;  lock on
	move.b   #GUN_TURRET,(1060)+2(a0) ;
	move.b   #GUN_TURRET,(1060)+4(a0) ;
	move.b   #GUN_TURRET,(1060)+6(a0) ;
	move.b   #GUN_TURRET,(1060)+8(a0) ;
	move.b   #GUN_TURRET,(1060)+10(a0) ;
	move.b   #GUN_TURRET,(1060)+12(a0) ;
	move.b   #GUN_TURRET,(1060)+14(a0) ;
	move.b   #GUN_TURRET,(1060)+16(a0) ;
	move.b   #GUN_TURRET,(1060)+18(a0) ;
	
	move.b   #GUN_TURRET,(1060)+20(a0) ;
	move.b   #GUN_TURRET,(1060)+22(a0) ;
	move.b   #GUN_TURRET,(1060)+24(a0) ;
	move.b   #GUN_TURRET,(1060)+26(a0) ;
	move.b   #GUN_TURRET,(1060)+28(a0) ;
	move.b   #GUN_TURRET,(1060)+30(a0) ;
	move.b   #GUN_TURRET,(1060)+32(a0) ;
	move.b   #GUN_TURRET,(1060)+34(a0) ;	
	

	move.w	#MAX_BLOCKS-1,d0
.Addloop:
	add.b	#FAKE_ANIM_ZERO,(a0)+
	dbra	d0,.AddLoop
	
	RTS
;--------------------------------------------

