/*
 * main.h
 *
 *  Created on: Sep 23, 2014
 *      Author: Matthew Handley
 *      		David Keltgen
 */

#ifndef MAIN_H_
#define MAIN_H_


/*** includes ***/
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>
#include "system.h"
#include "sys/alt_irq.h"
#include "altera_avalon_pio_regs.h"

/*** defines ***/
#define Switches (volatile int *) 0x01001090
#define LEDs 	 (volatile int *) 0x01001080

/*** prototypes ***/
void 	WriteLCD		( char* string1, char* string2);
int 	GetActiveSwitch	();

#endif /* MAIN_H_ */
