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
		0 ->  512M,  bus size 32, active CS = 1 (256Mx2);
		1 ->  1Giga, bus size 32, active CS = 1 (512Mx2);
		2 ->  1Giga, bus size 64, active CS = 1 (256Mx4);
		3 ->  2Giga, bus size 64, active CS = 1 (512Mx4);
		4 ->  4Giga, bus size 64, active CS = 2 (512Mx8);
*/

#if (defined(CONFIG_MX6Q_SECO_Q7) || defined(CONFIG_MX6Q_SECO_UQ7) || defined(CONFIG_MX6Q_SECO_uSBC))

/********************************************************************************
 ********************************************************************************
 **                              iMX6 QUAD/DUAL                                **	
 ********************************************************************************
 ********************************************************************************/
	
	#if ((CONFIG_DDR_SIZE == 0) && defined(CONFIG_DDR_32BIT))
	//=============================================================================
	// Configuration LDDR SIZE 0
	//=============================================================================
		dcd_hdr:          .word 0x40F801D2 // Tag=0xD2, Len=62*8 + 4 + 4=01F8, Ver=0x40 
		write_dcd_cmd:    .word 0x04F401CC // Tag=0xCC, Len=62*8 + 4=01F4, Param=0x0

		//DDR IO TYPE
		MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x798, 0x000C0000)
		MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x758, 0x00000000)

		//CLOCK
		MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x588, 0x00000028)
		MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x594, 0x00000028)

		//ADDRESS
		MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x56c, 0x00000028)
		MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x578, 0x00000028)
		MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x74c, 0x00000028)

		//CONTROL
		MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x57c, 0x00000028)
		MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)
		MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x59c, 0x00000028)
		MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x5a0, 0x00000028)
		MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x78c, 0x00000028)

		//DATA STROBE
		MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x750, 0x00020000)
		MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x5a8, 0x00000028)
		MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x5b0, 0x00000028)
		MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x524, 0x00000028)
		MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x51c, 0x00000028)

		//DATA
		MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x774, 0x00020000)
		MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x784, 0x00000028)
		MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x788, 0x00000028)
		MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x794, 0x00000028)
		MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x79c, 0x00000028)

		MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x5ac, 0x00000028)
		MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x5b4, 0x00000028)
		MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x528, 0x00000028)
		MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x520, 0x00000028)

		//ZQ
		MXC_DCD_ITEM(27, MMDC_P0_BASE_ADDR + 0x800, 0xA1390003) // bank_0
		
		//=============================================================================
		// Calibration setup 
		//=============================================================================		
		#ifdef UQSEVEN
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
			
	
			//DQS gating, read delay, write delay calibration values
			// value for DDR3 calidration on T1.2 CAL. A22
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
			//Read calibration
			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
			//write calibrttion
			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)

		#elif QSEVEN
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

	
			//DQS gating, read delay, write delay calibration values
			// value for DDR3 calidration on T1.2 CAL. A22
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
			//Read calibration
			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
			//write calibrttion
			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
		#elif uSBC
			 //write leveling
                        MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                        MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)


                        //DQS gating, read delay, write delay calibration values
                        // value for DDR3 calidration on T1.2 CAL. A22
                        MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
                        MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
                        //Read calibration
                        MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
                        //write calibrttion
                        MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
		#endif

		//DDR3 SETTINGS
		//Read Data Bit Delay
		MXC_DCD_ITEM(34, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(35, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(36, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(37, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

		// Complete calibration by forced measurement:
		MXC_DCD_ITEM(38, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 64-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x00c, 0x54597955)
		MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x010, 0xFF328F64)
		MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
		MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x030, 0x00591023)

		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x040, 0x00000017) //CS0_END =768MB (512 + 256)  in step da 256Mb -> [(2304*8/256) - 1] 
		MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x000, 0x83190000) //SDE_1=0; ROW=3; BL=1; DSIZ=1 -> 32 bit 

		//Initialize DDR3 on CS_0 and CS_1
		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x01c, 0x02088032)//write 0x0408 to MR2 bank_0
		MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)//write 0x0940 to MR0 bank_0 (Burst Type=1 (Interlived))
		//ZQ - Calibration
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040) // bank_0
	
		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

		MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x818, 0x00022227) // bank_0
	
		MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)

		MXC_DCD_ITEM(58, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)

		MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)
	
		// enable AXI cache for VDOA/VPU/IPU
		MXC_DCD_ITEM(60, IOMUXC_BASE_ADDR + 0x010, 0xf00000ff)
		// set IPU AXI-id0 Qos=0xf(bypass) AXI-id1 Qos=0x7
		MXC_DCD_ITEM(61, IOMUXC_BASE_ADDR + 0x018, 0x007f007f)
		MXC_DCD_ITEM(62, IOMUXC_BASE_ADDR + 0x01c, 0x007f007f)
		
	//=============================================================================
	// Configuration LDDR SIZE 0 END
	//=============================================================================

	#elif ( CONFIG_DDR_SIZE > 1)

		#if (CONFIG_DDR_SIZE == 4)
			dcd_hdr:          .word 0x40E002D2 // Tag=0xD2, Len=91*8 + 4 + 4=02E0, Ver=0x40 
			write_dcd_cmd:    .word 0x04DC02CC // Tag=0xCC, Len=91*8 + 4=02DC, Param=0x04 
		#elif ((CONFIG_DDR_SIZE == 2) || (CONFIG_DDR_SIZE == 3))
			dcd_hdr:          .word 0x40B802D2 // Tag=0xD2, Len=86*8 + 4 + 4=02B8, Ver=0x40 
			write_dcd_cmd:    .word 0x04B402CC // Tag=0xCC, Len=86*8 + 4 =02B4, Param=0x04
		#endif

		//DDR IO TYPE
		MXC_DCD_ITEM(1, IOMUXC_BASE_ADDR + 0x798, 0x000C0000)
		MXC_DCD_ITEM(2, IOMUXC_BASE_ADDR + 0x758, 0x00000000)

		//CLOCK
		MXC_DCD_ITEM(3, IOMUXC_BASE_ADDR + 0x588, 0x00000028)
		MXC_DCD_ITEM(4, IOMUXC_BASE_ADDR + 0x594, 0x00000028)

		//ADDRESS
		MXC_DCD_ITEM(5, IOMUXC_BASE_ADDR + 0x56c, 0x00000028)
		MXC_DCD_ITEM(6, IOMUXC_BASE_ADDR + 0x578, 0x00000028)
		MXC_DCD_ITEM(7, IOMUXC_BASE_ADDR + 0x74c, 0x00000028)

		//CONTROL
		MXC_DCD_ITEM(8, IOMUXC_BASE_ADDR + 0x57c, 0x00000028)
		MXC_DCD_ITEM(9, IOMUXC_BASE_ADDR + 0x58c, 0x00000000)
		MXC_DCD_ITEM(10, IOMUXC_BASE_ADDR + 0x59c, 0x00000028)
		MXC_DCD_ITEM(11, IOMUXC_BASE_ADDR + 0x5a0, 0x00000028)
		MXC_DCD_ITEM(12, IOMUXC_BASE_ADDR + 0x78c, 0x00000030)

		//DATA STROBE
		MXC_DCD_ITEM(13, IOMUXC_BASE_ADDR + 0x750, 0x00020000)
		MXC_DCD_ITEM(14, IOMUXC_BASE_ADDR + 0x5a8, 0x00000028)
		MXC_DCD_ITEM(15, IOMUXC_BASE_ADDR + 0x5b0, 0x00000028)
		MXC_DCD_ITEM(16, IOMUXC_BASE_ADDR + 0x524, 0x00000028)
		MXC_DCD_ITEM(17, IOMUXC_BASE_ADDR + 0x51c, 0x00000028)
		MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x518, 0x00000028)
		MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x50c, 0x00000028)
		MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x5b8, 0x00000028)
		MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x5c0, 0x00000028)

		//DATA
		MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x774, 0x00020000)
		MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x784, 0x00000028)
		MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x788, 0x00000028)
		MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x794, 0x00000028)
		MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x79c, 0x00000028)
		MXC_DCD_ITEM(27, IOMUXC_BASE_ADDR + 0x7a0, 0x00000028)
		MXC_DCD_ITEM(28, IOMUXC_BASE_ADDR + 0x7a4, 0x00000028)
		MXC_DCD_ITEM(29, IOMUXC_BASE_ADDR + 0x7a8, 0x00000028)
		MXC_DCD_ITEM(30, IOMUXC_BASE_ADDR + 0x748, 0x00000028)

		MXC_DCD_ITEM(31, IOMUXC_BASE_ADDR + 0x5ac, 0x00000028)
		MXC_DCD_ITEM(32, IOMUXC_BASE_ADDR + 0x5b4, 0x00000028)
		MXC_DCD_ITEM(33, IOMUXC_BASE_ADDR + 0x528, 0x00000028)
		MXC_DCD_ITEM(34, IOMUXC_BASE_ADDR + 0x520, 0x00000028)
		MXC_DCD_ITEM(35, IOMUXC_BASE_ADDR + 0x514, 0x00000028)
		MXC_DCD_ITEM(36, IOMUXC_BASE_ADDR + 0x510, 0x00000028)
		MXC_DCD_ITEM(37, IOMUXC_BASE_ADDR + 0x5bc, 0x00000028)
		MXC_DCD_ITEM(38, IOMUXC_BASE_ADDR + 0x5c4, 0x00000028)

		//ZQ
		MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x800, 0xA1390003) // bank_0

		#if (CONFIG_DDR_SIZE == 4)
			//=============================================================================
			// Calibration setup 
			//=============================================================================
		
			// value for DDR3 calidration on T1.2 CAL. A22
			//write leveling
			MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
			MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F0001)
			MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
		
			//DQS gating, read delay, write delay calibration values
			MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
			MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
			MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433F0340)
			MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x0345031C)
			//Read calibration
			MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
			MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40372F45)
			//write calibrttion
			MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
			MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x4731473C)
				
		
			//DDR3 SETTINGS
			//Read Data Bit Delay
			MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
			MXC_DCD_ITEM(56, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

			// Complete calibration by forced measurement:
			MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
			MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
			//=============================================================================
			// Calibration setup end
			//=============================================================================

			//MMDC init:
			//in DDR3, 64-bit mode, only MMDC0 is initiated:
			MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)
			MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
			MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x00c, 0x898E7955)
			MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xFF328F64)
			MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

			MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
			MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
			MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x008E1023)

			MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x040, 0x00000047) //CS0_END = 2304MB in step da 256Mb -> [(2304*8/256) - 1] 
			MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0xC41A0000) //SDE_1=1; ROW=4; BL=1; DSIZ=2 -> 64 bit 

			//Initialize DDR3 on CS_0 and CS_1
			MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02088032)//write 0x0408 to MR2 bank_0
			MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
			MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
			MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)//write 0x0940 to MR0 bank_0 (Burst Type=1 (Interlived))
			//ZQ - Calibration
			MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040) // bank_0
		

			MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x01c, 0x0208803A)//write 0x0408 to MR2 bank_1
			MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803B)//write 0x0000 to MR3 bank_1
			MXC_DCD_ITEM(80, MMDC_P0_BASE_ADDR + 0x01c, 0x00048039)//write 0x0004 to MR1 bank_1
			MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x01c, 0x09408038)//write 0x0940 to MR0 bank_1 (Burst Type=1 (Interlived))
			//ZQ - Calibratio
			MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048) // bank_1

			MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

			MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x818, 0x00022227) // bank_0
			MXC_DCD_ITEM(85, MMDC_P1_BASE_ADDR + 0x818, 0x00022227) // bank_1
		
			MXC_DCD_ITEM(86, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)

			MXC_DCD_ITEM(87, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)

			MXC_DCD_ITEM(88, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)
		
			// enable AXI cache for VDOA/VPU/IPU
			MXC_DCD_ITEM(89, IOMUXC_BASE_ADDR + 0x010, 0xf00000ff)
			// set IPU AXI-id0 Qos=0xf(bypass) AXI-id1 Qos=0x7
			MXC_DCD_ITEM(90, IOMUXC_BASE_ADDR + 0x018, 0x007f007f)
			MXC_DCD_ITEM(91, IOMUXC_BASE_ADDR + 0x01c, 0x007f007f)

		//=============================================================================
		// Configuration LDDR SIZE 4 END
		//=============================================================================

		#elif (CONFIG_DDR_SIZE == 3)
			//=============================================================================
			// Calibration setup 
			//=============================================================================		
			#ifdef UQSEVEN
				// value for DDR3 calidration on T1.2 CAL. A22				
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F0001)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
		
				//DQS gating, read delay, write delay calibration values
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433F0340)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x0345031C)
				//Read calibration
				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40372F45)
				//write calibrttion
				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x4731473C)
			#elif QSEVEN
				// value for DDR3 calidration on T1.2 CAL. A27				
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
				
				//DQS gating, read delay, write delay calibration values
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x432C0332)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x03380335)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433A0342)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x033F0323)
				//Read calibration
				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x48414146)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40403648)
				//write calibrttion
				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x40424744)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x463F4A3D)
			#elif uSBC
				 // value for DDR3 calidration on T1.2 CAL. A22
                                //write leveling
                                MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x002D0031)
                                MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x00390033)
                                MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x00140029)
                                MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x000E001F)

                                //DQS gating, read delay, write delay calibration values
                                MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x433C0350)
                                MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x03380334)
                                MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x43340338)
                                MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x032C0304)
                                //Read calibration
                                MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x40343238)
                                MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x36382E3A)
                                //write calibrttion
                                MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x383A4238)
                                MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x4030443E)	
			#endif

			//DDR3 SETTINGS
			//Read Data Bit Delay
			MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
			MXC_DCD_ITEM(56, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

			// Complete calibration by forced measurement:
			MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
			MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
			//=============================================================================
			// Calibration setup end
			//=============================================================================


			//MMDC init:
			//in DDR3, 64-bit mode, only MMDC0 is initiated:
			MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)
			MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
			MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x00c, 0x898E7955)
			MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xFF328F64)
			MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

			#ifdef QSEVEN
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			#elif uSBC
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00011740) //WALAT enable
			#elif UQSEVEN
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			#endif
			MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
			MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
			//MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x008F0E21)
			MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x008E1023)

			MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x040, 0x00000047) //CS0_END = 2304MB in step da 256Mb -> [(2304*8/256) - 1] 
			MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x841A0000) //SDE_1=1; ROW=4; BL=1; DSIZ=2 -> 64 bit 

			//Initialize DDR3 on CS_0 
			MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02088032)//write 0x0408 to MR2 bank_0
			MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
			MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
			MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)//write 0x0940 to MR0 bank_0 (Burst Type=1 (Interlived))
			//ZQ - Calibration
			MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040) // bank_0
		
			MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

			MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x818, 0x00022227) // bank_0
			MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x818, 0x00022227) // bank_1
		
			MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)

			MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)

			MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)
		
			// enable AXI cache for VDOA/VPU/IPU
			MXC_DCD_ITEM(84, IOMUXC_BASE_ADDR + 0x010, 0xf00000ff)
			// set IPU AXI-id0 Qos=0xf(bypass) AXI-id1 Qos=0x7
			MXC_DCD_ITEM(85, IOMUXC_BASE_ADDR + 0x018, 0x007f007f)
			MXC_DCD_ITEM(86, IOMUXC_BASE_ADDR + 0x01c, 0x007f007f)


		//=============================================================================
		// Configuration LDDR SIZE 3 END
		//=============================================================================
		#elif (CONFIG_DDR_SIZE == 2)
			//=============================================================================
			// Calibration setup 
			//=============================================================================		
			#ifdef UQSEVEN
				// value for DDR3 calidration on T1.2 CAL. A22
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F0001)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
		
				//DQS gating, read delay, write delay calibration values
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433F0340)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x0345031C)
				//Read calibration
				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40372F45)
				//write calibrttion
				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x4731473C)
			#elif QSEVEN
				// value for DDR3 calidration on T1.2 CAL. A27				
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
				
				//DQS gating, read delay, write delay calibration values
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x432C0332)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x03380335)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433A0342)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x033F0323)
				//Read calibration
				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x48414146)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40403648)
				//write calibrttion
				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x40424744)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x463F4A3D)
			#elif uSBC
				// value for DDR3 calidration on T1.2 CAL. A22
                                //write leveling
                                MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                                MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
                                MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F0001)
                                MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)

                                //DQS gating, read delay, write delay calibration values
                                MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x431A0326)
                                MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0323031B)
                                MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83c, 0x433F0340)
                                MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x0345031C)
                                //Read calibration
                                MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x40343137)
                                MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x40372F45)
                                //write calibrttion
                                MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x32414741)
                                MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x4731473C)
			#endif

			//DDR3 SETTINGS
			//Read Data Bit Delay
			MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)
			MXC_DCD_ITEM(56, MMDC_P1_BASE_ADDR + 0x81c, 0x33333333)
			MXC_DCD_ITEM(57, MMDC_P1_BASE_ADDR + 0x820, 0x33333333)
			MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x824, 0x33333333)
			MXC_DCD_ITEM(59, MMDC_P1_BASE_ADDR + 0x828, 0x33333333)

			// Complete calibration by forced measurement:
			MXC_DCD_ITEM(60, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
			MXC_DCD_ITEM(61, MMDC_P1_BASE_ADDR + 0x8b8, 0x00000800)
			//=============================================================================
			// Calibration setup end
			//=============================================================================

			//MMDC init:
			//in DDR3, 64-bit mode, only MMDC0 is initiated:
			MXC_DCD_ITEM(62, MMDC_P0_BASE_ADDR + 0x004, 0x00020036)
			MXC_DCD_ITEM(63, MMDC_P0_BASE_ADDR + 0x008, 0x09444040)
			MXC_DCD_ITEM(64, MMDC_P0_BASE_ADDR + 0x00c, 0x54597955)
			MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xFF328F64)
			MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

			MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
			MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026D2)
			MXC_DCD_ITEM(70, MMDC_P0_BASE_ADDR + 0x030, 0x00591023)

			MXC_DCD_ITEM(71, MMDC_P0_BASE_ADDR + 0x040, 0x00000047) //CS0_END = 2304MB in step da 256Mb -> [(2304*8/256) - 1] 
			MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0x831A0000) //SDE_1=0; ROW=3; BL=1; DSIZ=2 -> 64 bit 

			//Initialize DDR3 on CS_0 and CS_1
			MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02088032)//write 0x0408 to MR2 bank_0
			MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
			MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
			MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x09408030)//write 0x0940 to MR0 bank_0 (Burst Type=1 (Interlived))
			//ZQ - Calibration
			MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040) // bank_0
		
			MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

			MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x818, 0x00022227) // bank_0
			MXC_DCD_ITEM(80, MMDC_P1_BASE_ADDR + 0x818, 0x00022227) // bank_1
		
			MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x004, 0x00025576)

			MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x404, 0x00011006)

			MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)
		
			// enable AXI cache for VDOA/VPU/IPU
			MXC_DCD_ITEM(84, IOMUXC_BASE_ADDR + 0x010, 0xf00000ff)
			// set IPU AXI-id0 Qos=0xf(bypass) AXI-id1 Qos=0x7
			MXC_DCD_ITEM(85, IOMUXC_BASE_ADDR + 0x018, 0x007f007f)
			MXC_DCD_ITEM(86, IOMUXC_BASE_ADDR + 0x01c, 0x007f007f)
		
		//=============================================================================
		// Configuration LDDR SIZE 2 END
		//=============================================================================
		#endif
	#endif
#endif	

#if (defined(CONFIG_MX6DL_SECO_Q7) || defined(CONFIG_MX6DL_SECO_UQ7) || defined(CONFIG_MX6DL_SECO_uSBC)  ) 
/********************************************************************************
 ********************************************************************************
 **                     iMX6 Dual Lite 64 bit DDR                              **	
 ********************************************************************************
 ********************************************************************************/
	
	#ifdef CONFIG_DDR_64BIT

		#if (CONFIG_DDR_SIZE == 4)
			dcd_hdr:          .word 0x40E002D2 // Tag=0xD2, Len=88*8 + 4 + 4=02C8, Ver=0x40 
			write_dcd_cmd:    .word 0x04DC02CC // Tag=0xCC, Len=88*8 + 4=02C4, Param=0x04 
		#elif ((CONFIG_DDR_SIZE == 2) || (CONFIG_DDR_SIZE == 3))
			dcd_hdr:          .word 0x40A002D2 // Tag=0xD2, Len=83*8 + 4 + 4=02A0, Ver=0x40 
			write_dcd_cmd:    .word 0x049C02CC // Tag=0xCC, Len=83*8 + 4 =029C, Param=0x04
		#endif
	
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

		#if (CONFIG_DDR_SIZE == 4)
			//=============================================================================
			// Calibration setup 
			//=============================================================================**/
			// value for DDR3 calidration on T1.2 CAL. ??
			//write leveling
			MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
			MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x42480248)
			MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x0211020B)
			MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x417F0211)
			MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x015D0166)

			MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x4B4C504D)
			MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x494C4F48)

			MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x3F3F2E31)
			MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x2B35382B)
		
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
			MXC_DCD_ITEM(72, MMDC_P0_BASE_ADDR + 0x000, 0xC41A0000) //SDE_1=1; ROW=4; BL=1; DSIZ=2 -> 64 bi

			//Initialize DDR3 on CS0
			MXC_DCD_ITEM(73, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
			MXC_DCD_ITEM(74, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
			MXC_DCD_ITEM(75, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
			MXC_DCD_ITEM(76, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
			//ZQ - Calibration bank_0
			MXC_DCD_ITEM(77, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

			//Initialize DDR3 on CS1
			MXC_DCD_ITEM(78, MMDC_P0_BASE_ADDR + 0x01c, 0x0200803A)//write 0x0208 to MR2 bank_0
			MXC_DCD_ITEM(79, MMDC_P0_BASE_ADDR + 0x01c, 0x0000803B)//write 0x0000 to MR3 bank_0
			MXC_DCD_ITEM(80, MMDC_P0_BASE_ADDR + 0x01c, 0x00048039)//write 0x0004 to MR1 bank_0
			MXC_DCD_ITEM(81, MMDC_P0_BASE_ADDR + 0x01c, 0x05208038)//write 0x0940 to MR0 bank_0
			//ZQ - Calibration bank_1
			MXC_DCD_ITEM(82, MMDC_P0_BASE_ADDR + 0x01c, 0x04008048)

			MXC_DCD_ITEM(83, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

			MXC_DCD_ITEM(84, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)
			MXC_DCD_ITEM(85, MMDC_P1_BASE_ADDR + 0x818, 0x00022227)

			MXC_DCD_ITEM(86, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
			MXC_DCD_ITEM(87, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
			MXC_DCD_ITEM(88, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

			//=============================================================================
			// Configuration LDDR SIZE 4 END
			//=============================================================================
	
		#elif (CONFIG_DDR_SIZE == 3)
		//=============================================================================
		// Calibration setup 
		//=============================================================================**/
			#ifdef QSEVEN 
				// value for DDR3 calidration on T1.2 CAL. A23
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
		
				//DQS gating, read delay, write delay calibration values
				
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
			#elif UQSEVEN
				// value for LDDR3 calidration on T1.1 uQseven cal.A19
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
				//DQS gating, read delay, write delay calibration values
				//based on calibration compare of 0x00ffff00
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x42260229)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x020E0224)

				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x4D4F5047)

				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x31353531)
			#elif uSBC
				// value for LDDR3 calidration on T1.1 uQseven cal.A19
                                //write leveling
                                MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                                MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
                                MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
                                MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
                                //DQS gating, read delay, write delay calibration values
                                //based on calibration compare of 0x00ffff00
                                MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
                                MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)
                                MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x42260229)
                                MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x020E0224)

                                MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)
                                MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x4D4F5047)

                                MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
                                MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x31353531)
			#endif

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

		#elif (CONFIG_DDR_SIZE == 2)
		//=============================================================================
		// Calibration setup 
		//=============================================================================**/
			#ifdef QSEVEN 
				// value for DDR3 calidration on T1.2 CAL. A23
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
		
				//DQS gating, read delay, write delay calibration values
				
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
				
			#elif UQSEVEN
				// value for LDDR3 calidration on T1.1 uQseven cal.A19
				//write leveling
				MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
				MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
				MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
				//DQS gating, read delay, write delay calibration values
				//based on calibration compare of 0x00ffff00
				MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
				MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)
				MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x42260229)
				MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x020E0224)

				MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)
				MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x4D4F5047)

				MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
				MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x31353531)
			
			#elif uSBC
				// value for LDDR3 calidration on T1.1 uQseven cal.A19
                                //write leveling
                                MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x003e0043)
                                MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x0032003A)
                                MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x00470052)
                                MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x0052005f)
                                //DQS gating, read delay, write delay calibration values
                                //based on calibration compare of 0x00ffff00
                                MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x42540250)
                                MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x02380240)
                                MXC_DCD_ITEM(46, MMDC_P1_BASE_ADDR + 0x83C, 0x4268026c)
                                MXC_DCD_ITEM(47, MMDC_P1_BASE_ADDR + 0x840, 0x025c025c)

                                MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x484a4a4a)
                                MXC_DCD_ITEM(49, MMDC_P1_BASE_ADDR + 0x848, 0x4646463c)

                                MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x3a383232)
                                MXC_DCD_ITEM(51, MMDC_P1_BASE_ADDR + 0x850, 0x2c2e322c)
			#endif

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
			MXC_DCD_ITEM(65, MMDC_P0_BASE_ADDR + 0x010, 0xB66E8B63)
			MXC_DCD_ITEM(66, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

			#ifdef QSEVEN
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			#elif uSBC
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00011740) //WALAT enable
			#elif UQSEVEN
				MXC_DCD_ITEM(67, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
			#endif
			MXC_DCD_ITEM(68, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
			MXC_DCD_ITEM(69, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
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

	#if ((CONFIG_DDR_SIZE == 0) && defined(CONFIG_DDR_32BIT))

		dcd_hdr:          .word 0x40E001D2 // Tag=0xD2, Len=59*8 + 4 + 4 = 01E0, Ver=0x40 
		write_dcd_cmd:    .word 0x04DC01CC // Tag=0xCC, Len=59*8 + 4 = 01DC, Param=0x04

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

		MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x760, 0x00020000)
		MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x764, 0x00000028)
		MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x770, 0x00000028)
		MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x778, 0x00000028)
		MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x77c, 0x00000028)

		MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x470, 0x00000028)
		MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x474, 0x00000028)
		MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x478, 0x00000028)
		MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x47c, 0x00000028)


		//MMDC_P0_BASE_ADDR = 0x021b0000
		//MMDC_P1_BASE_ADDR = 0x021b4000
		//Calibrations
		//ZQ
		MXC_DCD_ITEM(27, MMDC_P0_BASE_ADDR + 0x800, 0xa1390003)

		//=============================================================================
		// Calibration setup 
		//=============================================================================
		#ifdef QSEVEN 
			// value for LDDR3 calidration on T1.1 uQseven cal.A23
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)
			
			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x4202017F)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x0172017B)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x4147494C)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x3F3D3F36)

		#elif UQSEVEN
			/*
			# write leveling
			MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x80c, 0x0001001F)
			MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x810, 0x001F0001)
			MXC_DCD_ITEM(42, MMDC_P1_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(43, MMDC_P1_BASE_ADDR + 0x810, 0x001F001F)
			# DQS gating, read delay, write delay calibration values
			# based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x83c, 0x431F0323)
			MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x840, 0x03230313)

			MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x848, 0x46393337)

			MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x850, 0x42424739)
			*/

			// value for LDDR3 calidration on T1.1 uQseven cal.A19
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)

		#elif uSBC
			// value for LDDR3 calidration on T1.1 uQseven cal.A19
                        //write leveling
                        MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                        MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

                        //DQS gating, read delay, write delay calibration values
                        //based on calibration compare of 0x00ffff00
                        MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
                        MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

                        MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

                        MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
		
		#endif

		MXC_DCD_ITEM(34, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(35, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(36, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(37, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

		MXC_DCD_ITEM(38, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 32-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x008, 0x00333040)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x00c, 0x3F4352F3) 
		MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x010, 0xB66E8B63)
		MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
		MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x030, 0x00431023)

		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x040, 0x00000017) //CS=_END = 768MB (512 + 256) in step da 256Mb -> [(768*8/256) - 1] 
		MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x000, 0x83190000) //SDE_1=0; ROW=3; BL=1 DSIZ=1 -> 32 bit

		//Initialize DDR3 on CS0
		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
		MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
		//ZQ - Calibration bank_0
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)
		MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)


		MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
		MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
		MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

		//=============================================================================
		// Configuration LDDR SIZE 0 END
		//=============================================================================
	#endif

#endif

#if (defined(CONFIG_MX6S_SECO_Q7) || defined(CONFIG_MX6S_SECO_UQ7) || defined(CONFIG_MX6S_SECO_uSBC))
/********************************************************************************
 ********************************************************************************
 **		             iMX6 SOLO 32 bit DDR	                       **	
 ********************************************************************************
 ********************************************************************************/

	dcd_hdr:          .word 0x40E001D2 // Tag=0xD2, Len=59*8 + 4 + 4 = 01E0, Ver=0x40 
	write_dcd_cmd:    .word 0x04DC01CC // Tag=0xCC, Len=59*8 + 4 = 01DC, Param=0x04

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

	MXC_DCD_ITEM(18, IOMUXC_BASE_ADDR + 0x760, 0x00020000)
	MXC_DCD_ITEM(19, IOMUXC_BASE_ADDR + 0x764, 0x00000028)
	MXC_DCD_ITEM(20, IOMUXC_BASE_ADDR + 0x770, 0x00000028)
	MXC_DCD_ITEM(21, IOMUXC_BASE_ADDR + 0x778, 0x00000028)
	MXC_DCD_ITEM(22, IOMUXC_BASE_ADDR + 0x77c, 0x00000028)

	MXC_DCD_ITEM(23, IOMUXC_BASE_ADDR + 0x470, 0x00000028)
	MXC_DCD_ITEM(24, IOMUXC_BASE_ADDR + 0x474, 0x00000028)
	MXC_DCD_ITEM(25, IOMUXC_BASE_ADDR + 0x478, 0x00000028)
	MXC_DCD_ITEM(26, IOMUXC_BASE_ADDR + 0x47c, 0x00000028)


	//MMDC_P0_BASE_ADDR = 0x021b0000
	//MMDC_P1_BASE_ADDR = 0x021b4000
	//Calibrations
	//ZQ
	MXC_DCD_ITEM(27, MMDC_P0_BASE_ADDR + 0x800, 0xa1390003)

	#if (CONFIG_DDR_SIZE == 1)
		//=============================================================================
		// Calibration setup 
		//=============================================================================**/
		#ifdef QSEVEN 
			// value for LDDR3 calidration on T1.1 uQseven cal.A24
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00 
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x417E017F)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x01780201)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x474B4949)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x403E3E35)

		#elif UQSEVEN
			// value for LDDR3 calidration on T1.1 uQseven cal.A19
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
		
		#elif uSBC
			// value for LDDR3 calidration on T1.1 uQseven cal.A19
                        //write leveling
                        MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                        MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

                        //DQS gating, read delay, write delay calibration values
                        //based on calibration compare of 0x00ffff00
                        MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
                        MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

                        MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

                        MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
	
		#endif

		MXC_DCD_ITEM(34, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(35, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(36, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(37, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

		MXC_DCD_ITEM(38, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 32-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x008, 0x00333040)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x00c, 0x676B52F3) 
		MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x010, 0xB66E8B63)
		MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
		MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x030, 0x006B1023)

		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x040, 0x00000027) //CS=_END = 1280MB (1024 + 256) in step da 256Mb -> [(768*8/256) - 1] 
		MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x000, 0x84190000) //SDE_1=0; ROW=4; BL=1 DSIZ=1 -> 32 bit

		//Initialize DDR3 on CS0
		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
		MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
		//ZQ - Calibration bank_0
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

		MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)


		MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
		MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
		MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

		//=============================================================================
		// Configuration LDDR SIZE 1 END
		//=============================================================================

	#elif (CONFIG_DDR_SIZE == 0)
		//=============================================================================
		// Calibration setup 
		//=============================================================================**/
		#ifdef QSEVEN
			// value for LDDR3 calidration on T1.1 uQseven cal.A24 
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00 
			
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x417E017F)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x01780201)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x474B4949)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x403E3E35)

		#elif UQSEVEN
			// value for LDDR3 calidration on T1.1 uQseven cal.A19
			//write leveling
			MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
			MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

			//DQS gating, read delay, write delay calibration values
			//based on calibration compare of 0x00ffff00
			MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
			MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

			MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

			MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
		
		#elif uSBC
			 // value for LDDR3 calidration on T1.1 uQseven cal.A19
                        //write leveling
                        MXC_DCD_ITEM(28, MMDC_P0_BASE_ADDR + 0x80c, 0x001F001F)
                        MXC_DCD_ITEM(29, MMDC_P0_BASE_ADDR + 0x810, 0x001F001F)

                        //DQS gating, read delay, write delay calibration values
                        //based on calibration compare of 0x00ffff00
                        MXC_DCD_ITEM(30, MMDC_P0_BASE_ADDR + 0x83c, 0x42180217)
                        MXC_DCD_ITEM(31, MMDC_P0_BASE_ADDR + 0x840, 0x02050209)

                        MXC_DCD_ITEM(32, MMDC_P0_BASE_ADDR + 0x848, 0x494B4C4D)

                        MXC_DCD_ITEM(33, MMDC_P0_BASE_ADDR + 0x850, 0x40413133)
		
		#endif

		MXC_DCD_ITEM(34, MMDC_P0_BASE_ADDR + 0x81c, 0x33333333)
		MXC_DCD_ITEM(35, MMDC_P0_BASE_ADDR + 0x820, 0x33333333)
		MXC_DCD_ITEM(36, MMDC_P0_BASE_ADDR + 0x824, 0x33333333)
		MXC_DCD_ITEM(37, MMDC_P0_BASE_ADDR + 0x828, 0x33333333)

		MXC_DCD_ITEM(38, MMDC_P0_BASE_ADDR + 0x8b8, 0x00000800)
		//=============================================================================
		// Calibration setup end
		//=============================================================================

		//MMDC init:
		//in DDR3, 32-bit mode, only MMDC0 is initiated:
		MXC_DCD_ITEM(39, MMDC_P0_BASE_ADDR + 0x004, 0x0002002D)
		MXC_DCD_ITEM(40, MMDC_P0_BASE_ADDR + 0x008, 0x00333040)
		MXC_DCD_ITEM(41, MMDC_P0_BASE_ADDR + 0x00c, 0x3F4352F3) 
		MXC_DCD_ITEM(42, MMDC_P0_BASE_ADDR + 0x010, 0xB66D8B63)
		MXC_DCD_ITEM(43, MMDC_P0_BASE_ADDR + 0x014, 0x01FF00DB)

		MXC_DCD_ITEM(44, MMDC_P0_BASE_ADDR + 0x018, 0x00001740)
		MXC_DCD_ITEM(45, MMDC_P0_BASE_ADDR + 0x01c, 0x00008000)
		MXC_DCD_ITEM(46, MMDC_P0_BASE_ADDR + 0x02c, 0x000026d2)
		MXC_DCD_ITEM(47, MMDC_P0_BASE_ADDR + 0x030, 0x00431023)

		MXC_DCD_ITEM(48, MMDC_P0_BASE_ADDR + 0x040, 0x00000017) //CS=_END = 768MB (512 + 256) in step da 256Mb -> [(768*8/256) - 1] 
		MXC_DCD_ITEM(49, MMDC_P0_BASE_ADDR + 0x000, 0x83190000) //SDE_1=0; ROW=3; BL=1 DSIZ=1 -> 32 bit

		//Initialize DDR3 on CS0
		MXC_DCD_ITEM(50, MMDC_P0_BASE_ADDR + 0x01c, 0x02008032)//write 0x0208 to MR2 bank_0
		MXC_DCD_ITEM(51, MMDC_P0_BASE_ADDR + 0x01c, 0x00008033)//write 0x0000 to MR3 bank_0
		MXC_DCD_ITEM(52, MMDC_P0_BASE_ADDR + 0x01c, 0x00048031)//write 0x0004 to MR1 bank_0
		MXC_DCD_ITEM(53, MMDC_P0_BASE_ADDR + 0x01c, 0x05208030)//write 0x0940 to MR0 bank_0
		//ZQ - Calibration bank_0
		MXC_DCD_ITEM(54, MMDC_P0_BASE_ADDR + 0x01c, 0x04008040)

		MXC_DCD_ITEM(55, MMDC_P0_BASE_ADDR + 0x020, 0x00007800)

		MXC_DCD_ITEM(56, MMDC_P0_BASE_ADDR + 0x818, 0x00022227)


		MXC_DCD_ITEM(57, MMDC_P0_BASE_ADDR + 0x004, 0x0002556D)
		MXC_DCD_ITEM(58, MMDC_P1_BASE_ADDR + 0x404, 0x00011006)
		MXC_DCD_ITEM(59, MMDC_P0_BASE_ADDR + 0x01c, 0x00000000)

		//=============================================================================
		// Configuration LDDR SIZE 0 END
		//=============================================================================

	#endif
#endif
#endif
