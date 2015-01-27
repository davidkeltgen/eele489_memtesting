/*
 * main.c
 *
 *  Created on: Sep 30, 2014
 *      Author(s): 	Matthew Handley
 *					David Keltgen
 */

#include <stdio.h>
#include "gps.h"
#include "main.h"


void WriteLCD( char* string1, char* string2)
{
	FILE *lcd;
	lcd = fopen("/dev/lcd_display", "w");

	/* Write strings to the LCD. */
	if (lcd != NULL )
	{
		fprintf(lcd, "\n%s\n", string1);
		fprintf(lcd, "%s\n",string2);
	}
	else
	{
		printf("Could not open LCD file!\n");
	}

	fclose( lcd );
}

int GetActiveSwitch()
{
	int switchValues, i;
	int result = -1;

	switchValues = *Switches;
	for(i = 0; i < (sizeof(int) * 8);i++)
	{

		/* Mask the lower bit */
		if((switchValues & 1) == 1)
		{
			/* switch at Ith position is on */
			if(result == -1)
			{
				result = i;
			}
			else
			{
			   /* multiple switches are turned on */
			   return -1;
			}
		}

		/* Right shift switchValues 1 */
		switchValues >>= 1;
	 }
	return result;
}

int main()
{
	char c;

	/* init */
	*LEDs = 0x00000000;
	gps_print_error();
	gps_state_machine_reset();

	while(1)
	{
		c = getchar();

		//printf("%c",c);
		gps_state_machine(c);
	}
}


