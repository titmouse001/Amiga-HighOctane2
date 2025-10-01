;;		rsreset
;;;simple copy block blit
;;BLIT_ENABLE	rs.b	1
;;BLIT_DEST	rs.l	1
;;BLIT_SOURCE	rs.l	1
;;BLIT_SIZE	rs.w	1
;;BLIT_SIZEOF	rs.b	0
;;		rsreset


		rsreset
;sound channles
SFX_PTR		rs.l	1
SFX_LEN		rs.w	1
SFX_PER		rs.w	1
SFX_VOL		rs.w	1
;;;;;;;;;SFX_LOCK	rs.l	1	;Interrupt time based, nothing can play over it.
SFX_STATUS	rs.w	1
SFX_SIZEOF	rs.b	0

;************************
;***     KeyBoard     ***
;************************
		rsreset
kb.qualifiers:	rs.b	1
kb.keytmp:	rs.b	1
kb.lastkeytmp:	rs.b	1
kb.keydelaytmp:	rs.b	1
kb.repspeedtmp:	rs.b	1
kb.key:		rs.b	1
kb.reserved:	rs.w	1
kb.sizeof	rs.b	0
		rsreset

;***************************
;*** Rocket Structure ***
;***************************

			rsreset
ROCKET_X		rs.l	1  ;\ keep these 2
ROCKET_Y		rs.l	1  ;/ in this order!!!
ROCKET_FRAME		rs.l	1
ROCKET_SPEED		rs.l	1

ROCKET_FIREDBY		rs.w	1
ROCKET_ENABLE		rs.b	1
ROCKET_pad		rs.b	1

ROCKET_SIZEOF		rs.b	0


;***************************
;*** Explosion Structure ***
;***************************

			rsreset
EXP_X			rs.w	1  ;\ keep these 2
EXP_Y			rs.w	1  ;/ in this order!!!
EXP_FRAME		rs.w	1
;;;;EXP_TYPE		rs.l	1
EXP_ENDFRAME		rs.w	1
EXP_ENABLE		rs.b	1
EXP_PAD			rs.b	1
EXP_SIZEOF		rs.b	0


;*************************
;*** Cpu Car Structure ***
;*************************

			rsreset
CAR_SCENE_ADR		rs.l	1
CAR_XPOS		rs.l	1
CAR_YPOS		rs.l	1
CAR_LASTXPOS		rs.l	1
CAR_LASTYPOS		rs.l	1
CAR_VELX		rs.l	1
CAR_VELY		rs.l	1
CAR_SPEED		rs.l	1
CAR_FRAME		rs.l	1
RELOADING_ROCKET	rs.l	1
CAR_TURN_AMOUNT		rs.l	1
CAR_TURN_SKID		rs.l	1
CAR_ROAD_GRIP		rs.l	1
CAR_TREDMARKS		rs.l	1  ;bit pattern LSR per frame for on/off marks
CAR_SNDCHANBIT		rs.w	1  ;NEVER CHANGE THIS AFTER INIT
CAR_PLAY_SND_NUM	rs.w	1  ;see "EQU_SFX.i"
CAR_PLAY_SND_LASTNUM	rs.w	1
CAR_TYPE		rs.w	1
CAR_NUMBER		rs.w	1
CAR_JOY_DIR		rs.w	1
CAR_WOBBLE_COUNT	rs.w	1



CAR_SIZEOF		rs.b	0

;*************************
;*** Blast Pixel Struc ***
;*************************

			rsreset
PIXEL_X			rs.l	1  ;\ keep these 2
PIXEL_Y			rs.l	1  ;/ in this order!!!
PIXEL_MX		rs.w	1
PIXEL_MY		rs.w	1
PIXEL_TIMER		rs.w	1
PIXEL_COL		rs.b	1
PIXEL_pad		rs.b	1
BLAST_SIZEOF		rs.b	0

;************************
;*** Zone List Struct ***
;************************

			rsreset
ZONE_X			rs.w	1
ZONE_Y			rs.w	1
ZONE_WIDTH		rs.w	1
ZONE_HEIGHT		rs.w	1
ZONE_FUNC		rs.l	1
ZONE_ENABLE		rs.b	1
ZONE_pad		rs.b	1
ZONE_SIZEOF		rs.b	0

;*************************
;*** memory alloc list ***
;*************************

		rsreset
MEM_LOCATION	rs.l	1
MEM_LENGTH	rs.l	1
MEM_TYPE	rs.l	1  ;BITDEF: "MEMORY.I"
MEM_ENABLE	rs.w	1
MEM_SIZEOF	rs.b	0


;;; *** USEFULL NOTES ***

;//MEMF_ANY	EQU 0		;Any type of memory will do
;//    BITDEF  MEM,PUBLIC,0
;//    BITDEF  MEM,CHIP,1
;//    BITDEF  MEM,FAST,2
;//    BITDEF  MEM,LOCAL,8	;Memory that does not go away at RESET
;//    BITDEF  MEM,24BITDMA,9	;DMAable memory within 24 bits of address
;//    BITDEF  MEM,KICK,10	;Memory that can be used for KickTag stuff
;//
;//    BITDEF  MEM,CLEAR,16	;AllocMem: NULL out area before return
;//    BITDEF  MEM,LARGEST,17	;AvailMem: return the largest chunk size
;//    BITDEF  MEM,REVERSE,18	;AllocMem: allocate from the top down
;//    BITDEF  MEM,TOTAL,19	;AvailMem: return total size of memory
;//
;//    BITDEF  MEM,NO_EXPUNGE,31	;AllocMem: Do not cause expunge on failure




