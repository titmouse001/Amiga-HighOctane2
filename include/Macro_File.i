;---------------------------------------------------
; INPUT: Name,Buff,Mode,MemType
READFILE_ALLOC	MACRO

	move.l	\1,FileName_Ptr
	move.l	\3,FileMode
	move.l	\4,MemType
	jsr	ReadFileRoutine; Errors trapped inside
	bsr	UnPackData
	
	PRINTDOS	MSG_LF,stdout
	
	move.l	location_ptr,\2	;save addr
	ENDM
;-----------------------------------------------
; INPUT: Name,Buff,Mode,MemType
READFILE_ALLOC_LEAVEPACKED	MACRO
	move.l	\1,FileName_Ptr
	move.l	\3,FileMode
	move.l	\4,MemType
	move.l	#0,location_ptr
	jsr	ReadFileRoutine; 
		
	tst.l	Location_ptr
	beq.s	\@skip
	PRINTDOS	MSG_LEAVECRUNCHED,stdout
\@skip
	PRINTDOS	MSG_LF,stdout
	
	move.l	location_ptr,\2	;save addr
	ENDM
;-----------------------------------------------
; INPUT: Name,Buff,Mode,MemType
READFILE_NoALLOC_LEAVEPACKED	MACRO

	move.l	\1,FileName_Ptr
	move.l	\2,location_ptr	
	move.l	\3,FileMode
	;;;;;;;;move.l	\4,MemType
	jsr	ReadFileRoutineNoAlloc; 
	ENDM
;-----------------------------------------------