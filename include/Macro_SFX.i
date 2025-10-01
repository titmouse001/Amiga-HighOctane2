;	***************
;	*** SAMPLES ***
;	***************

;-----------------------------------------

MAKE_SAMPLE_LIST:		MACRO

	move.l	\1,d1		;Sample Addr
	lea	\2,a0		
	moveq	#TOTAL_SAMPLES-1,d0
\@loop	add.l	d1,(a0)		;sizeof sam
	add.l	#8,a0		;long index into table
	dbra	d0,\@loop
	
	ENDM

;===============================================================

;	*************
;	*** MUSIC ***
;	*************

LOAD_MUSIC_SLOT	MACRO

	READFILE_ALLOC #DISK_\1,Param2,#MODE_OLDFILE,#MEMF_CHIP

	lea	MusicList,a0
	lea	\1*4(a0),a0
	move.l	Param2,(a0)
	
	ENDM

;-----

PLAY_MUSIC	MACRO

;;;;;;;;;	tst.w	Music_Playing
;;;;;;;;;	Bne.s	\@skip1

	lea	MusicList,a0		;list of tunes
	lea	\1*4(a0),a0		;find tune
	move.l	(a0),ModuleBuffer	;play buffer
	
	jsr	mt_init

;;;\@skip1
	ENDM