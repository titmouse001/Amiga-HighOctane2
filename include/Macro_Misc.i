 ;-----------------------------------------
CALL		MACRO
		jsr	_LVO\1(a6)
		ENDM
;-----------------------------------------
CALLSYS		MACRO
		LINKLIB	_LVO\1,\2
		ENDM

;-----------------------------------------

RELEASE_MOUSE	MACRO
again\@		btst	#6,$bfe001
		beq.s	again\@
		ENDM
;------------------------------------------

;USEAGE :- Mouse_button	"label"
MOUSE_BUTTON	MACRO
		btst	#6,$bfe001
		bne	\1
		ENDM
;-----------------------------------------------------------
