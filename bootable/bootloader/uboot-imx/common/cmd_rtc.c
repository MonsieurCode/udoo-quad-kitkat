/*
 * Command for sync iMX6 rtc with external pcf2123.
 *
 * Copyright (C) SECO s.r.l. 2013
 */
#include <common.h>
#include <spi_flash.h>

#include <asm/io.h>
#include <spi.h>
#include <rtc.h>
#include <linux/time.h>
#include <cmd_rtc.h>

#define MAX_COUNTER	1000

DECLARE_GLOBAL_DATA_PTR;

int do_rtc( void )
{
        
	struct rtc_time tm_default;
	struct rtc_time tm_first;
        struct rtc_time tm_second;
	u32 counter,utc_time;
	int err1 = 0, 
	    err2 = 0, 
	    err_set = 0,
	    err_os_flag_1 = 0, 
            os_flag_first = 0,
            err_os_flag_2 = 0, 
            os_flag_second = 0,
	    secure_counter = 0,
	    retry	   = 0;
	/* Default date value: 1970-01-01 - 00:00:00 */
	tm_default.tm_year = 0x70;
        tm_default.tm_mon  = 0x1;
	tm_default.tm_mday = 0x1;
	tm_default.tm_hour = 0x0;
	tm_default.tm_min  = 0x0;
	tm_default.tm_sec  = 0x0;
	tm_default.tm_wday = 0x4;
	
	/* 
	  Check Board Revision - 
	  REVB -> no RTC
          REVC -> RTC 
	*/
	if ( gd->bd->bi_arch_number == MACH_TYPE_MX6_SECO_Q7 ){
		
		if ( gd->bd->board_revision[1] < 0x31 ){
			printf("No rtc - board revision %x\n",gd->bd->board_revision[1]);
			return 0;
		}
	}
	else if ( gd->bd->bi_arch_number == MACH_TYPE_MX6_SECO_UQ7 ){

	 	if ( gd->bd->board_revision[1] < 0x20 ){
                        printf("No rtc - board revision %x\n",gd->bd->board_revision[1]);
                        return 0;
                }

	}
	/* else if (gd->bd->bi_arch_number == MACH_TYPE_MX6_SECO_uSBC ){
		// This check is not necessary, because only RevB have been released, and RevB is always equipped with RTC!!!
	}
	*/
	printf("Rtc:   ");	
	/*--Reading OS flag to verify external RTC time valid--*/	
	/*--BUG FIX - infinite loop avoids insecure readings  --*/
	do {
		secure_counter++;
		err_os_flag_1 = rtc_read_os_flag(&os_flag_first);
		err_os_flag_2 = rtc_read_os_flag(&os_flag_second);
		/*-- ?! Useless if statment!? */
		if ( secure_counter == MAX_COUNTER ){
			printf("\nOS flag: infinite loop\n");
			udelay(1000*1000);
			secure_counter = 0;
		}
		if ( err_os_flag_1 != 0 || err_os_flag_2 != 0 ){
			printf("\nOS flag: problem with SPI bus");
			udelay(1000);
			err_os_flag_1 = rtc_read_os_flag(&os_flag_first);
                	err_os_flag_2 = rtc_read_os_flag(&os_flag_second);
		}
		
	} while ( os_flag_first != os_flag_second );
	
#ifdef DEBUG_RTC	
	printf("\nSpi OS flag: %d   ",os_flag_first);
#endif

	if ( os_flag_first != 1 ){
	
		/*--Reading RTC SPI--*/
		/*--BUG FIX - infinite loop avoids insecure readings  --*/
		secure_counter = 0;
		do {
			secure_counter++;
			err1 = rtc_get(&tm_first);
			err2 = rtc_get(&tm_second);
			 /*-- ?! Useless if statment!? */
                	if ( secure_counter == MAX_COUNTER || err1 != 0 || err2 != 0 ){
                        	printf("\nrtc_get time infinite loop\n");
                        	udelay(1000*1000);
                        	secure_counter = 0;
                	}	
			
			 if ( ( tm_second.tm_sec == 0  &&
                               tm_second.tm_min == 0  &&
                               tm_second.tm_hour == 0 &&
                               tm_second.tm_mday == 0 &&
                               tm_second.tm_mon  == 0 &&
                               tm_second.tm_wday == 0 )   &&

			      (tm_first.tm_sec == 0  &&
			       tm_first.tm_min == 0  &&
			       tm_first.tm_hour == 0 &&
			       tm_first.tm_mday == 0 &&
			       tm_first.tm_mon  == 0 &&
			       tm_first.tm_wday == 0) && retry == 0 ){
					  
					printf("retry  ");
					retry = 1;
					udelay(1000*1000);
					printf("  resetting  ");
					rtc_reset();
					udelay(100);
					
					err1 = rtc_get(&tm_first);
					err2 = rtc_get(&tm_second);

			 }


		} while ( tm_first.tm_sec  != tm_second.tm_sec  &&
			tm_first.tm_min  != tm_second.tm_min  &&
			tm_first.tm_hour != tm_second.tm_hour &&
			tm_first.tm_mday != tm_second.tm_mday &&
			tm_first.tm_mon  != tm_second.tm_mon  &&
			tm_first.tm_wday != tm_second.tm_wday	);
		
		

		if ( ( err1 != 0 && err2 != 0 ) || 
		     (tm_first.tm_sec == 0  &&
		     tm_first.tm_min == 0  &&
		     tm_first.tm_hour == 0 &&
		     tm_first.tm_mday == 0 &&
		     tm_first.tm_mon  == 0 &&
		     tm_first.tm_wday == 0)){
			printf("No SPI RTC\nCan Get Time from SPI RTC\n");
			return -1;  		
		}
#ifdef DEBUG_RTC	
		printf("\nSpi Time: %d:%d:%d",tm_first.tm_hour,tm_first.tm_min,tm_first.tm_sec);
		printf("\nSpi Date: %d-%d-%d day of week %d",tm_first.tm_mday,tm_first.tm_mon,tm_first.tm_year,tm_first.tm_wday);
		printf("\n");
		/*--Reading RTC iMX6--*/
		rtc_internal_get(&counter);
#endif
		utc_time = mktime (tm_first.tm_year,
				   tm_first.tm_mon,
				   tm_first.tm_mday,
				   tm_first.tm_hour,
				   tm_first.tm_min,
				   tm_first.tm_sec);
#ifdef DEBUG_RTC
		printf("\nUTC from Spi : %lu\n",utc_time);
#endif
	} else {

		/*--Date from external RTC is invalid - set default date to 1970-01-01 - 00:00:00 --*/
		utc_time = mktime (1970,// year
                                   1, 	// month
                                   1, 	// day
                                   0, 	// hour
                                   0, 	// min
                                   0); 	// sec
		err_set = rtc_set(&tm_default);
		if ( err_set != 0 ){
			printf("\nImpossible to set spi rtc time");
			return -1;
		}
	}	
	
	/*--Setting Time from SPI to iMX6--*/
	rtc_internal_set(utc_time);	
	printf("ready\n");
	return 0;

}

U_BOOT_CMD(
	rtc,	1,	1,	do_rtc,
	"RTC reader",
	"\nRead External SPI RTC and transfer time \nto internal iMX6 RTC\n"
);
