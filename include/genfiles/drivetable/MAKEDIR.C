#include <math.h>
#include <stdio.h>

#define	PI (3.141592)

#define	FRAMES	(64)
#define	TABLES	(32)

void	Angles(long in);

void
main(void)
{
	Angles(1);

	printf("\n\n\n\n\n\n\n");

	Angles(0);
}

void
Angles(long in)
{
	float	angle,scale;
	long	k,i,move,mem;
	

	mem=FRAMES*TABLES*4;
	
	printf ("; MEMORY USED:");
	printf ("%ld<bytes> %ld<kb>\n",mem,mem/1024);

	if (in)
		printf ("\n***************\nCarDir_x_table:\n***************\n");
	else
		printf ("\n***************\nCarDir_y_table:\n***************\n");

	for (k=0;k<TABLES;k++)
	{
		angle=-PI/2;
		scale=sin((PI/2)/TABLES);
		scale*=k*256;
	
		printf("\n; ---------%02d-------",k);

		for (i=0;i<FRAMES;i++)
		{
			if (in)
				move = cos(angle)*1024;
			else
				move = sin(angle)*1024;
			move*= scale;

			if (i%8==0)
			{
				printf("\n");
				printf("	dc.l	");
			}
	
			if ((i+1)%8==0)
				printf("%ld",move);
			else
				printf("%ld,",move);

	 		angle+=(PI*2)/FRAMES;
		}
	}
}
