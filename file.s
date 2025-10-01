GetFileSize:
	MOVEM.L	D1-7/a0-6,-(SP)
	
	move.l	dosbase,a6 ; for CALL's
	move.l	FileName_Ptr,d1
	move.l	FileMode,d2
	
	CALL	Lock
	
	tst.l	d0
	beq	LoadError			
	
	move.l	d0,LockFile
	move.l	d0,d1
	lea	FileInfo_Struct,a4
	move.l	a4,d2
	CALL	Examine

	move.l	fib_Size(a4),FileSize
	
	move.l	LockFile,d1
	CALL	Unlock
	MOVEM.L	(SP)+,D1-7/a0-6
	
	move.l	FileSize,d0
	rts

LoadError:
	move.l	d0,d1	;    LockFile,d1
	CALL	Unlock
	PRINT_F	MSG_LOADERROR,FileName_ptr
	MOVEM.L	(SP)+,D1-7/a0-6
	
	moveq	#0,d0
	rts

;--------------------------------------------------------------------
ReadFile:
	MOVEM.L	D0-7/a0-6,-(SP)
	
	move.l	dosbase,a6  ; For later CALL's
	
	move.l	FileName_ptr,d1
	move.l	FileMode,d2
	CALL	Open	; d0=open(d1,d2) / fh=open(name,accessmode)
	move.l	d0,FileHandle

	move.l	d0,d1
	Move.l	Location_ptr,d2
	move.l	FileSize,d3	; d0=read(d1,d2,d3) / actuallength=read(fh,buffer,length)
	CALL	Read

	move.l	FileHandle,d1
	CALL	Close	; d0=close(d1) / success=close(fh)
	MOVEM.L	(SP)+,D0-7/a0-6
	rts
	
;-------------------------------------------------
ReadFileRoutineNoAlloc:
	bsr	GetFileSize

	tst.l	d0
	beq	ReadError1
	
	bsr	ReadFile

	PRINT_F	MSG_BYTES,FileSize
	PRINT_F	MSG_LOADINGNAME,FileName_ptr

ReadError1:
	rts
;----------------------------------------------------------------------
ReadFileRoutine:
	bsr	GetFileSize	
	tst.l	d0
	beq	ReadError2
	
	ADD_MEM	MemType,FileSize,Location_ptr
	bsr	ReadFile
	
	PRINT_F	MSG_BYTES,FileSize
	PRINT_F	MSG_LOADINGNAME,FileName_ptr
ReadError2:
	rts
