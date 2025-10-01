#include "misc\stdlib.h"
#include "menusys.h"


error uses laptop ver

#define 	ANGLES	(64L)
#define 	SCALE		(16L)	/*Number of logic shifts, emulate "swap Dn"  (mul 65536)*/
#define	TAB_SZE	(64L)
#define	MAX_CARS	(4L)
#define	NUM_SPEEDS	(32L)

/*JOY_UP							  EQU  	%0000001*/
/*JOY_DOWN   					  EQU  	%0000010*/
#define JOY_LEFT	(0x04)		/*EQU  	%000 0100*/
#define JOY_RIGHT	(0x08)		/*EQU 	%000 1000*/
/*JOY_BUT1						  EQU 	%0010000*/
#define JOY_TAPLEFT	(0x20)	/*EQU  	%010 0000*/
#define JOY_TAPRIGHT	(0x40)	/*EQU 	%100 0000*/


enum
{
	MENU_STARTGAME,
	MENU_QUIT,
	MENU_ITEMS,
};


typedef struct
{
	short x;
	short y;
	short w;
	short h;
	char*	Str; 
	char	Enable;
}MenuT;

MenuT Menu[MENU_ITEMS]=
{
	{0,0,32,32,0/*"test"*/,TRUE},
	{32,32,32,32,0/*"test"*/,TRUE},
};


typedef struct  
{
/* Must Match ASM files "include/structure.i" */
	long adr; 	/*CAR_SCENE_ADR		rs.l	1*/
	long xpos; /*CAR_XPOS		rs.l	1*/
	long ypos; /*CAR_YPOS		rs.l	1*/
	long lastx; 	/*CAR_LASTXPOS		rs.l	1*/
	long lasty; 	/*CAR_LASTYPOS		rs.l	1*/
	long velx; 	/*CAR_VELX		rs.l	1*/
	long vely; 	/*CAR_VELY		rs.l	1*/
	long speed; /*CAR_SPEED		rs.l	1*/
	long frame;	/*CAR_FRAME		rs.l	1*/
	long relaod;	/*RELOADING_ROCKET	rs.l	1*/
	long turn;		/*CAR_TURN_AMOUNT		rs.l	1*/
	long trunskid;/*CAR_TURN_SKID		rs.l	1*/
	long grip;		/*CAR_ROAD_GRIP		rs.l	1*/
	long tred;		/*CAR_TREDMARKS		rs.l	1*/  
	short sndchan;	/*CAR_SNDCHANBIT		rs.w	1 */ 
	short sndnum;	/*CAR_PLAY_SND_NUM	rs.w	1  */
	short sndlast;	/*CAR_PLAY_SND_LASTNUM	rs.w	1*/
	short type;		/*CAR_TYPE		rs.w	1*/
	short no;		/*CAR_NUMBER		rs.w	1*/
	short joy;		/*CAR_JOY_DIR		rs.w	1*/
	short wob;		/*CAR_WOBBLE_COUNT	rs.w	1*/
}CarT;

/*-------------------------------------------------*/

/* Machine code */
/* assembly var externs*/
extern short MouseX,MouseY;  			/*updated from screen refresh interrupt */
extern unsigned char	Angles64[TAB_SZE][TAB_SZE];
extern long CarDir_x_table[NUM_SPEEDS][TAB_SZE];
extern long CarDir_y_table[NUM_SPEEDS][TAB_SZE];
extern CarT CarList[];
extern short CarTurnToFace[];

/* assembly routines */
void ProcessMenuDisplay_ASM(void);
void InitMenus_withMusic_ASM(void);
void Quit_ASM(void);
void StartGame_ASM(void);
void SetMapXY_ASM(long x,long y);
long random_ASM(long in);	/*not using stdlib.h: rand() from the cc68k libs, to slow.  Created from c code/*

/*--------------------------------------------------*/
/* 'c' functions */
void DoMenu(void);
long DoMenuSystem(void);
void ControllCar(void);
long Menu_Check(MenuT* m,long mousex,long mousey);
long FindAngle64(long diffx,long diffy);
/*----------------------------------------------------*/

static short index[4][3]= {
									 {1,2,3}, /* against car 0 */
									 {0,2,3}, /* 	"		 "	 1 */
									 {0,1,3}, /* 	"		 "	 2 */
									 {0,1,2}  /*	"		 "	 3 */
									};
									
static long speedtab[]={ 8L,
								 5L,
								 4L,
								 3L};

void
DoMenu(void)
{
	long MenuItem;
	
	do
	{
	
		MenuItem = DoMenuSystem();

		switch (MenuItem)
		{
			case MENU_STARTGAME:
				StartGame_ASM();
			break;
			case MENU_QUIT:
				Quit_ASM();
			break;
		}	

	}while (MenuItem!=MENU_QUIT)
	
}



long
DoMenuSystem(void)
{
	short i;
	MenuT* m;
	long MouseButton(void);

	InitMenus_withMusic_ASM();
	InitMenuCars();

	for(;;)
	{
		if ( MouseButton() )
		{
			m=Menu;	/*reset to firt in list*/
			for (i=0;i<MENU_ITEMS;i++,m++)
			{
				if ( Menu_Check(m,MouseX,MouseY) )
					return (long)i;
			}
		}
		
		AnyCarCollisions();
				
		ControllCar();
				
		/*Func_SetMapXY_ASM(CarList[0L].xpos>>(SCALE),CarList[0L].ypos>>(SCALE)); */
		
		SetMapXY_ASM(0L,0L);
		
		/*DisplayMenuBobCar_ASM();*/
		
		ProcessMenuDisplay_ASM();
	}
}


void
InitMenuCars(void)
{

	CarT* 	ptr;
	short 		i;
	
	for (i=0;i<MAX_CARS;i++)	
	{
		ptr = &CarList[i];
		
		ptr->frame = random_ASM(ANGLES)<<SCALE;
		ptr->velx=0L;
		ptr->vely=0L;
		ptr->xpos = random_ASM(320L)<<SCALE; 
		ptr->ypos = random_ASM(256L)<<SCALE;
		ptr->speed = 0L; 
	}
}



void
ControllCar(void)
{
	CarT* 	ptr;
	long 		dx,dy;
	long 		speed;
	long		i,dir,car;
	long 		turn;
	
	/*
	static short	order[MAX_CARS]={0,0,1,2};
	static long count=99;
		
	count--;
	if (count<0)
	{
		count=random(100L)+50L;
		order[1]=index[1][random(3)];
		order[2]=index[2][random(3)];
		order[3]=index[3][random(3)];
	}
	*/	
		
	
	for (i=0;i<MAX_CARS;i++)	
	{
		ptr = &CarList[i];
		                      
		if ( i==0)
		{
			dx = ( MouseX - (ptr->xpos>>SCALE) );
			dy = ( MouseY - (ptr->ypos>>SCALE) );
		}
		else
		{
			car= i-1;
			/*car = order[i]; */
			dx  = (CarList[car].xpos - ptr->xpos)>>SCALE;
			dy  = (CarList[car].ypos - ptr->ypos)>>SCALE;
		}
		
		dir = (ptr->frame>>SCALE) - FindAngle64(dy,dx);
		dir = CarTurnToFace[dir];

		if (dir&JOY_LEFT)
			turn= -(( 2L<<SCALE)-((1L<<SCALE)/2L));
		else if (dir&JOY_TAPLEFT)
			turn=(-(1L<<SCALE));
		else if (dir&JOY_RIGHT)           
			turn= (( 2L<<SCALE)-((1L<<SCALE)/2L));
		else if (dir&JOY_TAPRIGHT)           
			turn=( (1L<<SCALE));  
		else
			turn=0L;
		       
		ptr->frame+=turn;
		ptr->frame&=0x3FFFFFL;  /* limit 0 to 63 (3fh) */

		ptr->speed += (speedtab[i]<<SCALE - ptr->speed)>>2;
		
		speed = ptr->speed>>SCALE;               
		dir	= ptr->frame>>SCALE;
		ptr->velx += CarDir_x_table[speed][dir]>>4;
		ptr->vely += CarDir_y_table[speed][dir]>>4;    
		ptr->velx-=ptr->velx>>5;
		ptr->vely-=ptr->vely>>5;
		ptr->lastx = ptr->xpos;
		ptr->lasty = ptr->ypos; 
		ptr->xpos += ptr->velx;
		ptr->ypos += ptr->vely; 
		
	}
}



void
AnyCarCollisions(void)
{
	CarT*		ptr2;
	CarT* 	ptr;
	long 		sx,sy;
	short		k,j;


	for (k=0;k<4;k++)	
	{
		ptr = &CarList[k];
		
		if ((ptr->xpos<0L) || (ptr->xpos>(320L<<SCALE)) ||
			 (ptr->ypos<0L) || (ptr->ypos>(240L<<SCALE)))
		{
			ptr->velx = -ptr->velx;
			ptr->vely = -ptr->vely;
			ptr->xpos =  ptr->lastx;
			ptr->ypos =  ptr->lasty; 
		}
		
		for (j=0;j<3;j++)	
		{
				ptr2 = &CarList[index[k][j]];
			
				if ((ptr->xpos > ptr2->xpos-(10L<<SCALE) ) &&
					 (ptr->xpos < ptr2->xpos+(10L<<SCALE) ) && 
					 (ptr->ypos > ptr2->ypos-(10L<<SCALE) ) &&
					 (ptr->ypos < ptr2->ypos+(10L<<SCALE) ) && )
				{
						sx=ptr->velx;
						sy=ptr->vely;

						ptr->velx=ptr2->velx;
						ptr->vely=ptr2->vely;
						ptr->xpos = ptr->lastx;
						ptr->ypos = ptr->lasty; 
						ptr->speed=0L;

						ptr2->velx=sx;
						ptr2->vely=sy;
						ptr2->xpos = ptr2->lastx;
						ptr2->ypos = ptr2->lasty; 
						ptr2->speed=0L;
				}
		}
	}		
}


long
Menu_Check(MenuT* m,long mousex,long mousey)
{
	if (m->Enable)
	{
		if ((mousex>=m->x) && (mousex<m->x+m->w) && 
			 (mousey>=m->y) && (mousey<m->y+m->h)	)
			return 	1L;
		else
			return	0L;
	}
}



long
FindAngle64(long diffx,long diffy)
{
	while ((abs(diffx)>=TAB_SZE/2L) || (abs(diffy)>=TAB_SZE/2L))
	{
		diffx>>=1L;
		diffy>>=1L;
	}
	
	return (long)Angles64[32L+diffx][32L+diffy];
}



/*

; Dropped these functions, I'm not really going to need them after all.
; Not going to create hotspots on the fly.  

void
Menu_Init(void)
{
	long	i;
	MenuT* m=Menu;

	for (i=0;i<MENU_ITEMS;i++,m++)
		Menu_CreateButton(m,-1,-1,-1,-1,0,FALSE);
}

void
Menu_CreateButton(MenuT* m,long x,long y,long w,long h,char* string,char Enable)
{
	m->x=x;
	m->y=y;
	m->w=w;
	m->h=h;
	m->Str=string;
	m->Enable=Enable;
}


*/