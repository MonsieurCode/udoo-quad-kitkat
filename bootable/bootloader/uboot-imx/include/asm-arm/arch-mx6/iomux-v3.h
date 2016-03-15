/*
 * Copyright (C) 2009 by Jan Weitzel Phytec Messtechnik GmbH,
 *			<armlinux@phytec.de>
 *
 * Copyright (C) 2011-2012 Freescale Semiconductor, Inc.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
 * MA 02110-1301, USA.
 */

#ifndef __MACH_IOMUX_V3_H__
#define __MACH_IOMUX_V3_H__

/*
 *	build IOMUX_PAD structure
 *
 * This iomux scheme is based around pads, which are the physical balls
 * on the processor.
 *
 * - Each pad has a pad control register (IOMUXC_SW_PAD_CTRL_x) which controls
 *   things like driving strength and pullup/pulldown.
 * - Each pad can have but not necessarily does have an output routing register
 *   (IOMUXC_SW_MUX_CTL_PAD_x).
 * - Each pad can have but not necessarily does have an input routing register
 *   (IOMUXC_x_SELECT_INPUT)
 *
 * The three register sets do not have a fixed offset to each other,
 * hence we order this table by pad control registers (which all pads
 * have) and put the optional i/o routing registers into additional
 * fields.
 *
 * The naming convention for the pad modes is MX35_PAD_<padname>__<padmode>
 * If <padname> or <padmode> refers to a GPIO, it is named
 * GPIO_<unit>_<num>
 *
 * IOMUX/PAD Bit field definitions
 *
 * MUX_CTRL_OFS:	    0..11 (12)
 * PAD_CTRL_OFS:	   12..23 (12)
 * SEL_INPUT_OFS:	   24..35 (12)
 * MUX_MODE + SION:	   36..40  (5)
 * PAD_CTRL + NO_PAD_CTRL: 41..59 (19)
 * SEL_INP:		   60..63  (4)
*/

typedef u64 iomux_v3_cfg_t;
typedef unsigned int iomux_pin_name_t;

#define MUX_CTRL_OFS_SHIFT	0
#define MUX_CTRL_OFS_MASK	((iomux_v3_cfg_t)0xfff << MUX_CTRL_OFS_SHIFT)
#define MUX_PAD_CTRL_OFS_SHIFT	12
#define MUX_PAD_CTRL_OFS_MASK	((iomux_v3_cfg_t)0xfff << \
	MUX_PAD_CTRL_OFS_SHIFT)
#define MUX_SEL_INPUT_OFS_SHIFT	24
#define MUX_SEL_INPUT_OFS_MASK	((iomux_v3_cfg_t)0xfff << \
	MUX_SEL_INPUT_OFS_SHIFT)

#define MUX_MODE_SHIFT		36
#define MUX_MODE_MASK		((iomux_v3_cfg_t)0x1f << MUX_MODE_SHIFT)
#define MUX_PAD_CTRL_SHIFT	41
#define MUX_PAD_CTRL_MASK	((iomux_v3_cfg_t)0x7ffff << MUX_PAD_CTRL_SHIFT)
#define MUX_SEL_INPUT_SHIFT	60
#define MUX_SEL_INPUT_MASK	((iomux_v3_cfg_t)0xf << MUX_SEL_INPUT_SHIFT)

#define MUX_PAD_CTRL(x)		((iomux_v3_cfg_t)(x) << MUX_PAD_CTRL_SHIFT)

#define IOMUX_PAD(_pad_ctrl_ofs, _mux_ctrl_ofs, _mux_mode, _sel_input_ofs, \
		_sel_input, _pad_ctrl)					\
	(((iomux_v3_cfg_t)(_mux_ctrl_ofs) << MUX_CTRL_OFS_SHIFT) |	\
		((iomux_v3_cfg_t)(_mux_mode) << MUX_MODE_SHIFT) |	\
		((iomux_v3_cfg_t)(_pad_ctrl_ofs) << MUX_PAD_CTRL_OFS_SHIFT) | \
		((iomux_v3_cfg_t)(_pad_ctrl) << MUX_PAD_CTRL_SHIFT) |	\
		((iomux_v3_cfg_t)(_sel_input_ofs) << \
			MUX_SEL_INPUT_OFS_SHIFT) | \
		((iomux_v3_cfg_t)(_sel_input) << MUX_SEL_INPUT_SHIFT))

#if defined CONFIG_MX6Q
#define MX6X_IOMUX(s) MX6Q_##s
#elif defined CONFIG_MX6DL
#define MX6X_IOMUX(s) MX6DL_##s
#elif defined CONFIG_MX6SL
#define MX6X_IOMUX(s) MX6SL_##s
#endif

/*
 * Use to set PAD control
 */
#define PAD_CTL_LVE_OFFSET	(22)
#define PAD_CTL_LVE		(1 << 18)
#define NO_PAD_CTRL		(1 << 17)
#define PAD_CTL_HYS		(1 << 16)

#define NO_PAD_I		0
#define NO_MUX_I		0
#define IOMUX_CONFIG_SION	(0x1 << 4)

#define PAD_CTL_PUS_100K_DOWN	(0 << 14)
#define PAD_CTL_PUS_47K_UP	(1 << 14)
#define PAD_CTL_PUS_100K_UP	(2 << 14)
#define PAD_CTL_PUS_22K_UP	(3 << 14)

#define PAD_CTL_PUE		(1 << 13)
#define PAD_CTL_PKE		(1 << 12)
#define PAD_CTL_ODE		(1 << 11)

#define PAD_CTL_SPEED_LOW	(1 << 6)
#define PAD_CTL_SPEED_MED	(2 << 6)
#define PAD_CTL_SPEED_HIGH	(3 << 6)

#define PAD_CTL_DSE_DISABLE	(0 << 3)
#define PAD_CTL_DSE_240ohm	(1 << 3)
#define PAD_CTL_DSE_120ohm	(2 << 3)
#define PAD_CTL_DSE_80ohm	(3 << 3)
#define PAD_CTL_DSE_60ohm	(4 << 3)
#define PAD_CTL_DSE_48ohm	(5 << 3)
#define PAD_CTL_DSE_40ohm	(6 << 3)
#define PAD_CTL_DSE_34ohm	(7 << 3)

#define PAD_CTL_SRE_FAST	(1 << 0)
#define PAD_CTL_SRE_SLOW	(0 << 0)

#define GPIO_PIN_MASK 0x1f

#define GPIO_PORT_SHIFT 5
#define GPIO_PORT_MASK (0x7 << GPIO_PORT_SHIFT)

#define GPIO_PORTA	(0 << GPIO_PORT_SHIFT)
#define GPIO_PORTB	(1 << GPIO_PORT_SHIFT)
#define GPIO_PORTC	(2 << GPIO_PORT_SHIFT)
#define GPIO_PORTD	(3 << GPIO_PORT_SHIFT)
#define GPIO_PORTE	(4 << GPIO_PORT_SHIFT)
#define GPIO_PORTF	(5 << GPIO_PORT_SHIFT)

/*
 * setups a single pad in the iomuxer
 */
int mxc_iomux_v3_setup_pad(iomux_v3_cfg_t pad);

/*
 * setups mutliple pads
 * convenient way to call the above function with tables
 */
int mxc_iomux_v3_setup_multiple_pads(iomux_v3_cfg_t *pad_list, unsigned count);

/*
 * Set bits for general purpose registers
 */
void mxc_iomux_set_gpr_register(int group, int start_bit, int num_bits, int value);

/*
 * Initialise the iomux controller
 */
void mxc_iomux_v3_init(void *iomux_v3_base);

/*
 * iomuxc_gpr13 bit fields
 */
#define iomuxc_gpr13_sdma_stop_req	(1<<30)
#define iomuxc_gpr13_can2_stop_req	(1<<29)
#define iomuxc_gpr13_can1_stop_req	(1<<28)
#define iomuxc_gpr13_enet_stop_req	(1<<27)
#define IOMUXC_GPR13_SATA_PHY_8_MASK	(7<<24)
#define IOMUXC_GPR13_SATA_PHY_7_MASK	(0x1f<<19)
#define IOMUXC_GPR13_SATA_PHY_6_SHIFT	16
#define IOMUXC_GPR13_SATA_PHY_6_MASK	(7<<IOMUXC_GPR13_SATA_PHY_6_SHIFT)
#define IOMUXC_GPR13_SATA_SPEED_MASK	(1<<15)
#define IOMUXC_GPR13_SATA_PHY_5_MASK	(1<<14)
#define IOMUXC_GPR13_SATA_PHY_4_MASK	(7<<11)
#define IOMUXC_GPR13_SATA_PHY_3_MASK	(0x1f<<7)
#define IOMUXC_GPR13_SATA_PHY_2_MASK	(0x1f<<2)
#define IOMUXC_GPR13_SATA_PHY_1_MASK	(3<<0)

#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_0P5DB	(0b000<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_1P0DB	(0b001<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_1P5DB	(0b010<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_2P0DB	(0b011<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_2P5DB	(0b100<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_3P0DB	(0b101<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_3P5DB	(0b110<<24)
#define IOMUXC_GPR13_SATA_PHY_8_RXEQ_4P0DB	(0b111<<24)

#define IOMUXC_GPR13_SATA_PHY_7_SATA1I	(0b10000<<19)
#define IOMUXC_GPR13_SATA_PHY_7_SATA1M	(0b10000<<19)
#define IOMUXC_GPR13_SATA_PHY_7_SATA1X	(0b11010<<19)
#define IOMUXC_GPR13_SATA_PHY_7_SATA2I	(0b10010<<19)
#define IOMUXC_GPR13_SATA_PHY_7_SATA2M	(0b10010<<19)
#define IOMUXC_GPR13_SATA_PHY_7_SATA2X	(0b11010<<19)

#define IOMUXC_GPR13_SATA_SPEED_1P5G	(0<<15)
#define IOMUXC_GPR13_SATA_SPEED_3G	(1<<15)

#define IOMUXC_GPR13_SATA_SATA_PHY_5_SS_DISABLED	(0<<14)
#define IOMUXC_GPR13_SATA_SATA_PHY_5_SS_ENABLED		(1<<14)

#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_16_16	(0<<11)
#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_14_16	(1<<11)
#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_12_16	(2<<11)
#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_10_16	(3<<11)
#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_9_16		(4<<11)
#define IOMUXC_GPR13_SATA_SATA_PHY_4_ATTEN_8_16		(5<<11)

#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_0P00_DB	(0b0000<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_0P37_DB	(0b0001<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_0P74_DB	(0b0010<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_1P11_DB	(0b0011<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_1P48_DB	(0b0100<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_1P85_DB	(0b0101<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_2P22_DB	(0b0110<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_2P59_DB	(0b0111<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_2P96_DB	(0b1000<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_3P33_DB	(0b1001<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_3P70_DB	(0b1010<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_4P07_DB	(0b1011<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_4P44_DB	(0b1100<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_4P81_DB	(0b1101<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_5P28_DB	(0b1110<<7)
#define IOMUXC_GPR13_SATA_PHY_3_TXBOOST_5P75_DB	(0b1111<<7)

#define IOMUXC_GPR13_SATA_PHY_2_TX_0P937V	(0b00000<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P947V	(0b00001<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P957V	(0b00010<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P966V	(0b00011<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P976V	(0b00100<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P986V	(0b00101<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_0P996V	(0b00110<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P005V	(0b00111<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P015V	(0b01000<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P025V	(0b01001<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P035V	(0b01010<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P045V	(0b01011<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P054V	(0b01100<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P064V	(0b01101<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P074V	(0b01110<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P084V	(0b01111<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P094V	(0b10000<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P104V	(0b10001<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P113V	(0b10010<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P123V	(0b10011<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P133V	(0b10100<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P143V	(0b10101<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P152V	(0b10110<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P162V	(0b10111<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P172V	(0b11000<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P182V	(0b11001<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P191V	(0b11010<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P201V	(0b11011<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P211V	(0b11100<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P221V	(0b11101<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P230V	(0b11110<<2)
#define IOMUXC_GPR13_SATA_PHY_2_TX_1P240V	(0b11111<<2)

#define IOMUXC_GPR13_SATA_PHY_1_FAST	0
#define IOMUXC_GPR13_SATA_PHY_1_MEDIUM	1
#define IOMUXC_GPR13_SATA_PHY_1_SLOW	2

#define IOMUXC_GPR13_SATA_MASK (IOMUXC_GPR13_SATA_PHY_8_MASK \
				|IOMUXC_GPR13_SATA_PHY_7_MASK \
				|IOMUXC_GPR13_SATA_PHY_6_MASK \
				|IOMUXC_GPR13_SATA_SPEED_MASK \
				|IOMUXC_GPR13_SATA_PHY_5_MASK \
				|IOMUXC_GPR13_SATA_PHY_4_MASK \
				|IOMUXC_GPR13_SATA_PHY_3_MASK \
				|IOMUXC_GPR13_SATA_PHY_2_MASK \
				|IOMUXC_GPR13_SATA_PHY_1_MASK)
				
#endif /* __MACH_IOMUX_V3_H__*/



