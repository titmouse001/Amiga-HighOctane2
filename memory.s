InitMem ; called once at startup, 
	; also used with FreeAllMemory used before program exit
	
	lea	MemoryList,a2
	move.w	#MAX_ALLOC_BLOCKS-1,d0
	
clearNextMemBlock:
	move.w	#0,MEM_ENABLE(a2)
	move.l	#0,MEM_TYPE(a2)   
	move.l	#0,MEM_LENGTH(a2)
	move.l	#0,MEM_LOCATION(a2)

	lea	MEM_SIZEOF(a2),a2
	dbra	d0,clearNextMemBlock
	
	rts
	
	
;------------------------------------------
;	***********************
;	*** AddToMemoryList ***
;	***********************
;	ENTRY:	Param1,Param2,Param3 = TYPE,LENGTH,LOCATION

AddToMemoryList:
	movem.l	d0-4/a0-6,-(sp)

	;----------------------------------
	;Library Call
	move.l	Param2,d0	;size
	move.l	Param1,d1	;type
	move.l	$4.w,a6
	CALL	AllocMem	d0=AllocMem(d0,d1), memblock=AllocMem(bytesize,attributes)
	move.l	d0,Param3	;return value from AllocMem
	;------------------------------------

	lea	MemoryList,a2
	move.w	#MAX_ALLOC_BLOCKS-1,d4
	
Next_Mem_block_Add
	tst.w	MEM_ENABLE(a2)
	bne	Mem_block_In_Use
	addq.w	#1,CountMemBlocksReserved

	cmp.w	#MAX_ALLOC_BLOCKS,CountMemBlocksReserved
	blt.s	MemblocksNotFull
	PRINTDOS	MSG_ALLOCERROR,stdout
	bra	mem_block_found ;error case
MemBlocksNotFull

	move.w	#1,MEM_ENABLE(a2)
	move.l	Param1,MEM_TYPE(a2)   
	move.l	Param2,MEM_LENGTH(a2)
	move.l	Param3,MEM_LOCATION(a2)
	
	Bra.s	Mem_Block_Found
Mem_Block_In_Use
	lea	MEM_SIZEOF(a2),a2
	dbra	d4,Next_Mem_Block_add
mem_Block_Found

	movem.l	(sp)+,d0-4/a0-6

	rts

CountMemBlocksReserved	dc.w	0

;-----------------------------------------------------

FreeMemoryItem
;	input: Param1 - memory loc

	movem.l	d0-7/a0-6,-(sp)

	move.l	Param1,d1	;loc ptr
	
	lea	MemoryList,a2
	move.w	#MAX_ALLOC_BLOCKS-1,d4

Next_Block
	tst.w	MEM_ENABLE(a2)
	beq	not_used
	
	move.l	MEM_LENGTH(a2),d0
	move.l	MEM_LOCATION(a2),a1
	
	;----------------------------
	;----------------------------
	;----------------------------
	IFNE 	MEMORY_DEBUG_ON
	jsr	DebugMemeryCheck
	ENDC
	;---------------------------
	;---------------------------
	;---------------------------
	
	cmp.l	d1,a1
	bne.s	not_used
	
	subq.w	#1,CountMemBlocksReserved	
	move.w	#0,MEM_ENABLE(a2)	
	
	move.l	$4.w,a6
	CALL	FreeMem			; FreeMem(A1,D0), FreeMem(memoryblock,bytesize)
	bra.s	BreakLoop
;;;;;;	movem.l	(sp)+,d0-7/a0-6
;;;;;;	rts

not_used:
	lea	MEM_SIZEOF(a2),a2
	dbra	d4,Next_block
BreakLoop:
	movem.l	(sp)+,d0-7/a0-6
	rts


;----------------------------------------------------
;	************************
;	*** Free All Memeory ***
;	***  which has used  ***
;	*** AddToMemoryList  ***
;	************************
	
FreeALLMemory:

	movem.l	d0-7/a0-6,-(sp)

	move.l	#0,TotalAllocChip
	move.l	#0,TotalAllocFast

	move.l	$4.w,a6
	lea	MemoryList,a2
	move.L	#MAX_ALLOC_BLOCKS-1,d4

	PRINTDOS	MSG_FREEINGMEM,stdout
	
Next_Mem_block:
	tst.w	MEM_ENABLE(a2)
	beq	mem_block_not_used
	FREEMEMITEM	MEM_LOCATION(a2)
	bsr	PrintMemItemDetails ; uses a2

mem_block_not_used
	lea	MEM_SIZEOF(a2),a2
	dbra	d4,Next_Mem_Block
	
	PRINTDOS	MSG_LF,stdout
	 
	;;move.l		TotalAllocChip,d5
	move.l		TotalAllocFast,d5
	divu		#1024,d5
	ext.l		d5
	move.l		d5,PrintfVar2 ; total bytes

	move.l		TotalAllocChip,d5	
	divu		#1024,d5
	ext.l		d5
	move.l		d5,PrintfVar1

	PRINT_F		MSG_TOTALALLOC,PrintfVar1
	
	movem.l	(sp)+,d0-7/a0-6
	
	rts


;---------------------------------------------------------

Display_Machine_Info

;;	PRINTDOS	MSG_SYSTEM_INFO,stdout
	
	lea		SystemSave,a4
	move.b		CPU(a4),d0
	ext.l		d0
	move.l		d0,PrintfVar1
	PRINT_F		MSG_CPU,PrintfVar1

	tst.b		ntsc_mode(a4)
	beq.s		.not_ntsc
	PRINTDOS	MSG_NTSC,stdout
	bra.s	.skip_pal
.not_ntsc
	PRINTDOS	MSG_PAL,stdout
.skip_pal

	tst.b		AGA(a4)
	beq.s		.not_aga
	PRINTDOS	MSG_AGA,stdout
	bra.s	.skip
.not_aga
	PRINTDOS	MSG_ESC_Standard,stdout
.skip

	PRINTDOS	MSG_LF,stdout
	move.l		$4.w,a6
	
	move.l		FastSize(a4),PrintfVar1
	moveq		#MEMF_FAST,d1
	CALL		AvailMem
	move.l		d0,PrintfVar2
	PRINT_F		MSG_FreeFastSize,PrintfVar1

	PRINTDOS	MSG_LF,stdout

	move.l		ChipSize(a4),PrintfVar1
	moveq		#MEMF_CHIP,d1
	CALL		AvailMem
	move.l		d0,PrintfVar2
	PRINT_F		MSG_FREECHIPSIZE,PrintfVar1
	PRINTDOS	MSG_LF,stdout

	move.l		#PROGMEM_CODE,PrintfVar1
	move.l		#PROGMEM_VARS,PrintfVar2
	move.l		#PROGMEM_CHIP,PrintfVar3
	PRINT_F		MSG_PROGRAMSPACE,PrintfVar1
	PRINTDOS	MSG_LF,stdout

	rts


;------------------------------------------------------------------




Machine_Type:

;*+*+*+	Set up constants...
	movea.l	4.w,a6			; exec base
	lea	$dff000,a5		; custom chip base
	lea	SystemSave,a4		; where to save everything

	move.l	#0,chipsize(a4)	
	move.l	#0,fastsize(a4)	

;*+*+*+	Check for memory...
	move.l	MEMLIST(a6),a0		;ExecBase,142hex=MemList
.check_node
	move.w	14(a0),d0		;mem type
	move.l	20(a0),d1		;lower address
	move.l	24(a0),d2		;upper address
	and.l	#$fffff000,d1		;mask off lower bits because
					;normally the first few bytes
					;of the memory are occupied
	sub.l	d1,d2                   ;get length of memory section
	and.w	#4,d0                   ;is the memory chip?
	beq.s	.chip_node          
	add.l	d2,fastsize(a4)		;add to fastmem size
	bra.s	.next_node          
.chip_node
	add.l   d2,chipsize(a4)		;add to chipmem size
.next_node
	move.l  0(a0),a0		;get next memory node
	tst.l   (a0)			;if the next node is zero
	bne.s	.check_node		;then its the end.

;*+*+*+	Check which CPU we've got under the hood...
	move	AttnFlags(a6),d0
                                        
	btst	#AFB_68040,d0       
	bne.s	.68040
	btst	#AFB_68030,d0       
	bne.s	.68030              
	btst	#AFB_68020,d0       
	bne.s	.68020              
	btst	#AFB_68010,d0       
	bne.s	.68010              
	bra.s	.CPU_Check_end		;Don't set flag, running a 68000
.68040
	move.b	#40,CPU(a4)
	bra.s	.CPU_Check_end
.68030
	move.b	#30,CPU(a4)
	bra.s	.CPU_Check_end
.68020
	move.b	#20,CPU(a4)
	bra.s	.CPU_Check_end
.68010
	move.b	#10,CPU(a4)
.CPU_Check_end


	movea.l	4.w,a6			; exec base

;*+*+*+	Check for PAL/NTSC modes...
	cmpi.b	#50,VBlankFrequency(a6)	; is vblank rate PAL ?
	beq.b	.pal			; yup.
	st	ntsc_mode(a4)		; set NTSC flag.
.pal

;*+*+*+	Check for AGA chipset...
	move.w	$7c(a5),d0		; AGA register...
	cmpi.b	#$f8,d0			; are we AGA?
	bne.b	.not_aga		; nope.
	st	AGA(a4)			; set the AGA flag.
.not_aga
	moveq	#0,d0			; return no error code

	rts

;-------------------------------------------------------------------

PrintMemItemDetails:

	movem.l	d0-1,-(sp)

	move.l	Mem_location(a2),a1
	movea.l	4.w,a6	
	CALL TypeOfMem

	move.l	MEM_LENGTH(a2),PrintfVar1
	move.l	d0,d1
	
	and.l	#MEMF_CHIP,d0
	bne	_Its_chip
	and.l	#MEMF_FAST,D1
	bne	_Its_Best
	
	bra	_Its_Error

_Its_chip:	PRINT_F	MSG_CHIP,PrintfVar1
		move.l	MEM_LENGTH(a2),d0
		add.l 	d0,TotalAllocChip
		Bra		_Done
_Its_error:	PRINT_F	MSG_ERROR,PrintfVar1
		Bra		_Done
_Its_Best:	PRINT_F	MSG_FAST,PrintfVar1
		move.l	MEM_LENGTH(a2),d0
		add.l	d0,TotalAllocFast
_Done:

	movem.l	(sp)+,d0-1
	rts
	
;----------------------------------------------------------------
	;***********************
	IFNE 	MEMORY_DEBUG_ON
	;***********************

DebugMemeryCheck:
	movem.l	d0-7/a0-6,-(sp)
	move.l	a1,a4
	move.l	a1,a5
	add.l	d0,a5
	sub.l	#2*1024,a5
		
	move.w	#((2*1024)/2)-1,d0
loopCheckmemtrashing:

	move.l	a4,PrintfVar1
	move.l	#0,PrintfVar2
	move.w	(a4),PrintfVar2
	cmp.w	#$0f,(a4)+
	beq.s 	skipmemtrashcehck1
	PRINT_F	MSG_TRASHINGMEM_LO,PrintfVar1,PrintfVar2
	PRINTDOS	MSG_LF,stdout
skipmemtrashcehck1:

	move.l	 a5,PrintfVar1
	move.l	#0,PrintfVar2
	move.w	(a5),PrintfVar2
	cmp.w	#$0f,(a5)+
	beq.s 	skipmemtrashcehck2
	PRINT_F	MSG_TRASHINGMEM_HI,PrintfVar1,PrintfVar2
	PRINTDOS	MSG_LF,stdout
skipmemtrashcehck2:

	dbra	d0,loopcheckmemtrashing
	movem.l	(sp)+,d0-7/a0-6
	
	RTS
	
	;******************************
	ENDC  ; END OF MEMORY_DEBUG_ON
	;******************************

;--------------------------------------------------------

QuickMemCopy:	; used for initialisation code maily, large setup cost.
		; (No fast for small amounts of data)

	movem.l	d0/a0-1,-(sp)
	move.l	a6,-(sp)
	
	move.l	Param1,a0
	move.l	Param2,a1
	move.l	Param3,d0
	
	move.l	$4.w,a6
	CALL	COPYMEMQUICK
	
	move.l	(sp)+,a6
	movem.l	(sp)+,d0/a0-1
	
	rts


