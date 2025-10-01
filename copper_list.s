;*** Start of game copper list ***

	EVEN
GameCopperlist:

	; Dont forget -2 with horizotal scrolling
	dc.w BPL1MOD,((512/8)*(BITPLANES-1))+(((512-SCREENWIDTH-BLOCK_SIZE)/8)-2)  ;Set the modulos
	dc.w BPL2MOD,((512/8)*(BITPLANES-1))+(((512-SCREENWIDTH-BLOCK_SIZE)/8)-2)

	dc.w $00e0		;bitplane 1
Bplanes	dc.w $0000
	dc.w $00e2,0000
	dc.w $00e4,0000		;bitplane 2
	dc.w $00e6,0000
	dc.w $00e8,0000		;bitplane 3
	dc.w $00ea,0000
	dc.w $00ec,0000		;bitplane 4
	dc.w $00ee,0000

	dc.w $0102
CopList_HScrl:	dc.w $0000	;Horizontal scrolling

	dc.w $0104,%100100	;sprites

	dc.w $0180
Col_CopperList:
	dc.w $0000
	dc.w $0182,0000   ;<---good debug 182 to 180
	dc.w $0184,0000
	dc.w $0186,0000
	dc.w $0188,0000
	dc.w $018a,0000
	dc.w $018c,0000
	dc.w $018e,0000
	dc.w $0190,0000
	dc.w $0192,0000
	dc.w $0194,0000
	dc.w $0196,0000
	dc.w $0198,0000
	dc.w $019a,0000
	dc.w $019c,0000
	dc.w $019e,0000

	;--- sprite0 ---
	dc.w	$120
spr0_h: dc.w	$0
	dc.w	$122
spr0_l:	dc.w	$0
	;--- sprite1 ---
	dc.w	$124
spr1_h: dc.w	$0
	dc.w	$126
spr1_l:	dc.w	$0
	;--- sprite2 ---
	dc.w	$128
spr2_h: dc.w 	$0
	dc.w	$12A
spr2_l:	dc.w	$0
	;--- sprite3 ---
	dc.w	$12C
spr3_h:	dc.w	$0
	dc.w	$12E
spr3_l:	dc.w	$0
	;--- sprite4 ---
	dc.w	$130
spr4_h:	dc.w	$0
	dc.w	$132
spr4_l:	dc.w	$0
	;--- sprite5 ---
	dc.w	$134
spr5_h:	dc.w	$0
	dc.w	$136
spr5_l:	dc.w	$0
	;--- sprite6 ---
	dc.w	$138
spr6_h:	dc.w	$0
	dc.w	$13A
spr6_l:	dc.w	$0
	;--- sprite7 ---
	dc.w	$13C
spr7_h:	dc.w	$0
	dc.w	$13E
spr7_l:	dc.w	$0

	dc.w BPLCON0,$4200
	dc.w DMACON,(1<<5)|(1<<8)|(1<<15)	;ON sprite/Bitplane

GameCopWait:	dc.w	$0
	dc.w	$8000+$7ffe

;;;;	dc.w BPLCON0,$0200
	dc.w DMACON,(1<<5)|(1<<8)	;OFF sprite/Bitplane
	
	CopperMove 	$8010,INTREQ	; *** TRIGGER SCREEN REFRESH ***

	dc.w BPL1MOD,((PANEL_WIDTH/8)-2)*(2-1)  ;Set the modulos
	dc.w BPL2MOD,((PANEL_WIDTH/8)-2)*(2-1)
	
	;;;;;dc.w DMACON,(1<<5)|(0<<15)	;sprites off
	;;;;;dc.w $0104,0	;hide sprites under bitplane

		
		
GameCopWait_Blankline:	dc.w	$0
	dc.w	$8000+$7ffe

	dc.w $00e0		;bitplane 1
BplanesGamePanel:
	dc.w $0000
	dc.w $00e2,0000
	dc.w $00e4,0000		;bitplane 2
	dc.w $00e6,0000
	dc.w $00e8		;bitplane 3
BplanesFixedGamePanel:
	dc.w $0000
	dc.w $00ea,0000
	dc.w $00ec,0000		;bitplane 4
	dc.w $00ee,0000

	dc.w $0102
;CopListPanel_HScrl:
	dc.w $0000

	;;;;;dc.w BPLCON0,$4200; 4 planes
	dc.w DMACON,(1<<5)|(1<<8)|(1<<15)	;ON sprite/Bitplane

GameCopWait2:	dc.w	$0
	dc.w	$8000+$7ffe

GameCopWait3:	dc.w	$0
	dc.w	$8000+$7ffe


	dc.w DMACON,(1<<5)|(1<<8)	;OFF sprite/Bitplane

;;;;	dc.w BPLCON0,$0200 ;comp video colour

	dc.l $fffffffe
	dc.l $fffffffe

	EVEN

; *** End of Game Copper List ***


;------------------------------------------------------

;*** Start of Menu copper list ***

	EVEN
MenuCopperlist:
;;;	dc.w BPLCON0,$0200

	;--- sprite0 ---
	dc.w	$120
Mspr0_h: dc.w	$0
	dc.w	$120+2
Mspr0_l:	dc.w	$0
	;--- sprite1 ---
	dc.w	$124
Mspr1_h: dc.w	$0
	dc.w	$124+2
Mspr1_l:	dc.w	$0
	;--- sprite2 ---
	dc.w	$128,$0
	dc.w	$12A,$0
	;--- sprite3 ---
	dc.w	$12C,$0
	dc.w	$12E,$0
	;--- sprite4 ---
	dc.w	$130,$0
	dc.w	$132,$0
	;--- sprite5 ---
	dc.w	$134,$0
	dc.w	$136,$0
	;--- sprite6 ---
	dc.w	$138,$0
	dc.w	$13A,$0
	;--- sprite7 ---
	dc.w	$13C,$0
	dc.w	$13E,$0


	dc.w $00e0		;bitplane 1
MenuBplanes:
	dc.w $0000
	dc.w $00e2,0000
	dc.w $00e4,0000		;bitplane 2
	dc.w $00e6,0000
	dc.w $00e8,0000		;bitplane 3
	dc.w $00ea,0000
	dc.w $00ec,0000		;bitplane 4
	dc.w $00ee,0000

;-==-=-=-=-==

	dc.w BPL1MOD,((512/8)*(BITPLANES-1))+((512-MENU_WIDTH)/8)  ;Set the modulos
	dc.w BPL2MOD,((512/8)*(BITPLANES-1))+((512-MENU_WIDTH)/8)

	dc.w $0102,$0000		;Horizontal scrolling
	dc.w $0104,%100100	;sprites

	dc.w $0180
MenuCol_CopperList:
	dc.w $0000
	dc.w $0182,0000
	dc.w $0184,0000
	dc.w $0186,0000
	dc.w $0188,0000
	dc.w $018a,0000
	dc.w $018c,0000
	dc.w $018e,0000
	dc.w $0190,0000
	dc.w $0192,0000
	dc.w $0194,0000
	dc.w $0196,0000
	dc.w $0198,0000
	dc.w $019a,0000
	dc.w $019c,0000
	dc.w $019e,0000

	dc.w BPLCON0,$4200
	dc.w DMACON,(1<<5)|(1<<8)|(1<<15)	;ON sprite/Bitplane

	CopperWait	446,255
	CopperWait	0,44
	CopperMove 	$8010,INTREQ	; *** TRIGGER SCREEN REFRESH ***
	
	dc.w DMACON,(1<<5)|(1<<8)	;OFF sprite/Bitplane
	;;;dc.w BPLCON0,$0200

	dc.l $fffffffe
	dc.l $fffffffe

	EVEN

; *** End of Menu Copper List ***




