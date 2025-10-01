; MENUSYS.C - Compiled by CC68K  Version 3.0  (c) 1991-1997  P.J.Fondse
; #include "misc\stdlib.h"
; #include "menusys.h"
; #define 	ANGLES	(64L)
; #define 	SCALE		(16L)	/*Number of logic shifts, emulate "swap Dn"  (mul 65536)*/
; #define	TAB_SZE	(64L)
; #define	MAX_CARS	(4L)
; #define	NUM_SPEEDS	(32L)
; /*JOY_UP							  EQU  	%0000001*/
; /*JOY_DOWN   					  EQU  	%0000010*/
; #define JOY_LEFT	(0x04)		/*EQU  	%000 0100*/
; #define JOY_RIGHT	(0x08)		/*EQU 	%000 1000*/
; /*JOY_BUT1						  EQU 	%0010000*/
; #define JOY_TAPLEFT	(0x20)	/*EQU  	%010 0000*/
; #define JOY_TAPRIGHT	(0x40)	/*EQU 	%100 0000*/
; enum
; {
; MENU_STARTGAME,
; MENU_QUIT,
; MENU_ITEMS,
; };
; typedef struct
; {
; short x;
; short y;
; short w;
; short h;
; char*	Str; 
; char	Enable;
; }MenuT;
; MenuT MenuList[MENU_ITEMS]=
; {
_MenuList:
; {0,0,32,32,0/*"test"*/,TRUE},
	dc.w	96
	dc.w	32
	dc.w	250
	dc.w	48
	dc.l	0
	dc.b	1
	ds.b	1
; {32,32,32,32,0/*"test"*/,TRUE},
	dc.w	96
	dc.w	176
	dc.w	240
	dc.w	192
	dc.l	0
	dc.b	1
	ds.b	1
; };
; typedef struct  
; {
; /* Must Match ASM files "include/structure.i" */
; long adr; 	/*CAR_SCENE_ADR		rs.l	1*/
; long xpos; /*CAR_XPOS		rs.l	1*/
; long ypos; /*CAR_YPOS		rs.l	1*/
; long lastx; 	/*CAR_LASTXPOS		rs.l	1*/
; long lasty; 	/*CAR_LASTYPOS		rs.l	1*/
; long velx; 	/*CAR_VELX		rs.l	1*/
; long vely; 	/*CAR_VELY		rs.l	1*/
; long speed; /*CAR_SPEED		rs.l	1*/
; long frame;	/*CAR_FRAME		rs.l	1*/
; long relaod;	/*RELOADING_ROCKET	rs.l	1*/
; long turn;		/*CAR_TURN_AMOUNT		rs.l	1*/
; long trunskid;/*CAR_TURN_SKID		rs.l	1*/
; long grip;		/*CAR_ROAD_GRIP		rs.l	1*/
; long tred;		/*CAR_TREDMARKS		rs.l	1*/  
; short sndchan;	/*CAR_SNDCHANBIT		rs.w	1 */ 
; short sndnum;	/*CAR_PLAY_SND_NUM	rs.w	1  */
; short sndlast;	/*CAR_PLAY_SND_LASTNUM	rs.w	1*/
; short type;		/*CAR_TYPE		rs.w	1*/
; short no;		/*CAR_NUMBER		rs.w	1*/
; short joy;		/*CAR_JOY_DIR		rs.w	1*/
; short wob;		/*CAR_WOBBLE_COUNT	rs.w	1*/
; }CarT;
; /*-------------------------------------------------*/
; /* Machine code */
; /* assembly var externs*/
; extern short MouseX,MouseY;  			/*updated from screen refresh interrupt */
; extern unsigned char	Angles64[TAB_SZE][TAB_SZE];
; extern long CarDir_x_table[NUM_SPEEDS][TAB_SZE];
; extern long CarDir_y_table[NUM_SPEEDS][TAB_SZE];
; extern CarT CarList[];
; extern short CarTurnToFace[];
; extern short Map_x,Map_y;
; extern short QuitCurrentScreen;
; /* assembly routines  */
; void ClearGameScreen(void);
; long random(long in);	/*not using stdlib.h: rand() from the cc68k libs, to slow.  Created from c code/*
; long MouseButton(void);
; /*--------------------------------------------------*/
; /* 'c' functions */
; void DoMenu(void);
; long DoMenuSystem(void);
; void ControllCar(void);
; long Menu_Check(MenuT* m,long mousex,long mousey);
; long FindAngle64(long diffx,long diffy);
; void SetMapXY(short x,short y);
; /*----------------------------------------------------*/
; static long 		initspeed[MAX_CARS]={8L,5L,4L,3L};
menusys_initspeed:
	dc.l	8,5,4,3
; static short index[MAX_CARS][3]= {
menusys_index:
	dc.w	1,2,3,0,2,3,0,1,3,0,1,2
; {1,2,3}, /* against car 0 */
; {0,2,3}, /* 	"		 "	 1 */
; {0,1,3}, /* 	"		 "	 2 */
; {0,1,2}  /*	"		 "	 3 */
; };
; void DoMenu(void)
; {
_DoMenu:  
	link  	A6,#-4
	move.l	D2,-(A7)
; long MenuItem;
; do
; {
DoMenu_1:  
; MenuItem = DoMenuSystem();
	jsr  	_DoMenuSystem
	move.l	D0,D2
; switch (MenuItem)
	move.l	D2,D0
	tst.l	D0
	beq  	DoMenu_3
	cmp.l	#1,D0
	beq  	DoMenu_4
	bra  	DoMenu_5
DoMenu_3:  
; {
; case MENU_STARTGAME:
; StartGame_ASM();
	jsr  	_StartGame_ASM
; break;
	bra  	DoMenu_5
DoMenu_4:  
; case MENU_QUIT:
; MT_End();
	jsr  	_MT_End
; break;
DoMenu_5:  
	moveq  	#1,D0
	move.l	D2,D1
	cmp.l	D0,D1
	bne  	DoMenu_1
; }	
; }while (MenuItem!=MENU_QUIT)
; }
	move.l	(A7)+,D2
	unlk  	A6
	rts  
; long DoMenuSystem(void)
; {
_DoMenuSystem:  
	link  	A6,#-6
	movem.l	D2/D3,-(A7)
; short i;
; MenuT* ptr_memu;
; MT_End();
	jsr  	_MT_End
; QuitCurrentScreen = FALSE;
	clr.w	_QuitCurrentScreen
; SetMapXY(0,0);
	clr.w	-(A7)
	clr.w	-(A7)
	jsr  	_SetMapXY
	addq.w	#4,A7
; ClearGameScreen();
	jsr  	_ClearGameScreen
; InitMenus_withMusic_ASM();
	jsr  	_InitMenus_withMusic_ASM
; InitMenuCars();
	jsr  	_InitMenuCars
; for(;;)
DoMenuSystem_1:  
; {
; if ( MouseButton() )
	jsr  	_MouseButton
	tst.w	D0
	beq  	DoMenuSystem_3
; {
; ptr_memu=MenuList;	/*reset to firt in list*/
	move.l	#_MenuList,D3
; for (i=0;i<MENU_ITEMS;i++,ptr_memu++)
	moveq  	#0,D2
DoMenuSystem_5:  
	cmp.w	#2,D2
	bge  	DoMenuSystem_6
; {
; if ( Menu_Check(ptr_memu,MouseX,MouseY) )
	move.w	_MouseY,D0
	ext.l	D0
	move.l	D0,-(A7)
	move.w	_MouseX,D0
	ext.l	D0
	move.l	D0,-(A7)
	move.l	D3,-(A7)
	jsr  	_Menu_Check
	add.w	#12,A7
	tst.l	D0
	beq  	DoMenuSystem_7
; return (long)i;
	move.w	D2,D0
	ext.l	D0
	bra  	DoMenuSystem_0
DoMenuSystem_7:  
	move.w	D2,A0
	addq.w	#1,D2
	move.l	D3,A1
	add.l	#14,D3
	bra  	DoMenuSystem_5
DoMenuSystem_6:  
DoMenuSystem_3:  
; }
; }
; AnyCarCollisions();
	jsr  	_AnyCarCollisions
; ControllCar();
	jsr  	_ControllCar
; SetMapXY(0L,0L);
	moveq  	#0,D0
	move.w	D0,-(A7)
	moveq  	#0,D0
	move.w	D0,-(A7)
	jsr  	_SetMapXY
	addq.w	#4,A7
; ProcessMenuDisplay_ASM();
	jsr  	_ProcessMenuDisplay_ASM
	bra  	DoMenuSystem_1
DoMenuSystem_0:  
	movem.l	(A7)+,D2/D3
	unlk  	A6
	rts  
; }
; }
; void SetMapXY(short x,short y)
; {
_SetMapXY:  
	link  	A6,#0
; Map_x = x;
	move.w	8(A6),_Map_x
; Map_y = y;
	move.w	10(A6),_Map_y
; }
	unlk  	A6
	rts  
; void InitMenuCars(void)
; {
_InitMenuCars:  
	link  	A6,#-6
	movem.l	D2/D3/A2/A3,-(A7)
	move.l	#_random,A3
	moveq  	#16,D3
; CarT* 	ptr;
; short 		i;
; for (i=0;i<MAX_CARS;i++)	
	moveq  	#0,D2
InitMenuCars_1:  
	move.w	D2,D0
	ext.l	D0
	cmp.l	#4,D0
	bge  	InitMenuCars_2
; {
; ptr = &CarList[i];
	move.l	#_CarList,A0
	move.w	D2,D0
	muls  	#70,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,A2
; ptr->frame = random(ANGLES)<<SCALE;
	move.l	#64,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D3,D1
	asl.l	D1,D0
	move.l	D0,32(A2)
; ptr->velx=0L;
	clr.l	20(A2)
; ptr->vely=0L;
	clr.l	24(A2)
; ptr->xpos = random(320L)<<SCALE; 
	move.l	#320,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D3,D1
	asl.l	D1,D0
	move.l	D0,4(A2)
; ptr->ypos = random(256L)<<SCALE;
	move.l	#256,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D3,D1
	asl.l	D1,D0
	move.l	D0,8(A2)
; ptr->speed = 0L; 
	clr.l	28(A2)
	addq.w	#1,D2
	bra  	InitMenuCars_1
InitMenuCars_2:  
; }
; }
	movem.l	(A7)+,D2/D3/A2/A3
	unlk  	A6
	rts  
; void ControllCar(void)
; {
; CarT* 	ptr;
; long 		dx,dy;
; long 		speed;
; long		i,dir,car;
; long 		turn;
; static short	order[MAX_CARS]={0,0,1,2};
ControllCar_order:
	dc.w	0,0,1,2
; static long count=99;
ControllCar_count:
	dc.l	99
_ControllCar:  
	link  	A6,#-32
	movem.l	D2/D3/D4/D5/D6/D7/A2/A3/A4/A5,-(A7)
	moveq  	#16,D5
	move.l	#_random,A3
	move.l	#ControllCar_count,A4
	move.l	#ControllCar_order,A5
; count--;
	subq.l	#1,(A4)
; if (count<0)
	moveq  	#0,D0
	move.l	(A4),D1
	cmp.l	D0,D1
	bge  	ControllCar_1
; {
; count=random(100L)+50L;
	move.l	#100,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	add.l	#50,D0
	move.l	D0,(A4)
; order[1]=index[1][random(3)];
	moveq  	#6,D0
	and.l	#65535,D0
	move.l	#menusys_index,A0
	add.l	D0,A0
	move.l	A0,-(A7)
	moveq  	#3,D0
	move.l	D0,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D0,-(A7)
	moveq  	#2,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	(A7)+,A0
	add.l	D0,A0
	moveq  	#2,D0
	and.l	#65535,D0
	move.l	A5,A1
	add.l	D0,A1
	move.w	(A0),(A1)
; order[2]=index[2][random(3)];
	moveq  	#12,D0
	and.l	#65535,D0
	move.l	#menusys_index,A0
	add.l	D0,A0
	move.l	A0,-(A7)
	moveq  	#3,D0
	move.l	D0,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D0,-(A7)
	moveq  	#2,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	(A7)+,A0
	add.l	D0,A0
	moveq  	#4,D0
	and.l	#65535,D0
	move.l	A5,A1
	add.l	D0,A1
	move.w	(A0),(A1)
; order[3]=index[3][random(3)];
	moveq  	#18,D0
	and.l	#65535,D0
	move.l	#menusys_index,A0
	add.l	D0,A0
	move.l	A0,-(A7)
	moveq  	#3,D0
	move.l	D0,-(A7)
	jsr  	(A3)
	addq.w	#4,A7
	move.l	D0,-(A7)
	moveq  	#2,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	(A7)+,A0
	add.l	D0,A0
	moveq  	#6,D0
	and.l	#65535,D0
	move.l	A5,A1
	add.l	D0,A1
	move.w	(A0),(A1)
ControllCar_1:  
; }
; for (i=0;i<MAX_CARS;i++)	
	moveq  	#0,D0
	move.l	D0,D3
ControllCar_3:  
	cmp.l	#4,D3
	bge  	ControllCar_4
; {
; ptr = &CarList[i];
	move.l	#_CarList,A0
	move.l	D3,-(A7)
	moveq  	#70,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.l	A0,A2
; if ( i==0)
	moveq  	#0,D0
	move.l	D3,D1
	cmp.l	D0,D1
	bne  	ControllCar_5
; {
; dx = ( MouseX - (ptr->xpos>>SCALE) );
	move.w	_MouseX,D0
	ext.l	D0
	move.l	4(A2),D1
	move.l	D0,-(A7)
	move.l	D5,D0
	asr.l	D0,D1
	move.l	(A7)+,D0
	sub.l	D1,D0
	move.l	D0,D6
; dy = ( MouseY - (ptr->ypos>>SCALE) );
	move.w	_MouseY,D0
	ext.l	D0
	move.l	8(A2),D1
	move.l	D0,-(A7)
	move.l	D5,D0
	asr.l	D0,D1
	move.l	(A7)+,D0
	sub.l	D1,D0
	move.l	D0,D7
	bra  	ControllCar_6
ControllCar_5:  
; }
; else
; {
; car= i-1; /*order[i];*/
	move.l	D3,D0
	moveq  	#1,D1
	sub.l	D1,D0
	move.l	D0,-28(A6)
; dx = (CarList[car].xpos - ptr->xpos)>>SCALE;
	move.l	#_CarList,A0
	move.l	-28(A6),-(A7)
	moveq  	#70,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.l	4(A0),D0
	sub.l	4(A2),D0
	move.l	D5,D1
	asr.l	D1,D0
	move.l	D0,D6
; dy = (CarList[car].ypos - ptr->ypos)>>SCALE;
	move.l	#_CarList,A0
	move.l	-28(A6),-(A7)
	moveq  	#70,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.l	8(A0),D0
	sub.l	8(A2),D0
	move.l	D5,D1
	asr.l	D1,D0
	move.l	D0,D7
ControllCar_6:  
; }
; dir = (ptr->frame>>SCALE) - FindAngle64(dy,dx);
	move.l	32(A2),D0
	move.l	D5,D1
	asr.l	D1,D0
	move.l	D0,-(A7)
	move.l	D6,-(A7)
	move.l	D7,-(A7)
	jsr  	_FindAngle64
	addq.w	#8,A7
	move.l	D0,D1
	move.l	(A7)+,D0
	sub.l	D1,D0
	move.l	D0,D2
; dir = CarTurnToFace[dir];
	move.l	D2,-(A7)
	moveq  	#2,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	#_CarTurnToFace,A0
	add.l	D0,A0
	move.w	(A0),D0
	ext.l	D0
	move.l	D0,D2
; if (dir&JOY_LEFT)
	move.l	D2,D0
	moveq  	#4,D1
	and.l	D1,D0
	tst.l	D0
	beq  	ControllCar_7
; turn= -(( 2L<<SCALE)-((1L<<SCALE)/2L));
	move.l	#-98304,D4
	bra  	ControllCar_8
ControllCar_7:  
; else if (dir&JOY_TAPLEFT)
	move.l	D2,D0
	moveq  	#32,D1
	and.l	D1,D0
	tst.l	D0
	beq  	ControllCar_9
; turn=(-(1L<<SCALE));
	move.l	#-65536,D4
	bra  	ControllCar_10
ControllCar_9:  
; else if (dir&JOY_RIGHT)           
	move.l	D2,D0
	moveq  	#8,D1
	and.l	D1,D0
	tst.l	D0
	beq  	ControllCar_11
; turn= (( 2L<<SCALE)-((1L<<SCALE)/2L));
	move.l	#98304,D4
	bra  	ControllCar_12
ControllCar_11:  
; else if (dir&JOY_TAPRIGHT)           
	move.l	D2,D0
	moveq  	#64,D1
	and.l	D1,D0
	tst.l	D0
	beq  	ControllCar_13
; turn=( (1L<<SCALE));  
	move.l	#65536,D4
	bra  	ControllCar_14
ControllCar_13:  
; else
; turn=0L;
	moveq  	#0,D4
ControllCar_14:  
ControllCar_12:  
ControllCar_10:  
ControllCar_8:  
; ptr->frame+=turn;
	move.l	D4,D0
	add.l	D0,32(A2)
; ptr->frame&=0x3FFFFFL;
	and.l	#4194303,32(A2)
; ptr->speed += ((initspeed[i]<<SCALE)-ptr->speed)>>2;
	move.l	D3,-(A7)
	moveq  	#4,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	#menusys_initspeed,A0
	add.l	D0,A0
	move.l	(A0),D0
	move.l	D5,D1
	asl.l	D1,D0
	sub.l	28(A2),D0
	asr.l	#2,D0
	add.l	D0,28(A2)
; speed = ptr->speed>>SCALE;               
	move.l	28(A2),D0
	move.l	D5,D1
	asr.l	D1,D0
	move.l	D0,-16(A6)
; dir	= ptr->frame>>SCALE;
	move.l	32(A2),D0
	move.l	D5,D1
	asr.l	D1,D0
	move.l	D0,D2
; ptr->velx += CarDir_x_table[speed][dir]>>4;
	move.l	-16(A6),-(A7)
	move.w	#256,D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	#_CarDir_x_table,A0
	add.l	D0,A0
	move.l	D2,-(A7)
	moveq  	#4,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.l	(A0),D0
	asr.l	#4,D0
	add.l	D0,20(A2)
; ptr->vely += CarDir_y_table[speed][dir]>>4;    
	move.l	-16(A6),-(A7)
	move.w	#256,D0
	ext.l	D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	#_CarDir_y_table,A0
	add.l	D0,A0
	move.l	D2,-(A7)
	moveq  	#4,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.l	(A0),D0
	asr.l	#4,D0
	add.l	D0,24(A2)
; ptr->velx-=ptr->velx>>5;
	move.l	20(A2),D0
	asr.l	#5,D0
	sub.l	D0,20(A2)
; ptr->vely-=ptr->vely>>5;
	move.l	24(A2),D0
	asr.l	#5,D0
	sub.l	D0,24(A2)
; ptr->lastx = ptr->xpos;
	move.l	4(A2),12(A2)
; ptr->lasty = ptr->ypos; 
	move.l	8(A2),16(A2)
; ptr->xpos += ptr->velx;
	move.l	20(A2),D0
	add.l	D0,4(A2)
; ptr->ypos += ptr->vely; 
	move.l	24(A2),D0
	add.l	D0,8(A2)
	addq.l	#1,D3
	bra  	ControllCar_3
ControllCar_4:  
; }
; }
	movem.l	(A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4/A5
	unlk  	A6
	rts  
; void AnyCarCollisions(void)
; {
_AnyCarCollisions:  
	link  	A6,#-20
	movem.l	D2/D3/D4/D5/D6/A2/A3,-(A7)
	move.l	#655360,D4
; CarT*		ptr2;
; CarT* 	ptr;
; long 		sx,sy;
; short		k,j;
; for (k=0;k<4;k++)	
	moveq  	#0,D2
AnyCarCollisions_1:  
	cmp.w	#4,D2
	bge  	AnyCarCollisions_2
; {
; ptr = &CarList[k];
	move.l	#_CarList,A0
	move.w	D2,D0
	muls  	#70,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,A2
; if ((ptr->xpos<0L) || (ptr->xpos>(320L<<SCALE)) ||
	tst.l	4(A2)
	blt  	AnyCarCollisions_5
	cmp.l	#20971520,4(A2)
	bgt  	AnyCarCollisions_5
	tst.l	8(A2)
	blt  	AnyCarCollisions_5
	cmp.l	#15728640,8(A2)
	ble  	AnyCarCollisions_3
AnyCarCollisions_5:  
; (ptr->ypos<0L) || (ptr->ypos>(240L<<SCALE)))
; {
; ptr->velx = -ptr->velx;
	move.l	20(A2),D0
	neg.l	D0
	move.l	D0,20(A2)
; ptr->vely = -ptr->vely;
	move.l	24(A2),D0
	neg.l	D0
	move.l	D0,24(A2)
; ptr->xpos =  ptr->lastx;
	move.l	12(A2),4(A2)
; ptr->ypos =  ptr->lasty; 
	move.l	16(A2),8(A2)
AnyCarCollisions_3:  
; }
; for (j=0;j<3;j++)	
	moveq  	#0,D3
AnyCarCollisions_6:  
	cmp.w	#3,D3
	bge  	AnyCarCollisions_7
; {
; ptr2 = &CarList[index[k][j]];
	move.l	#_CarList,A0
	move.w	D2,D0
	muls  	#6,D0
	and.l	#65535,D0
	move.l	#menusys_index,A1
	add.l	D0,A1
	move.w	D3,D0
	asl.w	#1,D0
	and.l	#65535,D0
	add.l	D0,A1
	move.w	(A1),D0
	muls  	#70,D0
	and.l	#65535,D0
	add.l	D0,A0
	move.l	A0,A3
; if ((ptr->xpos > ptr2->xpos-(10L<<SCALE) ) &&
	move.l	4(A3),D0
	sub.l	D4,D0
	move.l	4(A2),D1
	cmp.l	D0,D1
	ble  	AnyCarCollisions_8
	move.l	4(A3),D0
	add.l	D4,D0
	move.l	4(A2),D1
	cmp.l	D0,D1
	bge  	AnyCarCollisions_8
	move.l	8(A3),D0
	sub.l	D4,D0
	move.l	8(A2),D1
	cmp.l	D0,D1
	ble  	AnyCarCollisions_8
	move.l	8(A3),D0
	add.l	D4,D0
	move.l	8(A2),D1
	cmp.l	D0,D1
	bge  	AnyCarCollisions_8
; (ptr->xpos < ptr2->xpos+(10L<<SCALE) ) && 
; (ptr->ypos > ptr2->ypos-(10L<<SCALE) ) &&
; (ptr->ypos < ptr2->ypos+(10L<<SCALE) ) && )
; {
; sx=ptr->velx;
	move.l	20(A2),D5
; sy=ptr->vely;
	move.l	24(A2),D6
; ptr->velx=ptr2->velx;
	move.l	20(A3),20(A2)
; ptr->vely=ptr2->vely;
	move.l	24(A3),24(A2)
; ptr->xpos = ptr->lastx;
	move.l	12(A2),4(A2)
; ptr->ypos = ptr->lasty; 
	move.l	16(A2),8(A2)
; ptr->speed=0L;
	clr.l	28(A2)
; ptr2->velx=sx;
	move.l	D5,20(A3)
; ptr2->vely=sy;
	move.l	D6,24(A3)
; ptr2->xpos = ptr2->lastx;
	move.l	12(A3),4(A3)
; ptr2->ypos = ptr2->lasty; 
	move.l	16(A3),8(A3)
; ptr2->speed=0L;
	clr.l	28(A3)
AnyCarCollisions_8:  
	addq.w	#1,D3
	bra  	AnyCarCollisions_6
AnyCarCollisions_7:  
	addq.w	#1,D2
	bra  	AnyCarCollisions_1
AnyCarCollisions_2:  
; }
; }
; }		
; }
	movem.l	(A7)+,D2/D3/D4/D5/D6/A2/A3
	unlk  	A6
	rts  
; long Menu_Check(MenuT* m,long mousex,long mousey)
; {
_Menu_Check:  
	link  	A6,#0
	movem.l	D2/D3/A2,-(A7)
	move.l	8(A6),A2
	move.l	12(A6),D2
	move.l	16(A6),D3
; if (m->Enable)
	tst.b	12(A2)
	beq  	Menu_Check_1
; {
; if ((mousex>=m->x) && (mousex<m->x+m->w) && 
	move.w	(A2),D0
	ext.l	D0
	move.l	D2,D1
	cmp.l	D0,D1
	blt  	Menu_Check_3
	move.w	(A2),D0
	add.w	4(A2),D0
	ext.l	D0
	move.l	D2,D1
	cmp.l	D0,D1
	bge  	Menu_Check_3
	move.w	2(A2),D0
	ext.l	D0
	move.l	D3,D1
	cmp.l	D0,D1
	blt  	Menu_Check_3
	move.w	2(A2),D0
	add.w	6(A2),D0
	ext.l	D0
	move.l	D3,D1
	cmp.l	D0,D1
	bge  	Menu_Check_3
; (mousey>=m->y) && (mousey<m->y+m->h)	)
; return 	1L;
	moveq  	#1,D0
	bra  	Menu_Check_0
Menu_Check_3:  
; else
; return	0L;
	moveq  	#0,D0
	bra  	Menu_Check_0
Menu_Check_1:  
; }
; }
Menu_Check_0:  
	movem.l	(A7)+,D2/D3/A2
	unlk  	A6
	rts  
; long FindAngle64(long diffx,long diffy)
; {
_FindAngle64:  
	link  	A6,#0
	movem.l	D2/D3/D4,-(A7)
	move.l	8(A6),D2
	move.l	12(A6),D3
	moveq  	#32,D4
; while ((abs(diffx)>=TAB_SZE/2L) || (abs(diffy)>=TAB_SZE/2L))
FindAngle64_1:  
	tst.l	D2
	bge  	FindAngle64_4
	move.l	D2,D0
	neg.l	D0
	bra  	FindAngle64_5
FindAngle64_4:  
	move.l	D2,D0
FindAngle64_5:  
	cmp.l	D4,D0
	bge  	FindAngle64_3
	tst.l	D3
	bge  	FindAngle64_6
	move.l	D3,D0
	neg.l	D0
	bra  	FindAngle64_7
FindAngle64_6:  
	move.l	D3,D0
FindAngle64_7:  
	cmp.l	D4,D0
	blt  	FindAngle64_2
FindAngle64_3:  
; {
; diffx>>=1L;
	move.l	D2,D0
	asr.l	#1,D0
	move.l	D0,D2
; diffy>>=1L;
	move.l	D3,D0
	asr.l	#1,D0
	move.l	D0,D3
	bra  	FindAngle64_1
FindAngle64_2:  
; }
; return (long)Angles64[32L+diffx][32L+diffy];
	move.l	D4,D0
	add.l	D2,D0
	move.l	D0,-(A7)
	moveq  	#64,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	move.l	#_Angles64,A0
	add.l	D0,A0
	move.l	D4,D0
	add.l	D3,D0
	move.l	D0,-(A7)
	moveq  	#1,D0
	move.l	D0,-(A7)
	jsr  	LMUL
	move.l	(A7),D0
	addq.w	#8,A7
	add.l	D0,A0
	move.b	(A0),D0
	ext.w	D0
	ext.l	D0
	movem.l	(A7)+,D2/D3/D4
	unlk  	A6
	rts  
