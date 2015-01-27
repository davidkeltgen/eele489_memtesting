
#include "count_binary.h"

/* A "loop counter" variable. */
static alt_u8 count;
/* A variable to hold the value of the button pio edge capture register. */
volatile int edge_capture;

/* A variable to hold the value of the button pio edge capture register. */
volatile int rxdata;

#define BUFFER_SIZE 512
volatile alt_u8 ring_buffer[BUFFER_SIZE];
volatile int ring_buffer_wr_idx;	// the next location to be written to
volatile int ring_buffer_rw_idx;	// the next location to be read from


/* Button pio functions */

/*
  Some simple functions to:
  1.  Define an interrupt handler function.
  2.  Register this handler in the system.
*/

/*******************************************************************
 * static void handle_button_interrupts( void* context, alt_u32 id)*
 *                                                                 *  
 * Handle interrupts from the buttons.                             *
 * This interrupt event is triggered by a button/switch press.     *
 * This handler sets *context to the value read from the button    *
 * edge capture register.  The button edge capture register        *
 * is then cleared and normal program execution resumes.           *
 * The value stored in *context is used to control program flow    *
 * in the rest of this program's routines.                         *
 ******************************************************************/



static void handle_button_interrupts(void* context, alt_u32 id)
{
    /* Cast context to edge_capture's type. It is important that this be 
     * declared volatile to avoid unwanted compiler optimization.
     */
    volatile int* edge_capture_ptr = (volatile int*) context;
    /* Store the value in the Button's edge capture register in *context. */
    *edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTONS_PIO_BASE);
    /* Reset the Button's edge capture register. */
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(BUTTONS_PIO_BASE, 0);
    IORD_ALTERA_AVALON_PIO_EDGE_CAP(BUTTONS_PIO_BASE); //An extra read call to clear of delay through the bridge

}

static void handle_uart_interrupts(void* context, alt_u32 id)
{
	/* if we are not about to write to the next location that need to be read (buffer not full) */
	if(ring_buffer_wr_idx != ring_buffer_rw_idx )
	{
		/* write incoming byte to the buffer and increment wr_idx */
		ring_bufffer[ring_buffer_wr_idx++] = IORD_ALTERA_AVALON_UART_RXDATA(UART_RS232_BASE);

		/* wrap wr_idx to within the bounds of the buffer size */
		ring_buffer_wr_idx = ring_buffer_wr_idx % BUFFER_SIZE;
	}
	else
	{
		/* buffer is full, so the incoming byte is discarded */
	}

	/* Reset the UART's status register. */
	IOWR_ALTERA_AVALON_UART_STATUS(UART_RS232_BASE, 0);
	IOWR_ALTERA_AVALON_UART_STATUS(UART_RS232_BASE, 0);
}

/* Initialize the BUTTONS_PIO. */

static void init_BUTTONS_PIO()
{
    /* Recast the edge_capture pointer to match the alt_irq_register() function
     * prototype. */
    void* edge_capture_ptr = (void*) &edge_capture;
    /* Enable all 4 button interrupts. */
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(BUTTONS_PIO_BASE, 0xf);  
    /* Reset the edge capture register. */
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(BUTTONS_PIO_BASE, 0x0);
    /* Register the interrupt handler. */
    alt_irq_register( BUTTONS_PIO_IRQ, edge_capture_ptr, handle_button_interrupts );
}

static void init_uart()
{
	void* rxdata_ptr = (void*) &rxdata;

	/* Enable all UART interrupts. */
	IOWR_ALTERA_AVALON_UART_CONTROL(UART_RS232_BASE, 0x01F);

	/* Reset the UART's status register. */
	IOWR_ALTERA_AVALON_UART_STATUS(UART_RS232_BASE, 0);

	/* Register the interrupt handler. */
	alt_irq_register( UART_RS232_IRQ, rxdata_ptr, handle_uart_interrupts);

	/* reset the ring buffer */
	ring_buffer_wr_idx = 0;
	ring_buffer_rw_idx = 0;
}


/* Functions used in main loop
 * lcd_init() -- Writes a simple message to the top line of the LCD.
 * initial_message() -- Writes a message to stdout (usually JTAG_UART).
 * count_<device>() -- Implements the counting on the respective device.
 * handle_button_press() -- Determines what to do when one of the buttons
 * is pressed.
 */
static void lcd_init( FILE *lcd )
{
    /* If the LCD Display exists, write a simple message on the first line. */
    LCD_PRINTF(lcd, "%c%s Counting will be displayed below...", ESC,
               ESC_TOP_LEFT);
}

static void initial_message()
{
    printf("\n\n**************************\n");
    printf("* Hello from Nios II!    *\n");
    printf("* Counting from 00 to ff *\n");
    printf("**************************\n");
}

/********************************************************
 * The following functions write the value of the global*
 * variable 'count' to 3 peripherals, if they exist in  *
 * the system.  Specifically:                           *
 * The LEDs will illuminate and the LCD will display the  *
 * hex value as the program loops.                      *
 * *****************************************************/
static void count_led()
{
    alt_u8 b = count;

    /* put the 8 bit count on the LEDs */
    *LEDs = count & 0x000000FF;

}

static void clear_led()
{
	/* turn LEDs off */
    *LEDs = 0x00000000;
}


/* static void count_lcd()
 * 
 * Display the value of 'count' on the LCD Display, if it
 * exists in the system.
 * 
 * NOTE:  A HAL character device driver is used, so the LCD
 * is treated as an I/O device (i.e.: using fprintf).  You
 * can read more about HAL drivers <link/reference here>.
 */

static void count_lcd( void* arg )
{
#ifdef LCD_DISPLAY_NAME
    FILE *lcd = (FILE*) arg;
    LCD_PRINTF(lcd, "%c%s 0x%x\n", ESC, ESC_COL2_INDENT5, count);
#endif
}

static void clear_lcd( void* arg)
{
#ifdef LCD_DISPLAY_NAME
    FILE *lcd = (FILE*) arg;
    LCD_PRINTF(lcd, "%c%c\n", ESC, ESC_CLEAR);
#endif
}

/* count_all merely combines all three peripherals counting */

static void count_all( void* arg )
{
    count_led();

    lcd_init( arg );
    count_lcd( arg );

//    printf("%02x,  ", count);

}
  

static void handle_button_press(alt_u8 type, FILE *lcd)
{
    /* Button press actions while counting. */
    if (type == 'c')
    {
        switch (edge_capture) 
        {
            /* Button 1:  Output counting to LED only. */
        case 0x1:
            count_led();
            clear_lcd( lcd );
            break;
        case 0x2:
        	lcd_init( lcd );
            count_lcd( lcd );
            clear_led();
            break;
            /* Button 4:  Output counting to LED, and D. */ 
        case 0x4:
            count_all( lcd );
            break;
            /* If value ends up being something different (shouldn't) do
               same as 8. */
        default:
            count_all( lcd );
            break;
        }
    }
    /* If 'type' is anything else, assume we're "waiting"...*/
    else
    {
        switch (edge_capture)
        {
        case 0x1:
            printf( "Button 2\n");
            edge_capture = 0;
            break;
        case 0x2:
            printf( "Button 3\n");
            edge_capture = 0;
            break;
        case 0x4:
            printf( "Button 4\n");
            edge_capture = 0;
            break;
        default:
            printf( "Button press UNKNOWN!!\n");
        }
    }
}
    
/*******************************************************************************
 * int main()                                                                  *
 *                                                                             *
 * Implements a continuous loop counting from 00 to FF.  'count' is the loop   *
 * counter.                                                                    *
 * The value of 'count' will be displayed on one or more of the following 3    *
 * devices, based upon hardware availability:  LEDs    *
 * and the LCD Display.                                                        *
 *                                                                             *
 * During the counting loop, a switch press of SW0-SW3 will affect the         *
 * behavior of the counting in the following way:                              *
 *                                                                             *
 * SW0 - Only the LED will be "counting".                                      *
 * SW1 - Only the LCD Display will be "counting".                              *
 * SW2 - All devices "counting".                                               *
 *                                                                             *
 * There is also a 7 second "wait", following the count loop,                 *
 * during which button presses are still                                       *
 * detected.                                                                   *
 *                                                                             *
 * The result of the button press is displayed on STDOUT.                      *
 *                                                                             *
 * NOTE:  These buttons are not de-bounced, so you may get multiple            *
 * messages for what you thought was a single button press!                    *
 *                                                                             *
 * NOTE:  References to Buttons 1-4 correspond to SW0-SW3 on the Development   *
 * Board.                                                                      *
 ******************************************************************************/

int main(void)
{ 
    int i;
    int wait_time;
    FILE * lcd;

    count = 0;

    /* Initialize the LCD, if there is one.
     */
    lcd = LCD_OPEN();
    if(lcd != NULL) {lcd_init( lcd );}
    
    /* Initialize the button pio and UART. */
    init_BUTTONS_PIO();
    init_uart();


/* Initial message to output. */

    initial_message();

/* Continue 0-ff counting loop. */

    while( 1 ) 
    {
        usleep(100000);
        if (edge_capture != 0)
        {
            /* Handle button presses while counting... */
            handle_button_press('c', lcd);
        }
        /* If no button presses, try to output counting to all. */
        else
        {
            count_all( lcd );
        }

        /* check for new bytes in the buffer */
        if(ring_buffer_rw_idx != )

        /*
         * If done counting, wait about 7 seconds...
         * detect button presses while waiting.
         */
        if( count == 0xff )
        {
            LCD_PRINTF(lcd, "%c%s %c%s %c%s Waiting...\n", ESC, ESC_TOP_LEFT,
                       ESC, ESC_CLEAR, ESC, ESC_COL1_INDENT5);
            printf("\nWaiting...");
            edge_capture = 0; /* Reset to 0 during wait/pause period. */

            /* Clear the 2nd. line of the LCD screen. */
            LCD_PRINTF(lcd, "%c%s, %c%s", ESC, ESC_COL2_INDENT5, ESC,
                       ESC_CLEAR);
            wait_time = 0;
            for (i = 0; i<70; ++i)
            {
                printf(".");
                wait_time = i/10;
                LCD_PRINTF(lcd, "%c%s %ds\n", ESC, ESC_COL2_INDENT5,
                    wait_time+1);

                if (edge_capture != 0) 
                {
                    printf( "\nYou pushed:  " );
                    handle_button_press('w', lcd);
                }
                usleep(100000); /* Sleep for 0.1s. */
            }
            /*  Output the "loop start" messages before looping, again.
             */
            initial_message();
            lcd_init( lcd );
        }
        count++;
    }
    LCD_CLOSE(lcd);
    return 0;
}
/******************************************************************************
 *                                                                             *
 * License Agreement                                                           *
 *                                                                             *
 * Copyright (c) 2006 Altera Corporation, San Jose, California, USA.           *
 * All rights reserved.                                                        *
 *                                                                             *
 * Permission is hereby granted, free of charge, to any person obtaining a     *
 * copy of this software and associated documentation files (the "Software"),  *
 * to deal in the Software without restriction, including without limitation   *
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,    *
 * and/or sell copies of the Software, and to permit persons to whom the       *
 * Software is furnished to do so, subject to the following conditions:        *
 *                                                                             *
 * The above copyright notice and this permission notice shall be included in  *
 * all copies or substantial portions of the Software.                         *
 *                                                                             *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  *
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    *
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE *
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      *
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     *
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         *
 * DEALINGS IN THE SOFTWARE.                                                   *
 *                                                                             *
 * This agreement shall be governed in all respects by the laws of the State   *
 * of California and by the laws of the United States of America.              *
 * Altera does not recommend, suggest or require that this reference design    *
 * file be used in conjunction or combination with any other product.          *
 ******************************************************************************/
