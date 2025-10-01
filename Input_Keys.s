ScanKeys:

	bsr 		ReadKeys	;returns d0
	ext.w		d0
	beq		Nokeys
	
	cmp.w		#KEY_DEL,d0	
	bne.s		Not_del_key
	
	move.w	LastKeyPressed,d1
	cmp.w		d0,d1
	beq		.skip
	move.w	d0,LastKeyPressed
	sub.w		#BLOCK_SIZE,ScreenBlocksHeight
	bsr		DoPanel
.skip
	RTS

Not_del_key:

	cmp.w		#KEY_HELP,d0	
	bne.s		Not_help_key
	
	move.w	LastKeyPressed,d1
	cmp.w		d0,d1
	beq		.skip
	move.w	d0,LastKeyPressed
	add.w		#BLOCK_SIZE,ScreenBlocksHeight
	bsr		DoPanel
.skip
	RTS

Not_help_Key:
	cmp.w		#KEY_1,d0	
	bne		Not_key1
	
	move.l	#CarList+CAR_SIZEOF*0,CameraTarget
	move.l	#50*1<<16,CameraTimer

	RTS
	
Not_key1:
	cmp.w	#KEY_2,d0
	bne	.key2
	move.l	#CarList+CAR_SIZEOF*1,CameraTarget
	move.l	#50*1<<16,CameraTimer
	;;;;;PLAY_SAMPLE #SAM_BOOST,#%10,#310

	RTS
.key2:	
	cmp.w	#KEY_3,d0
	bne	.key3
	move.l	#CarList+CAR_SIZEOF*2,CameraTarget
	move.l	InterruptTimer,CameraTimer
	add.l	#50*2,CameraTimer
	;;;;;;;PLAY_SAMPLE #SAM_BOOST,#%100,#310
	RTS

.key3:	
	cmp.w	#KEY_4,d0
	bne	.key4
	move.l	#CarList+CAR_SIZEOF*3,CameraTarget
	move.l	InterruptTimer,CameraTimer
	add.l	#50*2,CameraTimer
	;;;;;;PLAY_SAMPLE #SAM_BOOST,#%1000,#310
	RTS

.key4:	
	cmp.w	#KEY_ESC,d0
	bne	.key5
	move.w	#-1,QuitCurrentScreen
	RTS
	
.key5:	
	cmp.w	#KEY_0,d0
	bne	.key6
	bsr	ClearGameScreen  	;both buffers
	;;;bsr	InitStoreOldBlocks
	RTS
.key6:



NoKeys:
	move.w	0,LastKeyPressed
	RTS
	
;--------------------------------------------------------

DoPanel:
	move.w	ScreenBlocksHeight,d0		
	
	cmp.w	#BLOCK_SIZE,d0
	bge.s	.InsideScreen1
	move.w	#BLOCK_SIZE,d0			;limit panel movement
.InsideScreen1

	cmp.w	#SCREENHEIGHT,d0
	ble.s	.InsideScreen2
	move.w	#SCREENHEIGHT,d0		;limit panel movement
.InsideScreen2

	move.w	d0,ScreenBlocksHeight
	
	bsr	MovePanel

	RTS

;--------------------------------------------------------


; *** KeyBoard ***
		
GetKeycodes	lea	Qualifier_Table(pc),a0
		moveq	#7,d7
		moveq	#0,d2
		move.b	(a1),d3			;kb.Qualifiers(a1),d3
check_qual1	move.b	(a0)+,d1
		cmp.b	d0,d1
		bne.s	checkqual2
		bset	d2,d3
		move.b	d3,(a1)			;kb.Qualifiers(a1)
		rts
checkqual2	add.w	#$80,d1
		cmp.b	d0,d1
		bne.s	checkqual4
		bclr	d2,d3
checkqual3	move.b	d3,(a1)			;kb.Qualifiers(a1)
		rts
checkqual4	addq.b	#1,d2
		dbra	d7,check_qual1
		tst.b	d0
		bpl.s	KeyOk
		move.b	d0,d1
		sub.b	#$80,d1
		cmp.b	kb.KeyTMP(a1),d1
		beq.s	KeyOk
		rts
KeyOk		move.b	d0,kb.KeyTMP(a1)
		rts


		cnop	0,4
ReadKeys:
		lea	kb_temp(pc),a1
		moveq	#0,d0
		move.b	kb.KeyTMP(a1),d0
		cmp.b	kb.LastKeyTMP(a1),d0
		beq.s	Repeat
		move.b	d0,kb.LastKeyTMP(a1)
		sf.b	kb.KeyDelayTMP(a1)
		bra.s	DoKey3
Repeat		tst.b	kb.KeyDelayTMP(a1)
		beq.s	DoKey
		subq.b	#1,kb.KeyDelayTMP(a1)
		bra.s	No_Key
DoKey		tst.b	kb.RepSpeedTMP(a1)
		beq.s	DoKey2
		subq.b	#1,kb.RepSpeedTMP(a1)
		bra.s	No_Key
DoKey2		sf.b	kb.RepSpeedTMP(a1)
DoKey3		tst.b	d0
		bpl.s	DoKey4
No_Key		st.b	d0
DoKey4		move.b	d0,kb.KEY(a1)		* d0.b = keycode..
		move.b	(a1),d1			;kb.Qualifiers(a1),d1	* d1.b = qualifiers..
		rts