#include <common.h>

#define __REG(x)     (*((volatile u32 *)(x)))

#define UART_PHYS UART5_BASE_ADDR


/* Register definitions */
#define URXD  0x00 /* Receiver Register */
#define UTXD  0x40 /* Transmitter Register */
#define UCR1  0x80 /* Control Register 1 */
#define UCR2  0x84 /* Control Register 2 */
#define UCR3  0x88 /* Control Register 3 */
#define UCR4  0x8c /* Control Register 4 */
#define UFCR  0x90 /* FIFO Control Register */
#define USR1  0x94 /* Status Register 1 */
#define USR2  0x98 /* Status Register 2 */
#define UESC  0x9c /* Escape Character Register */
#define UTIM  0xa0 /* Escape Timer Register */
#define UBIR  0xa4 /* BRM Incremental Register */
#define UBMR  0xa8 /* BRM Modulator Register */
#define UBRC  0xac /* Baud Rate Count Register */
#define UTS   0xb4 /* UART Test Register (mx31) */

/* UART Control Register Bit Fields.*/
	/* UARTx_URXD */
#define  URXD_CHARRDY    (1<<15)
#define  URXD_ERR        (1<<14)
#define  URXD_OVRRUN     (1<<13)
#define  URXD_FRMERR     (1<<12)
#define  URXD_BRK        (1<<11)
#define  URXD_PRERR      (1<<10)
#define  URXD_RX_DATA    (0xFF)
	/* UARTx_UTDX */
#define  UTXD_TX_DATA    (0xFF)
	/* UARTx_UCR1 */
#define  UCR1_ADEN       (1<<15)    /* Auto dectect interrupt */
#define  UCR1_ADBR       (1<<14)    /* Auto detect baud rate */
#define  UCR1_TRDYEN     (1<<13)    /* Transmitter ready interrupt enable */
#define  UCR1_IDEN       (1<<12)    /* Idle condition interrupt */
#define  UCR1_ICD	 (3<<10)    /* Idle condition detect */
#define  UCR1_RRDYEN     (1<<9)	    /* Recv ready interrupt enable */
#define  UCR1_RDMAEN     (1<<8)	    /* Recv ready DMA enable */
#define  UCR1_IREN       (1<<7)	    /* Infrared interface enable */
#define  UCR1_TXMPTYEN   (1<<6)	    /* Transimitter empty interrupt enable */
#define  UCR1_RTSDEN     (1<<5)	    /* RTS delta interrupt enable */
#define  UCR1_SNDBRK     (1<<4)	    /* Send break */
#define  UCR1_TDMAEN     (1<<3)	    /* Transmitter ready DMA enable */
#define  UCR1_UARTCLKEN  (1<<2)	    /* UART clock enabled */
#define  UCR1_DOZE       (1<<1)	    /* Doze */
#define  UCR1_UARTEN     (1<<0)	    /* UART enabled */
	/* UARTx_UCR2 */
#define  UCR2_ESCI	 (1<<15)    /* Escape seq interrupt enable */
#define  UCR2_IRTS	 (1<<14)    /* Ignore RTS pin */
#define  UCR2_CTSC	 (1<<13)    /* CTS pin control */
#define  UCR2_CTS        (1<<12)    /* Clear to send */
#define  UCR2_ESCEN      (1<<11)    /* Escape enable */
#define  UCR2_RTEC       (3<<9)     /* Request to send edge control */
#define  UCR2_PREN       (1<<8)     /* Parity enable */
#define  UCR2_PROE       (1<<7)     /* Parity odd/even */
#define  UCR2_STPB       (1<<6)	    /* Stop */
#define  UCR2_WS         (1<<5)	    /* Word size */
#define  UCR2_RTSEN      (1<<4)	    /* Request to send interrupt enable */
#define  UCR2_TXEN       (1<<2)	    /* Transmitter enabled */
#define  UCR2_RXEN       (1<<1)	    /* Receiver enabled */
#define  UCR2_SRST	 (1<<0)	    /* SW reset */
	/* UARTx_UCR3 */
#define  UCR3_DPEC       (3<<14)    /* DTR/DSR interrupt edge control */
#define  UCR3_DTREN	 (1<<13)    /* DTR interrupt enable */
#define  UCR3_PARERREN   (1<<12)    /* Parity enable */
#define  UCR3_FRAERREN   (1<<11)    /* Frame error interrupt enable */
#define  UCR3_DSR        (1<<10)    /* Data set ready */
#define  UCR3_DCD        (1<<9)     /* Data carrier detect */
#define  UCR3_RI         (1<<8)     /* Ring indicator */
#define  UCR3_TIMEOUTEN  (1<<7)     /* Timeout interrupt enable */
#define  UCR3_RXDSEN	 (1<<6)     /* Receive status interrupt enable */
#define  UCR3_AIRINTEN   (1<<5)     /* Async IR wake interrupt enable */
#define  UCR3_AWAKEN	 (1<<4)     /* Async wake interrupt enable */
#define  UCR3_REF25	 (1<<3)     /* Ref freq 25 MHz */
#define  UCR3_REF30	 (1<<2)     /* Ref Freq 30 MHz */
#define  UCR3_INVT	 (1<<1)     /* Inverted Infrared transmission */
#define  UCR3_BPEN	 (1<<0)     /* Preset registers enable */
	/* UARTx_UCR4 */
#define  UCR4_CTSTL      (0x3F<<10) /* CTS trigger level (32 chars) */
#define  UCR4_INVR	 (1<<9)     /* Inverted infrared reception */
#define  UCR4_ENIRI	 (1<<8)     /* Serial infrared interrupt enable */
#define  UCR4_WKEN	 (1<<7)     /* Wake interrupt enable */
#define  UCR4_REF16	 (1<<6)     /* Ref freq 16 MHz */
#define  UCR4_IRSC	 (1<<5)     /* IR special case */
#define  UCR4_TCEN	 (1<<3)     /* Transmit complete interrupt enable */
#define  UCR4_BKEN	 (1<<2)     /* Break condition interrupt enable */
#define  UCR4_OREN	 (1<<1)     /* Receiver overrun interrupt enable */
#define  UCR4_DREN	 (1<<0)     /* Recv data ready interrupt enable */
	/* UARTx_UFCR */
#define  UFCR_TXTL       (0x3F<<10)  /* Transmitter trigger level */
#define  UFCR_RFDIV      (7<<7)      /* Reference freq divider mask */
#define  UFCR_DCEDTE     (1<<6)      /* DCE/DTE mode select */
#define  UFCR_RXTL       (0x3F)      /* Receiver trigger level */
	/* UARTx_USR1 */
#define  USR1_PARITYERR  (1<<15)     /* Parity error interrupt flag */
#define  USR1_RTSS	 (1<<14)     /* RTS pin status */
#define  USR1_TRDY	 (1<<13)     /* Transmitter ready interrupt/dma flag */
#define  USR1_RTSD	 (1<<12)     /* RTS delta */
#define  USR1_ESCF	 (1<<11)     /* Escape seq interrupt flag */
#define  USR1_FRAMERR    (1<<10)     /* Frame error interrupt flag */
#define  USR1_RRDY       (1<<9)	     /* Receiver ready interrupt/dma flag */
#define  USR1_TIMEOUT    (1<<7)	     /* Receive timeout interrupt status */
#define  USR1_RXDS	 (1<<6)	     /* Receiver idle interrupt flag */
#define  USR1_AIRINT	 (1<<5)	     /* Async IR wake interrupt flag */
#define  USR1_AWAKE	 (1<<4)	     /* Aysnc wake interrupt flag */
#define  USR1_SAD        (1<<3)      /* RS-485 slave address detected interrupt flag */ 
	/* UARTx_USR2 */
#define  USR2_ADET	 (1<<15)     /* Auto baud rate detect complete */
#define  USR2_TXFE	 (1<<14)     /* Transmit buffer FIFO empty */
#define  USR2_DTRF	 (1<<13)     /* DTR edge interrupt flag */
#define  USR2_IDLE	 (1<<12)     /* Idle condition */
#define  USR2_ACST	 (1<<11)     /* Autobaud couter stopped */
#define  USR2_RIDELT     (1<<10)     /* Ring Indicator delta */
#define  USR2_RIN	 (1<<9)	     /* Ring indicator input */
#define  USR2_IRINT	 (1<<8)	     /* Serial infrared interrupt flag */
#define  USR2_WAKE	 (1<<7)	     /* Wake */
#define  USR2_DCDDELT    (1<<6)      /* Data carrier detect delta */
#define  USR2_DCDIN      (1<<5)      /* Data carrier detect input */
#define  USR2_RTSF	 (1<<4)	     /* RTS edge interrupt flag */
#define  USR2_TXDC	 (1<<3)	     /* Transmitter complete */
#define  USR2_BRCD	 (1<<2)	     /* Break condition */
#define  USR2_ORE        (1<<1)	     /* Overrun error */
#define  USR2_RDR        (1<<0)	     /* Recv data ready */
	/* UARTx_UTS */
#define  UTS_FRCPERR	 (1<<13)     /* Force parity error */
#define  UTS_LOOP        (1<<12)     /* Loop tx and rx */
#define  UTS_DBGEN	 (1<<11)     /* debug enable */
#define  UTS_LOOPIR      (1<<10)     /* Loop TX and RX for IR test */
#define  UTS_RXDBG	 (1<<9)      /* RX fifo debug mode */
#define  UTS_TXEMPTY	 (1<<6)	     /* TxFIFO empty */
#define  UTS_RXEMPTY	 (1<<5)	     /* RxFIFO empty */
#define  UTS_TXFULL	 (1<<4)	     /* TxFIFO full */
#define  UTS_RXFULL	 (1<<3)	     /* RxFIFO full */
#define  UTS_SOFTRST	 (1<<0)	     /* Software reset */


#define BAUDRATE_DEFAULT 115200

DECLARE_GLOBAL_DATA_PTR;

void uart_setbrg (void) {
	u32 clk = mxc_get_clock(MXC_UART_CLK) / 2;

	__REG(UART_PHYS + UFCR) = 4 << 7; /* divide int clock by 2 */
	__REG(UART_PHYS + UBIR) = (0x10 * 0xA) - 1;
	__REG(UART_PHYS + UBMR) = (clk / BAUDRATE_DEFAULT) * 10 - 1;

}


int uart_set_baudrate (int rate) {
	int retval = 1;
	u32 clk = mxc_get_clock(MXC_UART_CLK) / 2;
	switch (rate) {
		case 115200:
		case 9600:
		case 38400:
			 __REG(UART_PHYS + UBMR) = (clk / rate) * 10 - 1;
			 break;
		default:
			 retval = 0;
	}
	return retval;
}

int uart_get_baudrate (void) {
	u32 clk = mxc_get_clock(MXC_UART_CLK) / 2;
	return (clk * 10) / (__REG(UART_PHYS + UBMR) + 1);
}


int uart_getc (void) {
	while (__REG(UART_PHYS + UTS) & UTS_RXEMPTY);
	return (__REG(UART_PHYS + URXD) & URXD_RX_DATA); /* mask out status from upper word */
}


void uart_putc (const char c) {
	__REG(UART_PHYS + UTXD) = c;

	/* wait for transmitter to be ready */
	while(!(__REG(UART_PHYS + UTS) & UTS_TXEMPTY));

	/* If \n, also do \r */
	if (c == '\n')
		uart_putc ('\r');
}


/*
 * Test whether a character is in the RX buffer
 */
int uart_tstc (void) {
	/* If receive fifo is empty, return 0 */
	if (__REG(UART_PHYS + UTS) & UTS_RXEMPTY)
		return 0;
	return 1;
}


void uart_puts (const char *s) {
	while (*s) {
		uart_putc (*s++);
	}
}


int uart_gets (char **buff) {
	int size = 0;
	char *s = NULL;
	while (uart_tstc ()) {
		if (s == NULL) {
			s = (char *) malloc(sizeof(char));
		} else {
			s = (char *) realloc(s, (size + 1) * sizeof(char));
		}
	        s[size] = (char)uart_getc ();
		size ++;	
	}
	*buff = s;
	return size;
}


int uart_ngets (char **buff, int max_char) {
	int size = 0;
	char *s = NULL;
	while (uart_tstc () && size < max_char) {
		if (s == NULL) {
			s = (char *) malloc(sizeof(char));
		} else {
			s = (char *) realloc(s, (size + 1) * sizeof(char));
		}
	        s[size] = (char)uart_getc ();
		size ++;	
	}
	*buff = s;
	return size;
}


int uart_get_parity (void) {
	return (__REG(UART_PHYS + UCR2) & UCR2_PROE) >> 7;
}


int uart_set_parity (int parity) {
	u32 reg = __REG(UART_PHYS + UCR2);
	if (parity == 0) {
		__REG(UART_PHYS + UCR2) = reg & ~UCR2_PROE;
		return 1;
	}
	if (parity == 1) {
		__REG(UART_PHYS + UCR2) = reg | UCR2_PROE;
		return 1;
	}
	return 0;
}


int uart_get_parity_en (void) {
	return (__REG(UART_PHYS + UCR2) & UCR2_PREN) >> 8;
}


int uart_set_parity_en (int en) {
	u32 reg =  __REG(UART_PHYS + UCR2);
	if (en == 0) {
		__REG(UART_PHYS + UCR2) = reg & ~UCR2_PREN;
		return 1;
	}
	if (en == 1) {
		__REG(UART_PHYS + UCR2) = reg | UCR2_PREN;
		return 1;
	}
	return 0;
}


int uart_get_uart_en (void) {
	return (__REG(UART_PHYS + UCR1) & UCR1_UARTEN);
}


int uart_set_uart_en (int en) {
	u32 reg =  __REG(UART_PHYS + UCR1);
	if (en == 0) {
		__REG(UART_PHYS + UCR2) = reg & ~UCR1_UARTEN;
		return 1;
	}
	if (en == 1) {
		__REG(UART_PHYS + UCR2) = reg | UCR1_UARTEN;
		return 1;
	}
	return 0;
}


int uart_RX_is_empty (void) {
	if (__REG(UART_PHYS + UTS) & UTS_RXEMPTY)
		return 1;
	return 0;
}


int uart_TX_is_empty (void) {
	if (__REG(UART_PHYS + UTS) & UTS_TXEMPTY)
		return 1;
	return 0;
}

int uart_RX_is_full (void) {
	if (__REG(UART_PHYS + UTS) & UTS_RXFULL)
		return 1;
	return 0;
}


int uart_TX_is_full (void) {
	if (__REG(UART_PHYS + UTS) & UTS_RXFULL)
		return 1;
	return 0;
}

/*
 * Initialise the serial port with the given baudrate. The settings
 * are  8 data bits, no parity, 1 stop bit, no start bits.
 *
 */
int uart_init (void) {
	__REG(UART_PHYS + UCR1) = 0x0;
	__REG(UART_PHYS + UCR2) = 0x0;

	while (!(__REG(UART_PHYS + UCR2) & UCR2_SRST));

	__REG(UART_PHYS + UCR3) = 0x0704;
	__REG(UART_PHYS + UCR4) = 0x8000;
	__REG(UART_PHYS + UESC) = 0x002b;
	__REG(UART_PHYS + UTIM) = 0x0;

	__REG(UART_PHYS + UTS) = 0x0;

	uart_setbrg();

	__REG(UART_PHYS + UCR2) = UCR2_WS | UCR2_IRTS | UCR2_RXEN | UCR2_TXEN | UCR2_SRST;

	__REG(UART_PHYS + UCR1) = UCR1_UARTEN;

	return 0;
}


void uart_reg_display () {
	u32 reg;
	reg = __REG(UART_PHYS + URXD);
	printf ("reg 0x%x URXD = 0x%04x\n", UART_PHYS + URXD, reg);
	reg = __REG(UART_PHYS + UTXD);
	printf ("reg 0x%x UTXD = 0x%04x\n", UART_PHYS + UTXD, reg);

	reg = __REG(UART_PHYS + UCR1);
	printf ("reg 0x%x UCR1 = 0x%04x\n", UART_PHYS + UCR1, reg);
	reg = __REG(UART_PHYS + UCR2);
	printf ("reg 0x%x UCR2 = 0x%04x\n", UART_PHYS + UCR2, reg);
	reg = __REG(UART_PHYS + UCR3);
	printf ("reg 0x%x UCR3 = 0x%04x\n", UART_PHYS + UCR3, reg);
	reg = __REG(UART_PHYS + UCR4);
	printf ("reg 0x%x UCR4 = 0x%04x\n", UART_PHYS + UCR4, reg);

	reg = __REG(UART_PHYS + UFCR);
	printf ("reg 0x%x UFCR = 0x%04d\n", UART_PHYS + UFCR, reg);

	reg = __REG(UART_PHYS + USR1);
	printf ("reg 0x%x USR1 = 0x%04x\n", UART_PHYS + USR1, reg);
	reg = __REG(UART_PHYS + USR2);
	printf ("reg 0x%x USR2 = 0x%04x\n", UART_PHYS + USR2, reg);

	reg = __REG(UART_PHYS + UTIM);
	printf ("reg 0x%x UTIM = 0x%04d\n", UART_PHYS + UTIM, reg);

	reg = __REG(UART_PHYS + UBIR);
	printf ("reg 0x%x UBIR = 0x%04d\n", UART_PHYS + UBIR, reg);

	reg = __REG(UART_PHYS + UBMR);
	printf ("reg 0x%x UBMR = 0x%04d\n", UART_PHYS + UBMR, reg);

	reg = __REG(UART_PHYS + UBRC);
	printf ("reg 0x%x UBRC = 0x%04d\n", UART_PHYS + UBRC, reg);

	reg = __REG(UART_PHYS + UTS);
	printf ("reg 0x%x UTS  = 0x%04d\n", UART_PHYS + UTS, reg);
}
