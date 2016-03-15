/*
 * Copyright 2011 Freescale Semiconductor, Inc. All Rights Reserved.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
 *
 */

#ifndef __ARCH_ARM_MACH_MX6_CCM_REGS_H__
#define __ARCH_ARM_MACH_MX6_CCM_REGS_H__

struct mxc_ccm_reg {
	u32 ccr;	/* 0x0000 */
	u32 ccdr;
	u32 csr;
	u32 ccsr;
	u32 cacrr;	/* 0x0010*/
	u32 cbcdr;
	u32 cbcmr;
	u32 cscmr1;
	u32 cscmr2;	/* 0x0020 */
	u32 cscdr1;
	u32 cs1cdr;
	u32 cs2cdr;
	u32 cdcdr;	/* 0x0030 */
	u32 chscdr;
	u32 cscdr2;
	u32 cscdr3;
	u32 cscdr4;	/* 0x0040 */
	u32 resv0;
	u32 cdhipr;
	u32 cdcr;
	u32 ctor;	/* 0x0050 */
	u32 clpcr;
	u32 cisr;
	u32 cimr;
	u32 ccosr;	/* 0x0060 */
	u32 cgpr;
	u32 CCGR0;
	u32 CCGR1;
	u32 CCGR2;	/* 0x0070 */
	u32 CCGR3;
	u32 CCGR4;
	u32 CCGR5;
	u32 CCGR6;	/* 0x0080 */
	u32 CCGR7;
	u32 cmeor;
	u32 resv[0xfdd];
	u32 analog_pll_sys;			/* 0x4000 */
	u32 analog_pll_sys_set;
	u32 analog_pll_sys_clr;
	u32 analog_pll_sys_tog;
	u32 analog_usb1_pll_480_ctrl;		/* 0x4010 */
	u32 analog_usb1_pll_480_ctrl_set;
	u32 analog_usb1_pll_480_ctrl_clr;
	u32 analog_usb1_pll_480_ctrl_tog;
	u32 analog_reserved0[4];
	u32 analog_pll_528;			/* 0x4030 */
	u32 analog_pll_528_set;
	u32 analog_pll_528_clr;
	u32 analog_pll_528_tog;
	u32 analog_pll_528_ss;			/* 0x4040 */
	u32 analog_reserved1[3];
	u32 analog_pll_528_num;			/* 0x4050 */
	u32 analog_reserved2[3];
	u32 analog_pll_528_denom;		/* 0x4060 */
	u32 analog_reserved3[3];
	u32 analog_pll_audio;			/* 0x4070 */
	u32 analog_pll_audio_set;
	u32 analog_pll_audio_clr;
	u32 analog_pll_audio_tog;
	u32 analog_pll_audio_num;		/* 0x4080*/
	u32 analog_reserved4[3];
	u32 analog_pll_audio_denom;		/* 0x4090 */
	u32 analog_reserved5[3];
	u32 analog_pll_video;			/* 0x40a0 */
	u32 analog_pll_video_set;
	u32 analog_pll_video_clr;
	u32 analog_pll_video_tog;
	u32 analog_pll_video_num;		/* 0x40b0 */
	u32 analog_reserved6[3];
	u32 analog_pll_vedio_denon;		/* 0x40c0 */
	u32 analog_reserved7[7];
	u32 analog_pll_enet;			/* 0x40e0 */
	u32 analog_pll_enet_set;
	u32 analog_pll_enet_clr;
	u32 analog_pll_enet_tog;
	u32 analog_pfd_480;			/* 0x40f0 */
	u32 analog_pfd_480_set;
	u32 analog_pfd_480_clr;
	u32 analog_pfd_480_tog;
	u32 analog_pfd_528;			/* 0x4100 */
	u32 analog_pfd_528_set;
	u32 analog_pfd_528_clr;
	u32 analog_pfd_528_tog;
};

#endif /*__ARCH_ARM_MACH_MX6_CCM_REGS_H__ */
