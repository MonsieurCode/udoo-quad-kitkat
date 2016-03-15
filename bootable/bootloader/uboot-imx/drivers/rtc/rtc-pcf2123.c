/*
 * Command for accessing SPI flash.
 *
 * Copyright (C) 2008 Atmel Corporation
 */
#include <common.h>
#include <command.h>
#include <spi_flash.h>

#include <asm/io.h>
#include <spi.h>
#include <rtc.h>
#include <linux/time.h>


#define MAX_SPI_BYTES 			12     /* Maximum number of bytes we can handle */
#define TIME				4
#define DATE				4
#define RESET				4
#define YEAR				2
#define OS_FLAG				2
#define DATE_AND_TIME			8

#define MAX_HZ 				1000000
#define SPI_MODE			SPI_CS_HIGH
#if defined (CONFIG_MX6Q_SECO_Q7) || defined (CONFIG_MX6DL_SECO_Q7) || defined (CONFIG_MX6S_SECO_Q7)
#define CS				3
#define BUS				0
#define GPIO_BA				GPIO2_BASE_ADDR
#define GPIO_NUMBER			17
#elif defined (CONFIG_MX6Q_SECO_UQ7) || defined (CONFIG_MX6DL_SECO_UQ7) || defined (CONFIG_MX6S_SECO_UQ7)
#define CS                              3
#define BUS                             2
#define GPIO_BA                         GPIO4_BASE_ADDR
#define GPIO_NUMBER                     24
#elif defined (CONFIG_MX6Q_SECO_uSBC) || defined (CONFIG_MX6DL_SECO_uSBC) || defined (CONFIG_MX6S_SECO_uSBC)
#define CS                              3
#define BUS                             2
#define GPIO_BA                         GPIO4_BASE_ADDR
#define GPIO_NUMBER                     24
#endif
#define CMD_READ			0x03
//#define LEN				8
//#define BITLEN				80

#define PCF2123_REG_CTRL1       (0x00)  /* Control Register 1 */
#define PCF2123_REG_CTRL2       (0x01)  /* Control Register 2 */
#define PCF2123_REG_SC          (0x02)  /* datetime */
#define PCF2123_REG_MN          (0x03)
#define PCF2123_REG_HR          (0x04)
#define PCF2123_REG_DM          (0x05)
#define PCF2123_REG_DW          (0x06)
#define PCF2123_REG_MO          (0x07)
#define PCF2123_REG_YR          (0x08)

#define PCF2123_SUBADDR         (1 << 4)
#define PCF2123_WRITE           ((0 << 7) | PCF2123_SUBADDR)
#define PCF2123_READ            ((1 << 7) | PCF2123_SUBADDR)

unsigned char           time[TIME];
unsigned char 		date[DATE];
unsigned char		year[YEAR];
u64			reg_imx6;

static unsigned bcd2bin (uchar n)
{
        return ((((n >> 4) & 0x0F) * 10) + (n & 0x0F));
}


static void spi_cs3_direction_output(void){

	/* Set as output */
        reg_imx6 = readl(GPIO_BA + GPIO_GDIR);
        reg_imx6 |= (1 << GPIO_NUMBER);
        writel(reg_imx6, GPIO_BA + GPIO_GDIR);

}

static void spi_cs3_low(void){

	/* Set Low */
        reg_imx6 = readl(GPIO_BA + GPIO_DR);
        reg_imx6 &= ~(1 << GPIO_NUMBER);
        writel(reg_imx6, GPIO_BA + GPIO_DR);

}


static void spi_cs3_high(void){

 	/* Set High */
        reg_imx6 = readl(GPIO_BA + GPIO_DR);
        reg_imx6 |= (1 << GPIO_NUMBER);
        writel(reg_imx6, GPIO_BA + GPIO_DR);


}

int rtc_set(struct rtc_time *tm)
{
	struct spi_slave *spi;
        int     j,ret;
        unsigned char cmd[MAX_SPI_BYTES],time[7];
	
	spi = spi_setup_slave (BUS, CS, MAX_HZ, SPI_MODE);
        if(!spi){
                printf("Error in setup slave!");
                return -1;
        }

        ret = spi_claim_bus(spi);
        if( ret < 0 ){
                printf("Error Claiming Bus!\n");
                printf("Release Bus and Claiming Again");
                spi_release_bus(spi);
                printf("\nClaiming Again");
                ret = spi_claim_bus(spi);
                if(!ret){
                        printf("\nError Claiming Bus!\n");
                        return ret;
                }
        }

        /* Set Direction */
        spi_cs3_direction_output();
	/* Set Low */
        spi_cs3_low();
        /*WRITE TIME OPERATION*/

	cmd[0] = tm->tm_hour;
        cmd[1] = tm->tm_min;
        cmd[2] = tm->tm_sec;
	cmd[3] = PCF2123_WRITE | PCF2123_REG_SC;
        cmd[4] = tm->tm_year;
        cmd[5] = tm->tm_mon;
        cmd[6] = tm->tm_wday;
	cmd[7] = tm->tm_mday;
        for (j = 8; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        for (j = 0; j < DATE_AND_TIME; j++){
        time[j] = 0x0;
        }

        /* Set High */
        spi_cs3_high();

                if(spi_xfer(spi, DATE_AND_TIME*8, cmd, time,
                                 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
                        printf("Error with the SPI transaction.\n");
                        return -1;
                }

        /* Set Low */
        spi_cs3_low();
	spi_release_bus(spi);
        spi_free_slave(spi);

	return 0;
}

int rtc_get(struct rtc_time *tm){

 	struct spi_slave *spi;
        int     j,ret;
        unsigned char cmd[MAX_SPI_BYTES],time[7];
        int counter;

	spi = spi_setup_slave (BUS, CS, MAX_HZ, SPI_MODE);
	if(!spi){
		printf("Error in setup slave!");
		return -1;
	}
	
	ret = spi_claim_bus(spi);
	if( ret < 0 ){
		printf("Error Claiming Bus!\n");
        	printf("Release Bus and Claiming Again");
		spi_release_bus(spi);
		printf("\nClaiming Again");
		ret = spi_claim_bus(spi);
		if(!ret){
			printf("\nError Claiming Bus!\n");
			return ret;
		}
	}

	/* Set Direction */
	spi_cs3_direction_output();

	/*READ TIME OPERATION*/	

	cmd[0] = 0x00;
        cmd[1] = 0x00;
	cmd[2] = 0x00;
	cmd[3] = PCF2123_READ | PCF2123_REG_SC;
	
	for (j = 4; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        for (j = 0; j < TIME; j++){
        time[j] = 0x0;
        }		
	
	/* Set High */
        spi_cs3_high();

		if(spi_xfer(spi, TIME*8, cmd, time,
				 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
			printf("Error with the SPI transaction.\n");
			return -1;
		}
	
	/* Set Low */
	spi_cs3_low();	

		tm->tm_sec     = bcd2bin(time[2] & 0x7f);
                tm->tm_min     = bcd2bin(time[1] & 0x7f);
                tm->tm_hour    = bcd2bin(time[0] & 0x3f);

	/*READ DATE OPERATION*/

	for (j = 0; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        cmd[0] = 0x00;
	cmd[1] = 0x00;
	cmd[2] = 0x00;
	cmd[3] = PCF2123_READ | PCF2123_REG_DM;
        
	for (j = 4; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

	for (j = 0; j < DATE; j++){
        date[j] = 0x0;
        }

        /* Set High */
        spi_cs3_high();

                if(spi_xfer(spi, DATE*8, cmd, date,
                                 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
                        printf("Error with the SPI transaction.\n");
                        return -1;
                }

        /* Set Low */
        spi_cs3_low();

	/*READ YEAR OPERATION*/

        for (j = 0; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        cmd[0] = 0x00;
        cmd[1] = PCF2123_READ | PCF2123_REG_YR;
        for (j = 2; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        for (j = 0; j < YEAR; j++){
        year[j] = 0x0;
        }

        /* Set High */
        spi_cs3_high();

                if(spi_xfer(spi, YEAR*8, cmd, year,
                                 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
                        printf("Error with the SPI transaction.\n");
                        return -1;
                }

        /* Set Low */
        spi_cs3_low();
	spi_release_bus(spi);
        spi_free_slave(spi);

		tm->tm_mday    = bcd2bin(date[2] & 0x3f);
		tm->tm_wday    = date[1] & 0x07;
		tm->tm_mon     = bcd2bin(date[0] & 0x1f);
		tm->tm_year    = bcd2bin(year[0]);
		if (tm->tm_year < 38)
        	      	tm->tm_year += 2000;
		else
			tm->tm_year += 1900;
        	 tm->tm_yday = 0;
               	 tm->tm_isdst = 0;
	
	return 0;	


}
void rtc_reset(void){

	struct spi_slave *spi;
        int     j,ret;
        unsigned char cmd[MAX_SPI_BYTES],reset[RESET];
	
	spi = spi_setup_slave (BUS, CS, MAX_HZ, SPI_MODE);
	
	if(!spi){
		printf("Error in setup slave!");
		return;
	}
	
	//printf("\nSlave correctly Set\n");

	ret = spi_claim_bus(spi);
	if( ret < 0 ){
		printf("Error Claiming Bus!\n");
        	printf("Release Bus and Claiming Again");
		spi_release_bus(spi);
		printf("\nClaiming Again");
		ret = spi_claim_bus(spi);
		if(!ret){
			printf("\nError Claiming Bus!\n");
			return;
		}
	}

	/* Set Direction */
	spi_cs3_direction_output();

        /* Set Low */
        spi_cs3_low();	
	
	/*SOFTWARE RESET*/

        cmd[0] = 0x58;
	cmd[1] = PCF2123_WRITE | PCF2123_REG_CTRL1;
        for (j = 2; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        for (j = 0; j < RESET; j++){
        reset[j] = 0x0;
        }	
	
	 /* Set High */
        spi_cs3_high();

                if(spi_xfer(spi, 2*8, cmd, reset,
                                 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
                        printf("Error with the SPI transaction.\n");
                        return;
                }
        
	/* Set Low */
        spi_cs3_low();	
	spi_release_bus(spi);
        spi_free_slave(spi);


}

int rtc_read_os_flag(int *os_flag){

 	struct spi_slave *spi;
        int     j,ret;
        unsigned char cmd[MAX_SPI_BYTES];
	unsigned char ctrl_os_flag[OS_FLAG];

	spi = spi_setup_slave (BUS, CS, MAX_HZ, SPI_MODE);
	if(!spi){
		printf("Error in setup slave!");
		return -1;
	}
	
	ret = spi_claim_bus(spi);
	if( ret < 0 ){
		printf("Error Claiming Bus!\n");
        	printf("Release Bus and Claiming Again");
		spi_release_bus(spi);
		printf("\nClaiming Again");
		ret = spi_claim_bus(spi);
		if(!ret){
			printf("\nError Claiming Bus!\n");
			return ret;
		}
	}

	/* Set Direction */
	spi_cs3_direction_output();

	        /* Set Low */
        spi_cs3_low();

	/*READ OS FLAG */

        for (j = 0; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        cmd[0] = 0x00;
        cmd[1] = PCF2123_READ | PCF2123_REG_SC;
        for (j = 2; j < MAX_SPI_BYTES; j++){
        cmd[j] = 0x0;
        }

        for (j = 0; j < OS_FLAG; j++){
        ctrl_os_flag[j] = 0x0;
        }

        /* Set High */
        spi_cs3_high();

                if(spi_xfer(spi, OS_FLAG*8, cmd, ctrl_os_flag,
                                 SPI_XFER_BEGIN | SPI_XFER_END) != 0) {
                        printf("Error with the SPI transaction.\n");
                        return -1;
                }

        /* Set Low */
        spi_cs3_low();
	
	spi_release_bus(spi);
        spi_free_slave(spi);
	
	*os_flag = (ctrl_os_flag[0] >> 7);	

	return 0;	



}
        
