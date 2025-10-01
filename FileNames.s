; 	******************
; 	*** FILE NAMES ***
;	******************

MOD_PATH	MACRO
DISK_MOD_\1: 	dc.b	"data/mods/mod.HighOctane2.\1",0
		ENDM

GFX_PATH	MACRO
DISK_GFX_\1:	dc.b	"data/gfx/\1.gfx",0
		ENDM
	
		EVEN
			
			
			
; *** MAPS ***	;;;THIS WILL HAVE TO CHANGE!!!
;NEEDS TO LOAD USER MAPS, SCAN A WHOLE DIR FOR MAP FILES.
;KEEP IT EASY MAP01..99
DISK_Map01:		dc.b	"data/maps/rd01.map",0
DISK_Hit01:		dc.b	"data/maps/rd01.hit",0
DIsK_Arrow01:		dc.b	"data/maps/rd01.arw",0


;	*************
; 	*** MUSIC ***
;	*************

	MOD_PATH Title
	MOD_PATH Ingame1
	MOD_PATH Ingame2
	MOD_PATH Ingame3
	MOD_PATH Ingame4


; 	***********
; 	*** GFX ***
; 	***********

	GFX_PATH bigspr
	GFX_PATH mark
	GFX_PATH carfrms1
	GFX_PATH carfrms2
	GFX_PATH Rocket
	GFX_PATH blocks
	GFX_PATH font
	GFX_PATH panel
	GFX_PATH mouse
	GFX_PATH title
	GFX_PATH Menu
	GFX_PATH Exp
	GFX_PATH spr_car


;	***********
;	*** SFX ***
;	***********

Disk_Sample1:		dc.b  "data/sfx/samples.sam",0

	EVEN