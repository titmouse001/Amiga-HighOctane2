ADDTEXT		MACRO
\1:		dc.b	\2,NULL
\1_SIZE:	EQU	*-\1
		ENDM
		
	EVEN
	;-------------------------------------------------
	; *** FILE NAMES ***
	
	ADDTEXT	MSG_MAPXX,"data/maps/road%02ld.map"
	
	;------------------------------------------------
	
	; *** DEBUG SCREEN MESSAGES ***
	
	ADDTEXT	MSG_LF,LF
	ADDTEXT	MSG_FREEFASTSIZE,"FastMem:[1m%ld[0m...[1m%ld[0mFree"
	ADDTEXT	MSG_FREECHIPSIZE,"ChipMem:[1m%ld[0m...[1m%ld[0mFree"
	ADDTEXT	MSG_PROGRAMSPACE,"Program:[1m%ld[0mcode+[1m%ld[0mdata+[1m%ld[0mchip"
	ADDTEXT	MSG_TOTALALLOC,"Total_Allocated[chip[1m%ld[0mk][fast[1m%ld[0mk]"
	ADDTEXT	MSG_DECRUNCHING,"[33munpacked[0m:[1m%ld[0m"
	ADDTEXT	MSG_LEAVECRUNCHED,"[33mKeeping_Packed[0m"
	ADDTEXT	MSG_CPU,"<CPU:680%02ld>"
	ADDTEXT	MSG_MAP_ERROR,"ERROR:BAD-MAP-FORMAT"
	ADDTEXT	MSG_CANT_TAKE_SYSTEM,"ERROR:CAN'T-HALT-SYSTEM"
	ADDTEXT	MSG_LOADERROR,"ERROR:File-Not-Found-'%s'"
	ADDTEXT	MSG_AllocError,"ERROR:Alloc-Error"
	ADDTEXT	MSG_FREEINGMEM,"[33mFREEING-ALL-MEMORY:[0m"
	ADDTEXT	MSG_PAL,"<PAL_system>"
	ADDTEXT	MSG_NTSC,"<NTSC_system>"
	ADDTEXT	MSG_AGA,"<AGA_Chip_Set>"
	ADDTEXT	MSG_ESC_Standard,"<ESC/Standard_Chip_Set>"
	ADDTEXT	MSG_BYTES,"[1m%8ld[0m"
	ADDTEXT	MSG_LOADINGNAME,"'[32m%s[0m'"
	ADDTEXT	MSG_RESERVING,"[1m%8ld[0m<bytes>...reserved"
	ADDTEXT	MSG_CHIP,"[Chip:[1m%ld[0m]"
	ADDTEXT	MSG_FAST,"[Fast:[1m%ld[0m]"
	ADDTEXT	MSG_ERROR,"[MEM?:[1m%ld[0m]"
	ADDTEXT	MSG_DEBUG,"DEBUG[1m%ld[0m"
	ADDTEXT	MSG_MEMBLOCKSNOTSETFREE,"Amount-of-Mem-Blocks-Not-Set-Free=%ld"
	ADDTEXT	MSG_TRASHINGMEM_LO,"***MEM_TRASHED_LO__loc:%ld/val:%ld***"
	ADDTEXT	MSG_TRASHINGMEM_HI,"***MEM_TRASHED_HI__loc:%ld/val:%ld***"
	
	ADDTEXT	MSG_HEX,"HEX_%lx"

MSG_DEMO	dc.b	"            -HIGH OCTANE II-",LF,NULL
MSG_DEMO_SIZE	EQU	*-MSG_DEMO

	EVEN
	


