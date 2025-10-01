_InitMenus_withMusic_ASM:

	movem.l	d1-d7/a0-a6,-(sp)

	;;;;move.w	#0,map_x
	;;;;move.w	#0,map_y
	
	;;;;move.w	#0,QuitCurrentScreen	
	
	PLAY_MUSIC	MOD_TITLE

	;;;;bsr	ClearGameScreen  	;both buffers
	;-------------------------	
	moveq	#9,d7
	bsr	SetCurrentMap
		
	bsr	MakeMaplookup	

	bsr	InitStoreOldBlocks

;;	bsr 	BlitAnimateBlocks
;;;;	bsr	Menu_BlitBlocks
;;	SCREEN_SWAP
;;;;	bsr	Menu_BlitBlocks
;;	bsr 	BlitAnimateBlocks
	;--------------------------
	
	move.w	#MENU_WIDTH,ScreenBlocksWidth
	move.w	#MENU_HEIGHT,ScreenBlocksHeight
	
	;;	bsr	ClearGameScreen  	;both buffers

	bsr	Set_Menu_Screen
	SET_PALETTE 	   GamePalette,MenuCol_CopperList,1<<BITPLANES	;SCREENCOLOURS

;;;;	ENABLE_LEVEL3_INTERRUPT	Lev3CopperInterruptMenu
	
	movem.l	(sp)+,d1-d7/a0-a6
	rts


_ProcessMenuDisplay_ASM:
	movem.l	d1-d7/a0-a6,-(sp)


	move.w	map_x,d0
	and.w		#$fff0,d0
	MOVE.W	d0,Bob_Map_x
	move.w	map_y,d0
	and.w		#$fff0,d0
	MOVE.W	d0,Bob_Map_y

	move.l	StoreBlocksLoc1,a5
	move.l	LogicScreenBuffer,d6
	bsr 	BlitAnimateBlocks
	
	moveq.l		#0,d6	   
	move.l		d6,d7    ; no overrun in menu.
	bsr 	DisplayCars		;IN d6,d7
	
;;;	menutxt_val		#64,#64,InterruptTimer
	SET_SCREEN_POINTER	MenuBplanes,LogicScreenBuffer,(512)/8,BITPLANES
	WAITSCREEN

;;;;	SCREEN_SWAP
	
	bsr	HardWare_Scroll
	
	movem.l	(sp)+,d1-d7/a0-a6
		
	rts
		

;-------------------------------------------
_StartGame_ASM:
	;*** Game INITIALISE ***
	movem.l	d1-d7/a0-a6,-(sp)
	
	
	bsr	mt_END
;;;	WAITSCREEN
	move.w	#0,QuitCurrentScreen



	move.w	#BLOCKS_X*BLOCK_SIZE,ScreenBlocksWidth
	move.w	#SCREENHEIGHT,ScreenBlocksHeight

	;*move.w #(1<<5)|(1<<8),DMACON+CUSTOM	;OFF sprite/Bitplane

	bsr	ClearGameScreen  	;both buffers
	
	;------------------------
	moveq	#0,d7
	bsr	SetCurrentMap	; IN d7=MAP number
	;----------------------


	bsr	GameInit
	
	;;move.w	#%1000001111101111,DMACON+CUSTOM	;sprite/blitter/Copper/Bitplane

	bsr	MainGameLoop

	movem.l	(sp)+,d1-d7/a0-a6
	RTS
	;;;;bra	DoMenu_withMusic
	
;------------------------------------------------------------
