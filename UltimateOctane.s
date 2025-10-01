;  * * * * * * * * * * * *
;  * * *   M A I N   * * *
;  * * * * * * * * * * * *

;	incdir	"hard:lang/Devpac3-2.0/include/"
	;----------------------------------------------
	;Amiga Includes - version 40.15
	include	"exec/exec_lib.i"	
	include	"exec/execbase.i"
	include	"exec/libraries.i"
	include	"exec/types.i"
	include	"exec/memory.i"
	include	"graphics/gfxbase.i"
	include	"graphics/graphics_lib.i"
	include	"hardware/custom.i"
	include	"dos/dos_lib.i"
	include  "dos/dos.i"
	
	;---------------------------------------------
	;* H I G H O C T A N E I I   I N C L U D E S *
	;---------------------------------------------
	include	"include/Structures.i"
	;-----------------------------
	include	"include/EQU_GAME.i"
	include "include/EQU_SYS.i"
	include "include/EQU_MENU.i"
	include "include/EQU_MUSIC.i"
	include "include/EQU_SFX.i"
	include "include/EQU_KEYS.i"
	include "include/EQU_SCRN.i"
	;-----------------------------
	include	"include/Macro_string.i"
	include	"include/Macro_SFX.i"
	include	"include/Macro_misc.i"
	include	"include/Macro_maths.i"
	include	"include/Macro_car.i"
	include "include/Macro_Misc.i"
	include "include/Macro_gfx.i"
	include "include/Macro_mem.i"
	include "include/Macro_INT.i"
	include "include/Macro_File.i"
	;----------------------------

	
;=============================================================	

MEMORY_DEBUG_ON		SET	0	;0=off/1=on
;check adds 4k to alloc's,
;2k extra at start and a extra 2k at the end.
;=============================================================

	opt c-
	Section	Bitplanes,Code		;public mem

	Bra.s	PROGRAM_START
	dc.b	"$VER: HighOctaneII v1.21 by Paul Overy (FryUp Productions)",0
	even

PROGRAM_START:

	movem.l	d1-d7/a0-a6,-(sp)

	move.l	$4.w,a6		; exec base
	lea	doslib,a1
	CALL	oldopenlibrary	;support for obsolete 'openlibaray'	
	move.l	d0,dosbase	;store dos base
	;--------------------------------------------------
	move.l	DosBase,a6
	CALL	output		;finds the program's initial output filehandle
	move.l	d0,stdout	;store dos output
	;--------------------------------------------------
	PRINTDOS	MSG_DEMO,stdout


	BSR	InitMem
	bsr	Machine_Type
	bsr	Display_Machine_Info


	
	;-------------------------------------------------------
	;*** SCREEN MEMORY / CHIP RAM ***
	READFILE_ALLOC   #DISK_GFX_TITLE,LogicScreenBuffer,#MODE_OLDFILE,#MEMF_CHIP|MEMF_CLEAR
	
	cmp.l	#((512*320)/8)*4,FileSize ; just incase
	beq.s	.skip
	bra	Error
.skip	

	ADD_MEM_PRINTF	#MEMF_CHIP|MEMF_CLEAR,#((512*320)/8)*BITPLANES,PhysicScreenBuffer
	MEM_LONG_COPY	LogicScreenBuffer,PhysicScreenBuffer,#((512*320)/8)*BITPLANES

	ADD_MEM_PRINTF	#MEMF_CHIP|MEMF_CLEAR,#MAPDATA_HITSIZE_EXTRA*BLOCK_SIZE*BITPLANES*2,ReDrawIconsBuffer

	ADD_MEM_PRINTF  #MEMF_CHIP|MEMF_CLEAR,#(((CAR_BLIT_WIDTH*3)/8)*(CAR_BLIT_HEIGHT*3)),CollisionBuffer ;mask only

	;--------------------------------------------------------------------------
	; *** LOAD MAPS / FAST RAM ***
	move.l	#MAPDATA_MAPSIZE+MAX_BLOCKS+MAPDATA_ARWSIZE,d0
	ADD_MEM_PRINTF	#MEMF_FAST|MEMF_CLEAR,d0,MapDataBuffer ;map uncrunch space
	bsr	LoadAllMaps
;;;	move.l	#0,d7
;;;	bsr	SetCurrentMap
	;--------------------------------------------------------------------------
	READFILE_ALLOC   #DISK_GFX_Font,FontBuffer,#MODE_OLDFILE,#MEMF_FAST
	;--------------------------------------------------------------------------
	; LOAD AS CHIP RAM
	;--- ALL CARS GFX
	READFILE_ALLOC   #DISK_GFX_carfrms1,CarGfxBuffer1,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_carfrms2,CarGfxBuffer2,#MODE_OLDFILE,#MEMF_CHIP
	move.l CarGfxBuffer1,CarGfxBuffer3
	move.l CarGfxBuffer2,CarGfxBuffer4
;	READFILE_ALLOC   #DISK_GFX_carfrms2,CarGfxBuffer3,#MODE_OLDFILE,#MEMF_CHIP
;	READFILE_ALLOC   #DISK_GFX_carfrms2,CarGfxBuffer4,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_Mark,SkidsGfxBuffer,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_Rocket,RocketGfxBuffer,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_Blocks,IconBuffer,#MODE_OLDFILE,#MEMF_CHIP
	;----------------------------------------------------------------------------------
	ADD_MEM_PRINTF  #MEMF_CHIP|MEMF_CLEAR,#((PANEL_WIDTH/8)*PANEL_BITMAP_HEIGHT)*2,PanelBuffer
	READFILE_ALLOC   #DISK_GFX_Panel,FixedPanelBuffer,#MODE_OLDFILE,#MEMF_CHIP
	;----------------------------------------------------------------------------------
	READFILE_ALLOC   #DISK_GFX_Mouse,PointerBuffer,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_Spr_Car,CarSpriteBuffer1,#MODE_OLDFILE,#MEMF_CHIP
	;;;FILE TO BIG!!! STORE JUST PARTS NEEDED
;;;	READFILE_ALLOC   #DISK_GFX_Menu,MenuBuffer,#MODE_OLDFILE,#MEMF_CHIP
	READFILE_ALLOC   #DISK_GFX_Exp,ExplosionBuffer,#MODE_OLDFILE,#MEMF_CHIP
	;-------------------------------------------------------------------------------------
	LOAD_MUSIC_SLOT MOD_TITLE
	LOAD_MUSIC_SLOT MOD_INGAME1
	;-------------------------------------------------------
	; --- READ ALL SAMPLES, CONTAINED IN ONE FILE---
	READFILE_ALLOC #DISK_Sample1,Param2,#MODE_OLDFILE,#MEMF_CHIP|MEMF_CLEAR
	MAKE_SAMPLE_LIST	Param2,AllSamples
	;-------------------------------------------------------------------
	; --- Scene Map Animations ---
	ADD_MEM_PRINTF  #MEMF_FAST|MEMF_CLEAR,#MAX_BLOCKS,AnimBuffer
	bsr	SetUpSceneAnimations
	;-------------------------------------------------------------------	

	bsr	TakeSystem
	tst.l	d0
	bne	Error

;	***************************
;	*** Intro Screen & Menu *** 
;	***************************

	bsr	InitialiseGameSystem

	bsr	DoIntro  	
	
	bsr	_DoMenu	;menu's compiled in c
	
	
	bsr	RestoreSystem  ; *** EXIT GAME ***
	moveq	#0,d0	; dos return value
;---------------------------------------------
	Bra.s	NoError
Error:	PRINTDOS MSG_CANT_TAKE_SYSTEM,stdout
;---------------------------------------------
NoError:
	bsr	FreeAllMemory

	move.l	$4.w,a6		; exec base
	move.l	DosBase,a1
	CALL	closelibrary
	

	movem.l	(sp)+,d1-d7/a0-a6
	rts				;Back to OS

;--------------------------------------------------

	EVEN
	include "process_game.s"
	include "ProcessCars.s"
	include "interrupts.s"
	include "Terrain.s"
	include	"string.s"
	include	"maths.s"  ; - also 32 bit multiply and divide functions for CC68K
	include	"weapons.s"
	include "GFX.s"
	include "BlitCheck.s"
	include "Camra.s"
	include	"sound.s"
	include "pro.s"
	include	"Input_Keys.s"
	include "Input_Joy.s"
	include	"memory.s"
	include	"initstuff.s"
	include	"font.s
	include "map.s"
	include "STC_Decompactor.s"
	include "file.s"
	include "Startup.s"
	include	"Text.s"
	include "FileNames.s"
	include "debug.s"
	include "Menu.s"	
	EVEN
	include "menusys.asm"
	EVEN


END_PROGRAM_LABLE:

PROGMEM_CODE	EQU	(END_PROGRAM_LABLE-PROGRAM_START)
;--------------------------------------------------

; *** SOUND ***

FREQUENCY	EQU	523 ; NOTE "C"

M_COUNT	set	1
SAM_OFF	set	0

ADD_SAMPLE	MACRO
		dc.l	\<SAM_OFF>
		dc.w	(SAM_SIZE\<M_COUNT>)/2,0
SAM_OFF	set	SAM_OFF+SAM_SIZE\<M_COUNT>
M_COUNT	set 	M_COUNT+1
		ENDM

AllSamples:
	REPT	TOTAL_SAMPLES	;*** MACRO-LOOP ***
	ADD_SAMPLE 		;see "EQU_SFX.s"
	ENDR

;------------------------------------------------------------------------------
MapDataBufferList	dcb.l	MAX_LOADEED_MAPS	;Store pointers to each crunched data.
			
MapDataBuffer		dc.l	0	;Unpacked data pointers
HitDataBuffer		dc.l	0
ArrowDataBuffer		dc.l	0
AnimBuffer		dc.l	0	;FAST MEM (if possible)
;------------------------------------------------------------------------------

;;;;;LastMemReservedPtr	dc.l	0
CollisionBuffer		dc.l	0
Sample1Buffer		dc.l	0
SkidsGfxBuffer		dc.l	0
;;;;MenuBuffer		dc.l	0
ModuleBuffer		dc.l	0
BobGfxBuffer		dc.l	0
RocketGfxBuffer		dc.l	0

;----------------------------------------------------------------------------------
CarGfxBuffer1		dc.l	0 ;IMPORTANT:KEEP THESE TOGETHER IN 1 BLOCK
CarGfxBuffer2		dc.l	0 ;	     IN THE SAME ORDER
CarGfxBuffer3		dc.l	0 ;not used yet
CarGfxBuffer4		dc.l	0 ;not used yet
;----------------------------------------------------------------------------------
IconBuffer		dc.l	0
ReDrawIconsBuffer	dc.l	0

FontBuffer				dc.l	0
PanelBuffer				dc.l	0
FixedPanelBuffer		dc.l	0
PointerBuffer			dc.l	0
CarSpriteBuffer1		dc.l	0
CarSpriteBuffer2		dc.l	0

LogicScreenBuffer		dc.l	0
PhysicScreenBuffer	dc.l	0

;;LogicScreenBufferOffset		dc.l	0
;;PhysicScreenBufferOffset	dc.l	0

ExplosionBuffer		dc.l	0

WobbleTable0:	dc.l	0<<16,0<<16,0<<16,0<<16,0<<16,0<<16,0<<16,0<<16
		dc.l	0<<16,0<<16,0<<16,0<<16,0<<16,0<<16,0<<16,0<<16

WobbleTable1:	dc.l	+1<<16,0<<16,0<<16,-1<<16,+1<<16,-1<<16,-1<<16,+1<<16
		dc.l	+1<<16,0<<16,-1<<16,0<<16,+1<<16,-1<<16,+1<<16,-1<<16
		
		dc.l	WobbleTable1		;32
		dc.l	WobbleTable1            ;31
		dc.l	WobbleTable1            ;30
		dc.l	WobbleTable1            ;29
		dc.l	WobbleTable1            ;28
		dc.l	WobbleTable1            ;27
		dc.l	WobbleTable1            ;26
		dc.l	WobbleTable1            ;25
		dc.l	WobbleTable1            ;24
		dc.l	WobbleTable1            ;23
		dc.l	WobbleTable1            ;22
		dc.l	WobbleTable1            ;21
		dc.l	WobbleTable1            ;20
		dc.l	WobbleTable1            ;19
		dc.l	WobbleTable1            ;18
		dc.l	WobbleTable1		;17
		dc.l	WobbleTable1            ;16
		dc.l	WobbleTable1            ;15
		dc.l	WobbleTable1            ;14
		dc.l	WobbleTable1            ;13
		dc.l	WobbleTable1            ;12
		dc.l	WobbleTable1            ;11
		dc.l	WobbleTable1            ;10
		dc.l	WobbleTable1            ;9
		dc.l	WobbleTable1            ;8
		dc.l	WobbleTable1            ;7
		dc.l	WobbleTable1            ;6
		dc.l	WobbleTable1            ;5
		dc.l	WobbleTable1            ;4
		dc.l	WobbleTable1            ;3
		dc.l	WobbleTable1            ;2
		dc.l	WobbleTable1            ;1
WobbleBySpeed_tab2tab:	dc.l	WobbleTable0	;0
		dc.l	WobbleTable1		;1
		dc.l	WobbleTable1            ;2
		dc.l	WobbleTable1            ;3
		dc.l	WobbleTable1            ;4
		dc.l	WobbleTable1            ;5
		dc.l	WobbleTable1            ;6
		dc.l	WobbleTable1            ;7
		dc.l	WobbleTable1            ;8
		dc.l	WobbleTable1            ;9
		dc.l	WobbleTable1            ;10
		dc.l	WobbleTable1            ;11
		dc.l	WobbleTable1            ;12
		dc.l	WobbleTable1            ;13
		dc.l	WobbleTable1            ;14
		dc.l	WobbleTable1            ;15
		dc.l	WobbleTable1		;16
		dc.l	WobbleTable1            ;17
		dc.l	WobbleTable1            ;18
		dc.l	WobbleTable1            ;19
		dc.l	WobbleTable1            ;20
		dc.l	WobbleTable1            ;21
		dc.l	WobbleTable1            ;22
		dc.l	WobbleTable1            ;23
		dc.l	WobbleTable1            ;24
		dc.l	WobbleTable1            ;25
		dc.l	WobbleTable1            ;26
		dc.l	WobbleTable1            ;27
		dc.l	WobbleTable1            ;28
		dc.l	WobbleTable1            ;29
		dc.l	WobbleTable1            ;30
		dc.l	WobbleTable1            ;31
		dc.l	WobbleTable1            ;32
		
		
		
;------------------------------
; FILE.s support vars
FileMode	dc.l	0
Location_ptr	dc.l	0
FileName_ptr	dc.l	0
LockFile	dc.l	0
FileHandle	dc.l	0
FileSize	dc.l	0
MemType		dc.l	0
;-----------------------------

			CNOP	0,4
FileInfo_Struct:	ds.b	fib_SIZEOF
			EVEN
			
dosbase		 	dc.l	0
stdout			dc.l	0
OldLev2			dc.l	0
kb_temp:		ds.b	kb.sizeof
Qualifier_Table:	dc.b	"`abcdefg"

TotalAllocFast		dc.l	0
TotalAllocChip		dc.l	0

Param1			dc.l	0
Param2			dc.l	0
Param3			dc.l	0
Param4			dc.l	0
Param5			dc.l	0

PrintfVar1		dc.l	0
PrintfVar2		dc.l	0
PrintfVar3		dc.l	0

PrintF_Buffer:		ds.b	64
FileName_Buffer:	ds.b	64
			CNOP	0,4

;-----------------------------------------------------
SFXList:		dcb.b	SFX_SIZEOF*4,0
			EVEN
MusicList:		dcb.l	MAX_MUSIC_MODULES,0
			EVEN
MemoryList		dcb.b	MEM_SIZEOF*MAX_ALLOC_BLOCKS,0
			EVEN
;Joy players are first in the list, Cpu after.
_CarList	; extern for C compiler (extern for MENUS ONLY)
CarList			dcb.b	CAR_SIZEOF*MAX_CARS,0
			EVEN
BlastList		dcb.b	BLAST_SIZEOF*MAX_BLAST_PIXELS,0
			EVEN
ExplosionList		dcb.b	EXP_SIZEOF*MAX_EXPLOSIONS,0
			EVEN
RocketList		dcb.b	ROCKET_SIZEOF*MAX_ROCKETS,0
			EVEN
;;ZoneList		dcb.b	ZONE_SIZEOF*MAX_ZONES,0
;;			EVEN

;*** holds two items *** offset into map, icon no#
BlocksRestoreList	dcb.w	(MAPDATA_HITSIZE_EXTRA)*2,0
;-----------------------------------------------
StoreOldBlocks1		dcb.w	32*32,0
StoreOldBlocks2		dcb.w	32*32,0
StoreBlocksLoc1		dc.l	StoreOldBlocks1
StoreBlocksLoc2		dc.l	StoreOldBlocks2
;------------------------------------------------
			EVEN
				
;keeptimerB_HI	dc.b	0;TimerB HI
;keeptimerB_LO	dc.b	0;TimerB LO
;keepClkStart	dc.b	0;set commandbits: OneShot & CLK & Start
;		dc.b	0
			EVEN
;---------------------------------------------------
;	 	*** DATA ***
			EVEN
MapLookup		ds.l	MAX_BLOCKS
			EVEN
; *** NOTE: Lables inside file... CarDir_x_table: & CarDir_y_table: ***
			Include	"include/cardirxy.txt"
			EVEN

_Angles64:	; also externed for C code
	 		Include	"include/Angle64.txt"	; Find direction table
			EVEN

LockOnTab:		
			dc.w	 0	;blank
			dc.w	1060	;gun turret
			dc.w	980	;tank
			EVEN
			
;***LABLE IS IN MIDDLE OF TABLE***
;*** CarTurnToFace: ***
			Include "include/turndirs.txt" ; word data
			; find quickest route to turn
			; word index for above =  (CarFrame - NewDir)
;-----------------------------------------------------
CountExtraIcons		dc.w	EXTRA_BLOCKS_START ;holds skid effects
;-----------------------------------------------------

Scene_Anim_Speed	dc.w	%100
ScreenBlocksHeight		dc.w   	SCREENHEIGHT	
ScreenBlocksWidth			dc.w		BLOCKS_X*BLOCK_SIZE
ScreenRefresh		dc.w	0
;;;BlocksDown		dc.w	0
;---------------------------------
OldInterrupt		dc.l	0
RND			ds.l	2
screenrefreshed		dc.w	0
SceneAnimTimer		dc.w	1

_QuitCurrentScreen:
QuitCurrentScreen:	dc.w	1
;---------------------------------
LastKeyPressed		dc.w	0

_MouseX			dc.w	150
_MouseY			dc.w	256+64
OldMouseX		dc.b	0
OldMouseY		dc.b	0
;---------------------------------
_Map_x:					; 'C' compiler lable
Map_x			dc.w	0 	; CAMERA VIEW X
_Map_y:					; 'C' compiler lable
Map_y			dc.w	0  ; CAMERA VIEW Y

Bob_Map_x		dc.w	0
Bob_Map_y		dc.w	0
CameraTarget		dc.l	0
CameraTimer		dc.l	0
;CameraTargetType	dc.w	0
;CameraSmooth		dc.w 	0
;---------------------------------
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
LastChanPlayedMask	dc.w	0
LastChanLoopMask	dc.w	0
;--------------------------------
InterruptTimer		dc.l	0
;debugwaittime		dc.l	0
			EVEN

; 	****************
; 	*** Palettes ***
;	****************

TitlePalette:		incbin	data/gfx/Title.pal
GamePalette:		incbin	data/gfx/Game.pal
GamePanelPalette:	incbin	data/gfx/panel.pal

		EVEN

END_OF_VARS:
PROGMEM_VARS	EQU	(END_OF_VARS-END_PROGRAM_LABLE)
;---------------------------------------------------------
;	 ******************
; 	 *** Debug Vars ***
;	 ******************

;;;VarTableSpace	dc.l	(END_OF_VARS-END_PROGRAM_LABLE) ;+ 3 more longs
;;;FixedChipUsed 	dc.l	CHIP_END-CHIP_START
;;;ProgramSpace	dc.l	END_PROGRAM_LABLE-PROGRAM_START

;*************************************************************************
;*************************** C H I P   R A M *****************************
;*************************************************************************

	section	ChipRam,Code_c

CHIP_START:

	include "Copper_List.s"
	EVEN
BlankSound:	dcb.w	64,0

CHIP_END:

;*************************************************************************
PROGMEM_CHIP	EQU	(CHIP_END-CHIP_START)
