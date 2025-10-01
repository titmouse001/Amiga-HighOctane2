;---------------------------------------------------
ENABLE_LEVEL2_INTERRUPT		MACRO
	bsr	GetVBR
	move.l	d0,a4
	lea	OldLev2(pc),a0		     ; level2 save
	move.l	$68(a4),(a0)
	move.l  #\1,$68(a4) ; Lable Address
	move.w	#$8000+$4008,INTENA+CUSTOM   ; Enable CIA-A interrupt
	ENDM
;---------------------------------------------------
ENABLE_LEVEL3_INTERRUPT		MACRO
	bsr	GetVBR
	move.l	d0,a0
	move.l  #\1,$6c(a0) ; Lable Address
	move.w	#$8000+$4010,INTENA+CUSTOM   ; Enable Copper interrupt
	ENDM
;---------------------------------------------------
ENABLE_LEVEL4_INTERRUPT		MACRO
	bsr	GetVBR
	move.l	d0,a0
	move.l  #\1,$70(a0) ; Lable Address
	move.w	#$8000+$4780,INTENA+CUSTOM   ; Enable Audio interrupt
	ENDM
;---------------------------------------------------