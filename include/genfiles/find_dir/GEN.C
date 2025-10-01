#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>

/*
#include "gfxlib\gfx.h"
#include "gfxlib\svgagfx.h"
#include "gfxlib\timerint.h"
#include "gfxlib\poll.h"
#include "gfxlib\debug.h"
#include "gfxlib\memory.h"
#include "gfxlib\mouse.h"
#include "gfxlib\common.h"
#include "gfxlib\keyboard.h"
#include "gfxlib\main.ci"

*/

//#define		ANGLES			(64.0)
//#define		ANGLETABLESIZE	(16) 
#define		PI				(3.1415926535897932384626433832795)		
//short	 	AngleTable[ANGLETABLESIZE][ANGLETABLESIZE];

short*	 	AngleTable;

//char	 	SaveTable[ANGLETABLESIZE][ANGLETABLESIZE];

void 	CreateAngleTable(void);
//void 	GenVelTables(void);
//short 	FindAngle16(short X1,short Y1, short X2, short Y2);
void MakeTables(void);
void WriteAFile (char* BaseName);

long ANGLES;
long ANGLETABLESIZE;

int
//ProgramStart ( int argc, char** argv )
main ( int argc, char** argv )
{
//	char	palette[256*3];
//	short Mode,i,col;

	ANGLES = 64-1; //default with no input
	ANGLETABLESIZE = 64; //default with no input

	if (argc==4)
	{
		ANGLES = atoi(argv[2]);
		ANGLETABLESIZE = atoi(argv[3]) ;
	}
	else
	 	printf("USAGE: Gen <BaseName> <MaxAngle> <TableSize>\n"
			   "       Outputs `<Basename><MaxAngle>.c'\n"
			   "       Example: gen angle 64 32\n"
			   "                creates angle64.txt\n");

//	InitMouseDriver ();
//	GfxInit(GFXINIT_STANDARD);

//	InitTimerInterrupt ();
//	InitPoll();
//	InitKeyboardInterrupt ();

//	InitMemory ( 1024*2 ,0 );	//AllocSize in Kb
//	AllocateMemory ( &AngleTable, ANGLETABLESIZE*ANGLETABLESIZE*sizeof(short), Mem_AutoFree );

	AngleTable= malloc (1024*2*1024);

//	Mode = FindMode ( 640, 480, MODE_COL_256 );
//	SetGraphicModeEx(Mode, GFXSETMODE_STANDARD );

//	ResetMouseDriver ();
//   	ClearScreen();

//	srand(112);
//	col=1;
//	for (i=0;i<256*3;i+=3)
//	{
//		palette[i+0]=rand()%64;
//		palette[i+1]=rand()%64;
//		palette[i+2]=rand()%64;
//	}
//	SetPalette ( palette );
//

	MakeTables();

	WriteAFile(argv[1]);

	free(AngleTable);


//	KeyAsciiRead ();
//
//	FreeAutoMem ();
//	UninitMemory ();
//
//	RestoreGraphicMode();
//
//	ClearKeyboardInterrupt ();
//	UninitPoll();
//	ClearTimerInterrupt ();
//
//	GfxUninit ();
//	UninitMouseDriver ();

	return	0;
}


void
MakeTables(void)
{
	//short x,y,s;

 	CreateAngleTable();	


/*
	s=SCREENHEIGHT/ANGLETABLESIZE;
	for (y=0;y<ANGLETABLESIZE;y++)
	{
		if ( (y+s) > SCREENHEIGHT)
			break;

		for (x=0;x<ANGLETABLESIZE;x++)
	 	{
			FillRectangle(x*s,y*s,s,s,AngleTable[x+y*ANGLETABLESIZE]);
		}
	}

	Poll();
*/

}




void
WriteAFile (char* BaseName)
{
	FILE* File;
	short	x,y;
	char	FileName[128];

	sprintf (FileName,"%s%d.txt",BaseName,(long)ANGLES);

	File = fopen ( FileName, "wt" );	//write, text
	if ( File == NULL )
	{
		printf ("ERROR: cannot write file\n" );
		exit(1);
	}
		//ExitPrintf ( "ERROR: cannot write file\n" );

	fprintf ( File, "; NOTE: byte AngleTable[%d][%d] =\n",ANGLES,ANGLETABLESIZE,ANGLETABLESIZE );
	fprintf ( File, "; MAX ANGLE SET TO %d (MAX=360)\n",ANGLES );
	fprintf ( File, "; TABLE SIZE=%.1fk\n", (ANGLETABLESIZE*ANGLETABLESIZE)/1024.0);

//	fprintf ( File, "{\n" );

	for (y=0; y<ANGLETABLESIZE; y++)
	{
		fprintf ( File, "   dc.b " );

		for (x=0; x<ANGLETABLESIZE; x++)
		{
			if (x==(ANGLETABLESIZE)-1)
				fprintf ( File, "%2d", AngleTable[x+y*ANGLETABLESIZE] );
			else
				fprintf ( File, "%2d,", AngleTable[x+y*ANGLETABLESIZE] );
		}

	 	fprintf ( File, "\n" );
//	 	fprintf ( File, " },\n" );

	}

//	fprintf ( File, "}; " );
	fclose ( File );
}
										

//-----------------------------------------------------------------------


void
CreateAngleTable(void)
{
	short 	x,y,a;
	float	angle;

	for (y=0; y<ANGLETABLESIZE; y++)
	{	
		for (x=0; x<ANGLETABLESIZE; x++ )
		{
			angle = atan2 ( (x-ANGLETABLESIZE/2), (ANGLETABLESIZE/2)-y ); 
			a= (angle/(2.0*PI)*(float)ANGLES);

			if (x<ANGLETABLESIZE/2)
					AngleTable[x+(ANGLETABLESIZE)*y] =(ANGLES-1-abs(a));
			else
				AngleTable[x+(ANGLETABLESIZE*y)] = abs(a);

		}
	}

}


//-----------------------------------------------------------------------


//
//void
//GenVelTables(void)
//{
//	short	i,a,Speed,x,y;
//	float	angle;
//
//	for (Speed=0; Speed<AccSpeeds; Speed++)
//	{
//		i=(ANGLES/4);		// start offset, cos(0)/sin(0)=90deg
//		for (a=0; a<ANGLES; a++)
//		{
//			angle = (2*PI*a)/ANGLES;
//			x=cos(angle) * 32.0*Speed;
//			y=sin(angle) * 32.0*Speed;
//
//			WalkPath_X[Speed][i]=x;
//			WalkPath_Y[Speed][i]=y;
//	
//			i++;
//			if (i>ANGLES-1)
//				i=0;
//		}
//	}
//
////	for (Speed=0; Speed<AccSpeeds; Speed++)
////	{
////		for (i=0;i<ANGLES;i++)
////			printf ("%2d,",WalkPath_X[Speed][i]);
////
////		printf ("\n");
////
////	}
//
//
//}
//


//
//
//short 
//FindAngle16(short X1, short Y1, short X2, short Y2)
//{
//	short	DiffX;
//	short	DiffY;
//	short 	ang;
//
//	DiffX = X1 - X2 ;
//	DiffY = Y1 - Y2 ;
//	
//	while (abs(DiffX)>=ANGLETABLESIZE || abs(DiffY)>=ANGLETABLESIZE)
//	{
//		DiffX=DiffX/2;
//		DiffY=DiffY/2;
//	}
//
//	ang=SaveTable[ANGLETABLESIZE-(DiffX)][ANGLETABLESIZE-(DiffY)]; 
//
//	return ang%ANGLES;
//
//}
//

//void
//Delay ( long Time )
//{
//	long Waitfor;
//
//	Waitfor = InterruptCounter + Time;
//
//	while ( InterruptCounter < Waitfor )
//		;
//
//}
//

