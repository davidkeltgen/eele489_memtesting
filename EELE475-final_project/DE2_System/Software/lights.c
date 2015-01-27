#define Switches (volatile int *) 0x00003010
#define LEDs 	 (int *) 0x00003000

void main()
{ 
	while (1){
		*LEDs = *Switches;
	}
}


