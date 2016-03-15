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

/* -------------------------------RTC iMX6--------------------------------- */
/* Register definitions */
#define SNVS_HPSR       0x14    /* HP Status Register */
#define SNVS_LPCR       0x38    /* LP Control Register */
#define SNVS_LPSR       0x4C    /* LP Status Register */
#define SNVS_LPSRTCMR   0x50    /* LP Secure Real Time Counter MSB Register */
#define SNVS_LPSRTCLR   0x54    /* LP Secure Real Time Counter LSB Register */
#define SNVS_LPTAR      0x58    /* LP Time Alarm Register */
#define SNVS_LPSMCMR    0x5C    /* LP Secure Monotonic Counter MSB Register */
#define SNVS_LPSMCLR    0x60    /* LP Secure Monotonic Counter LSB Register */
#define SNVS_LPPGDR     0x64    /* LP Power Glitch Detector Register */
#define SNVS_LPGPR      0x68    /* LP General Purpose Register */
#define CNTR_TO_SECS_SH 15	/* Shift to convert 47-bit counter to 32-bit raw second count */
/* ------------------------------------------------------------------------ */

/* Bit Definitions */
#define SNVS_HPSR_SSM_ST_MASK   0x00000F00
#define SNVS_HPSR_SSM_ST_SHIFT  8

#define SNVS_LPCR_SRTC_ENV      (1 << 0)
#define SNVS_LPCR_LPTA_EN       (1 << 1)
#define SNVS_LPCR_LPWUI_EN      (1 << 3)

#define SNVS_LPCR_ALL_INT_EN (SNVS_LPCR_LPTA_EN | SNVS_LPCR_LPWUI_EN)

#define SNVS_LPSR_LPTA          (1 << 0)

#define SNVS_LPPGDR_INIT        0x41736166



u32			utc_time;
u64			reg,reg_rtc_imx6_lb,reg_rtc_imx6_mb;
int			counter;


static inline void rtc_write_sync_lp(void)
{
        unsigned int i, count1, count2, count3;

        /* Wait for 3 CKIL cycles */
        for (i = 0; i < 3; i++) {

                /* TKT052983: Do consective reads of LSB of counter
                 * to ensure integrity
                 */
                do {
                        count1 = __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR);
                        count2 = __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR);
                } while (count1 != count2);

                /* Now wait until counter value changes */
                do {
                        do {
                                count2 = __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR);
                                count3 = __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR);
                        } while (count2 != count3);
                } while (count3 == count1);
        }
}

int rtc_internal_set(u32 time){

	int ret;
        u32 lp_cr;
        u64 old_time_47bit, new_time_47bit;
#ifdef DEBUG_RTC
	printf("\nSetting time to iMX6...");
#endif
        old_time_47bit = (((u64) (__raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCMR) &
                ((0x1 << CNTR_TO_SECS_SH) - 1)) << 32) |
                ((u64) __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR)));

        /* Disable RTC first */
        lp_cr = __raw_readl(SNVS_BASE_ADDR + SNVS_LPCR) & ~SNVS_LPCR_SRTC_ENV;
        __raw_writel(lp_cr,SNVS_BASE_ADDR + SNVS_LPCR);
        while (__raw_readl(SNVS_BASE_ADDR + SNVS_LPCR) & SNVS_LPCR_SRTC_ENV)
                ;

        /* Write 32-bit time to 47-bit timer, leaving 15 LSBs blank */
        __raw_writel(time << CNTR_TO_SECS_SH, SNVS_BASE_ADDR + SNVS_LPSRTCLR);
        __raw_writel(time >> (32 - CNTR_TO_SECS_SH), SNVS_BASE_ADDR + SNVS_LPSRTCMR);

        /* Enable RTC again */
        __raw_writel(lp_cr | SNVS_LPCR_SRTC_ENV, SNVS_BASE_ADDR + SNVS_LPCR);
        while (!(__raw_readl(SNVS_BASE_ADDR + SNVS_LPCR) & SNVS_LPCR_SRTC_ENV))
                ;

        rtc_write_sync_lp();

        new_time_47bit = (((u64) (__raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCMR) &
                ((0x1 << CNTR_TO_SECS_SH) - 1)) << 32) |
                ((u64) __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR)));
#ifdef DEBUG_RTC
       	printf("Done!\n"); 
#endif
	return 0;
}

int rtc_internal_get(u32 *counter){
#ifdef DEBUG_RTC	
	printf("\nRead RTC iMX6: ");
#endif
	reg_rtc_imx6_mb = readl(SNVS_BASE_ADDR + SNVS_LPSRTCMR);

	reg_rtc_imx6_mb <<= 32;

	reg_rtc_imx6_mb |= __raw_readl(SNVS_BASE_ADDR + SNVS_LPSRTCLR );

	*counter = (u32)( reg_rtc_imx6_mb >> CNTR_TO_SECS_SH );
#ifdef DEBUG_RTC	
	printf("%lu\n",*counter);	
#endif	
	return 0;	


}
void rtc_internal_reset(void){

	printf("\nFunction Reset Not Implemented\n");

}
        
