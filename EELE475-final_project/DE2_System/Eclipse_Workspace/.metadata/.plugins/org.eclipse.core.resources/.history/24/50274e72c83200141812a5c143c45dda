/*
 * lights.c
 *
 */
#define Switches (volatile int *) 0x00005030
#define LEDs 	 (int *) 0x00005020

void main()
{
	while (1){
		*LEDs = *Switches;
	}
}

