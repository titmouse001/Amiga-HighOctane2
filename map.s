
LoadAllMaps:
	moveq	#MAX_LOADEED_MAPS-1,d0
MapLoop:MOVE.L	D0,-(SP)
	move.l	d0,d7
	lsl.l	#2,d7
	bsr	LoadMap
	MOVE.L	(SP)+,D0
	dbra	d0,MapLoop
	RTS

;----------------------------------------------
	
LoadMap:
	;A simple sprinf, "filename%02ld.map"
	move.l	d7,d0
	lsr.l	#2,d0
	move.l	d0,PrintfVar1
	lea	MSG_MAPXX,a0
	lea	PrintfVar1,a1
	lea	PrintF_Process,a2
	lea	FileName_Buffer,a3
	move.l	$4.w,a6
	CALL	RawDoFmt	
	;----------------------------
	; ANY FAST RAM
	
	move.l	#FileName_Buffer,FileName_Ptr
	move.l	#MODE_OLDFILE,FileMode
	move.l	#MEMF_FAST,MemType

	READFILE_ALLOC_LEAVEPACKED   #FileName_Buffer,Param2,#MODE_OLDFILE,#MEMF_FAST|MEMF_CLEAR

	lea 	MapDataBufferList,a0
	move.l	Param2,(a0,d7)
	;-----------------------------
;;;;;	PRINTDOS	MSG_LF,stdout
	
	RTS
	
;---------------------------------------------------
Format_Map:
	move.l	MapDataBuffer,a0
	move.l	ArrowDataBuffer,a1

	move.w	MAPHEADER_WIDTH(a0),d3 	; *** GET MAP WIDTH ***
	move.w	MAPHEADER_HEIGHT(a0),d1 ; *** GET MAP HEIGHT ***
	lea	MAPHEADER_DATA(a0),a0	; +24 skip header
	subq	#1,d1
	subq	#1,d3
.loop_y
	move.w	d3,d0
.loop_x
	;----------------------------------------
	; CORRECT ARROW DATA
	move.b	(a1),d2
	sub.b	#1,d2
	cmp.b	#71,d2
	bne.s	.path_ok
	moveq	#0,d2		;make it valid
.Path_Ok
	move.b	d2,(a1)+
	;----------------------------------------
	dbra	d0,.loop_x
	dbra	d1,.loop_y
	
	RTS
	
	
;----------------------------------------------------------------

SetCurrentMap:   ; IN d7=map number

	lsl.w		#2,d7	; index long
	lea 		MapDataBufferList,a0
	move.l		(a0,d7.w),a1
	cmp.l		#"S404",(a1)
	move.l		MapDataBuffer,a0	;***DEST***	
	
	bne.s		No_CrunchedHeader
	bsr		Decrunch	;a0 = destination address a1 = crunched data
	bra.s		UnPackDone

No_CrunchedHeader:	
	move.w	#MAPDATA_MAPSIZE+MAPDATA_HITSIZE+MAPDATA_ARWSIZE-1,d0 	;data size
	
CopyMapLoop:
	move.b	(a1)+,(a0)+ ;copy to spare 
	dbra	d0,CopyMapLoop
	
UnPackDone:
	;-------------------------------------	
	move.l	MapDataBuffer,HitDataBuffer
	add.l		#HIT_OFFSET,HitDataBuffer
	move.l	MapDataBuffer,ArrowDataBuffer
	add.l		#ARW_OFFSET,ArrowDataBuffer
	;-------------------------------------
	; VALID MAP?
	move.l	MapDataBuffer,a0
	cmp.l	#"AmBk",(a0)
	beq.s	skipmaperror
	nop
skipmaperror
	;-------------------------------------	
	bsr	Format_Map
	;-------------------------------------
	RTS