/*

file gps.h

Matthew Handley
EELE475 HW2
2014-09-16

Header file for gps.c

Contains typedefs, defines, and prototypes

*/

#ifndef GPS_H
#define GPS_H

#include "count_binary.h"

/*** type definitions ***/
typedef struct GPS_TIME_T
{
	char hour[3];
	char minute[3];
	char second[6];
} GPS_TIME_T;

typedef struct GPS_TIME_D_T
{
	int 	hour;
	int 	minute;
	int 	second;
	char 	ampm[3];
} GPS_TIME_D_T;

typedef struct GPS_ANGLE_T
{
	char degrees[4];
	char minutes[9];
	char direction[2];
} GPS_ANGLE_T;

typedef struct GPS_ALT_T
{
	char alt[7];
	char unit[2];
} GPS_ALT_T;

typedef struct GPS_SATID_T
{
	char id[3];
} GPS_SATID_T;

typedef struct GPGGA_T
{
	GPS_TIME_T 	time;
	GPS_ANGLE_T	lat;
	GPS_ANGLE_T	lon;
	GPS_ALT_T	alt;
} GPGGA_T;

typedef struct GPGGA_D_T
{
	GPS_TIME_D_T 	time;
	double			lat;
	char 			lat_dir[2];
	double			lon;
	char 			lon_dir[2];
	double			alt;
	char 			alt_unit[3];
} GPGGA_D_T;

typedef struct GPGSA_T
{
	GPS_SATID_T	list[12];
} GPGSA_T;

typedef struct GPGSA_D_T
{
	int		list[12];
} GPGSA_D_T;

typedef union GPS_LOG_U
{
	GPGGA_T 	gpgga;
	GPGSA_T 	gpgsa;
	GPGGA_D_T 	gpgga_d;
	GPGSA_D_T 	gpgsa_d;
} GPS_LOG_U;

typedef enum 
{
	GPGGA,
	GPGSA,
	GPGGA_D,
	GPGSA_D
} GPS_LOG_T;

typedef enum
{
	NONE = 0,
	SOME = 1,
	ALL  = 2
} DEBUG_LEVEL;


/*** defines ***/
#define debug_level NONE

# define GPS_NUM_SATIDS 12 

enum
{
	GPGGA_COL_TIME 		= 1,
	GPGGA_COL_LON 		= 2,
	GPGGA_COL_LON_DIR 	= 3,
	GPGGA_COL_LAT		= 4,
	GPGGA_COL_LAT_DIR	= 5,
	GPGGA_COL_ALT		= 9,
	GPGGA_COL_ALT_DIR	= 10
} GPGGA_COL;

/*** prototypes ***/
void gps_init                   ( void );
void gps_state_machine_reset	( void );
void gps_state_machine			( char c );
void gps_save_string				( void );
void gps_convert_log			( void );
void gps_save_error		    	( void );


#endif
