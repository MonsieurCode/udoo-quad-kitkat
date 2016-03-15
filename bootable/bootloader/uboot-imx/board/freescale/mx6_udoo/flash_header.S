/*
 * Copyright (C) 2011 Freescale Semiconductor, Inc.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston,
 * MA 02111-1307 USA
 */

#include <config.h>
#include <asm/arch/mx6.h>

#ifdef	CONFIG_FLASH_HEADER
#ifndef CONFIG_FLASH_HEADER_OFFSET
# error "Must define the offset of flash header"
#endif

#define CPU_2_BE_32(l) \
       ((((l) & 0x000000FF) << 24) | \
	(((l) & 0x0000FF00) << 8)  | \
	(((l) & 0x00FF0000) >> 8)  | \
	(((l) & 0xFF000000) >> 24))

#define MXC_DCD_ITEM(i, addr, val)   \
dcd_node_##i:                        \
        .word CPU_2_BE_32(addr) ;     \
        .word CPU_2_BE_32(val)  ;     \

.section ".text.flasheader", "x"
	b	_start
	.org	CONFIG_FLASH_HEADER_OFFSET

ivt_header:       .word 0x402000D1 // Tag=0xD1, Len=0x0020, Ver=0x40 
app_code_jump_v:  .word _start
reserv1:          .word 0x0
dcd_ptr:          .word dcd_hdr
boot_data_ptr:	  .word boot_data
self_ptr:         .word ivt_header
#ifdef CONFIG_SECURE_BOOT
app_code_csf:     .word __hab_data
#else
app_code_csf:     .word 0x0
#endif
reserv2:          .word 0x0

boot_data:        .word TEXT_BASE
#ifdef CONFIG_SECURE_BOOT
image_len:        .word __hab_data_end - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
#else
image_len:        .word _end_of_copy  - TEXT_BASE + CONFIG_FLASH_HEADER_OFFSET
#endif
plugin:           .word 0x0

/* CONFIG_DDR_SIZE:     
2 ->  1Giga, bus size 64, active CS = 1 (256Mx4);
3 ->  2Giga, bus size 64, active CS = 1 (512Mx4);
*/

/* CONFIG_DDR_TYPE:     
1 ->  LDDR3
*/

#define DDR_SIZE_1GB_256Mx4		2
#define DDR_SIZE_2GB_512Mx4		3


#if defined(CONFIG_MX6Q_UDOO)

/********************************************************************************
 ********************************************************************************
 **                              iMX6 QUAD                                     **	
 ********************************************************************************
 ********************************************************************************/
	
	dcd_hdr:          .word 0x40C802D2 // Tag=0xD2, Len=88*8 + 4 + 4=02C8, Ver=0x40 
	write_dcd_cmd:    .word 0x04C402CC // Tag=0xCC, Len=88*8 + 4 =02C4, Param=0x04 

	// DCD 
	MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x5a8, 0x00000028)
	MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x5b0, 0x00000028)
	MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x524, 0x00000028)
	MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x51c, 0x00000028)

	MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x518, 0x00000028)
	MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x50c, 0x00000028)
	MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x5b8, 0x00000028)
	MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x5c0, 0x00000028)

	MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x5ac, 0x00000028)
	MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x5b4, 0x00000028)
	MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x528, 0x00000028)
	MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x520, 0x00000028)

	MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x514, 0x00000028)
	MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x510, 0x00000028)
	MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x5bc, 0x00000028)
	MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x5c4, 0x00000028)

	MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x56c, 0x00000028)
	MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x578, 0x00000028)
	MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x588, 0x00000028)
	MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x594, 0x00000028)
	
	MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x57c, 0x00000028)
	MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x590, 0x00003000)
	MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x598, 0x00003000)
	MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)
	
	MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x59c, 0x00000028)
	MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x5a0, 0x00000028)
	MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x784, 0x00000028)
	MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x788, 0x00000028)
	
	MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x794, 0x00000028)
	MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x79c, 0x00000028)
	MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x7a0, 0x00000028)
	MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x7a4, 0x00000028)
	
	MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x7a8, 0x00000028)
	MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x748, 0x00000028)
	MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x74c, 0x00000028)
	MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x750, 0x00020000)
	
	MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x758, 0x00000000)
	MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x774, 0x00020000)
	MXC_DCD_ITEM(39, IOMUXC_BASE_ADDR + 0x78c, 0x00000028)
	MXC_DCD_ITEM(40, IOMUXC_BASE_ADDR + 0x798, 0x000C0000)
	
	//DDR3 SETTINGS
	//Read Data Bit Delay
	MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x81c, 0x66666666)
	MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x820, 0x66666666)
	MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x824, 0x66666666)
	MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x828, 0x66666666)
	MXC_DCD_ITEM(45, MMDC_P1_BASE_ADDR + 0x81c, 0x66666666)
	MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x820, 0x66666666)
	MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x824, 0x66666666)
	MXC_DCD_ITEM(48, MMDC_P1_BASE_ADDR + 0x828, 0x66666666)

	//MMDC init:
	//in DDR3, 64-bit mode, only MMDC0 is initiated:
	MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)
	MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
	
	MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x00c, 0x54597955)

	MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x010, 0xFF328F64)
	MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)
	MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x018, 0x00001740) 

	MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
	MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
	
	MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x030, 0x00591023)

	#if (CONFIG_DDR_SIZE == DDR_SIZE_1GB_256Mx4)
	MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x040, 0x00000027) //CS0_END = 1280MB in step da 256Mb -> [(2304*8/256) - 1] 
	MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0x831A0000) //SDE_1=0; ROW=3; BL=1; DSIZ=2 -> 64 bit 
	#endif

	#if (CONFIG_DDR_SIZE == DDR_SIZE_2GB_512Mx4)
	MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x040, 0x00000047) //CS0_END = 2304MB in step da 256Mb -> [(2304*8/256) - 1] 
	MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x000, 0x841A0000) //SDE_1=0; ROW=4; BL=1; DSIZ=2 -> 64 bit 
	#endif
	
	//Initialize DDR3 on CS_0  
	//MR2
	MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x01c, 0x04088032)//write 0x0408 to MR2 bank_0
	//MR3
	MXC_DCD_ITEM(61, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
	//MR1
	MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
	//MR0
	MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)
	//ZQ - Calibration
	MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)
	//ZQ
	MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x800, 0xA1390003)

	MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x020, 0x00005800)
	MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x818, 0x00011117)
	MXC_DCD_ITEM(68, MMDC_P1_BASE_ADDR + 0x818, 0x00011117)
	
	//DQS gating, read delay, write delay calibration values
	//value for DDR3 calidration
	
	//Read DQS Gating calibration
	MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x83c, 0x440A0415)
	MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x840, 0x03690363)
	MXC_DCD_ITEM(71, MMDC_P1_BASE_ADDR + 0x83c, 0x035D0363)
	MXC_DCD_ITEM(72, MMDC_P1_BASE_ADDR + 0x840, 0x03290308)
	//Read calibration
	MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x848, 0x4B2A4141)
	MXC_DCD_ITEM(74, MMDC_P1_BASE_ADDR + 0x848, 0x442A3249)
	//write calibrttion
	MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x850, 0x40454841)
	MXC_DCD_ITEM(76, MMDC_P1_BASE_ADDR + 0x850, 0x49334B3F)

	//write leveling
	MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x80c, 0x00350035)
	MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
	MXC_DCD_ITEM(79, MMDC_P1_BASE_ADDR + 0x80c, 0x00010001)
	MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x810, 0x00010001)
	
	MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
	MXC_DCD_ITEM(82, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)

	MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)
	MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)
	MXC_DCD_ITEM(85, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

	/* enable AXI cache for VDOA/VPU/IPU */
	MXC_DCD_ITEM(86, IOMUXC_BASE_ADDR + 0x010, 0xf00000ff)
	/* set IPU AXI-id0 Qos=0xf(bypass) AXI-id1 Qos=0x7 */
	MXC_DCD_ITEM(87, IOMUXC_BASE_ADDR + 0x018, 0x007f007f)
	MXC_DCD_ITEM(88, IOMUXC_BASE_ADDR + 0x01c, 0x007f007f)
#endif	

#if defined(CONFIG_MX6DL_UDOO)
/********************************************************************************
 ********************************************************************************
 **                     iMX6 DUAL                                              **	
 ********************************************************************************
 ********************************************************************************/
	
	dcd_hdr:          .word 0x40A002D2 // Tag=0xD2, Len=83*8 + 4 + 4=02A0, Ver=0x40 
	write_dcd_cmd:    .word 0x049C02CC // Tag=0xCC, Len=83*8 + 4 =029C, Param=0x04

	//IOMUXC_BASE_ADDR  = 0x20e0000
	//DDR IO TYPE
	MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x774, 0x000c0000)
	MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x754, 0x00000000)
	//Clock 
	MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x4ac, 0x00000028)
	MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x4b0, 0x00000028)
	//Address
	MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x464, 0x00000028)
	MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x490, 0x00000028)
	MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x74c, 0x00000028)
	//Control
	MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x494, 0x00000028)
	MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x4a0, 0x00000000)
	MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x4b4, 0x00000028)
	MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x4b8, 0x00000028)
	MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x76c, 0x00000028)
	//Data Strobe
	MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x750, 0x00020000)
	MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x4bc, 0x00000028)
	MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x4c0, 0x00000028)
	MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x4c4, 0x00000028)
	MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x4c8, 0x00000028)
	MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x4cc, 0x00000028)
	MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x4d0, 0x00000028)
	MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x4d4, 0x00000028)
	MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x4d8, 0x00000028)

	//DATA
	MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x760, 0x00020000)
	MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x764, 0x00000028)
	MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x770, 0x00000028)
	MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x778, 0x00000028)
	MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x77c, 0x00000028)
	MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x780, 0x00000028)
	MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x784, 0x00000028)
	MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x78c, 0x00000028)
	MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x748, 0x00000028)

	MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x470, 0x00000028)
	MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x474, 0x00000028)
	MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x478, 0x00000028)
	MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x47c, 0x00000028)
	MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x480, 0x00000028)
	MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x484, 0x00000028)
	MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x488, 0x00000028)
	MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x48c, 0x00000028)

	//MMDC_P0_BASE_ADDR = 0x021b0000
	//MMDC_P1_BASE_ADDR = 0x021b4000
	//Calibrations
	//ZQ
	MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x800, 0xa1390003)

	#if (CONFIG_DDR_SIZE == DDR_SIZE_2GB_512Mx4)
	//=============================================================================
	// Calibration setup 
	//=============================================================================**/
		//write leveling
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
		MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F0001)
		MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)

		//DQS gating, read delay, write delay calibration values
		// value for DDR3 calidration on T1.2 CAL. A23
		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x4202017F)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0172017B)
		MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x421F0220)
		MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x02140228)
		//Read calibration
		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x4147494C)
		MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x4A4C4E48)
		//write calibrttion
		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x3F3D3F36)
		MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x34373A32)

		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
		MXC_DCD_ITEM(56, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

		MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 64-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)
		MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x008, 0x00333040)
		MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x00c, 0x676B52F3) 
		MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xB66E8B63)
		MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
		MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x006B1023)

		MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x040, 0x00000047) //CS0_END = 2304MB (2048 + 256) in step da 256Mb -> [(2304*8/256) - 1] 
		MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x841A0000) //SDE_1=0; ROW=; BL=1; DSIZ=2 -> 64 bit 

		//Initialize DDR3 on CS0
		MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
		MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
		//ZQ - Calibration bank_0
		MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

		MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

		MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
		MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)

		MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
		MXC_DCD_ITEM(82, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
		MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

	//=============================================================================
	// Configuration LDDR SIZE 3 END
	//=============================================================================

	#elif (CONFIG_DDR_SIZE == DDR_SIZE_1GB_256Mx4)
	//=============================================================================
	// Calibration setup 
	//=============================================================================**/
		//write leveling
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x002F0038)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001f)
		MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001f)
		MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001f)
		//DQS gating, read delay, write delay calibration values
		//based on calibration compare of 0x00ffff00
		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x425C0251)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x021B021E)
		MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x021B021E)
		MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x01730200)

		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x45474C45)
		MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x44464744)

		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x3F3F3336)
		MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x32383630)

		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
		MXC_DCD_ITEM(56, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

		MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 64-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)
		MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x008, 0x00333040)
		MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x00c, 0x3F4352F3) 
		MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xB66D8B63)
		MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
		MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x00431023)

		MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x040, 0x00000027) //CS0_END = 1280MB (1024 + 256) in step da 256Mb -> [(1280*8/256) - 1]
		MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x831A0000) //SDE_1=0; ROW=3; BL=1; DSIZ=2 -> 64 bit 

		//Initialize DDR3 on CS0
		MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
		MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
		//ZQ - Calibration bank_0
		MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

		MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

		MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
		MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)

		MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
		MXC_DCD_ITEM(82, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
		MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

	//=============================================================================
	// Configuration LDDR TYPE 2 END
	//=============================================================================
	#endif

#endif
#endif
