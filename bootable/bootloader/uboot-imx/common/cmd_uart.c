/*
 * Boot support
 */
#include <common.h>
#include <command.h>
#include <stdio_dev.h>
#include <config.h>
#include <common.h>
#include <command.h>
#include <malloc.h>
#include <stdio_dev.h>
#include <timestamp.h>
#include <version.h>
#include <net.h>
#include <serial.h>
#include <nand.h>
#include <onenand_uboot.h>
#include <mmc.h>


DECLARE_GLOBAL_DATA_PTR;



static int is_initialized = 0;
int uart_init_dev () {
	int retval;
	if (is_initialized) {
		retval = 0;
	} else {
		uart_init();
		is_initialized = 1;
		retval = 1;
	}
	return retval;
}
	

void uart_write (char *str) {
	uart_puts (str);
}


void uart_read () {
	do {
		int ret = uart_getc ();
		printf ("%c", ret);
		if (ctrlc()) {
			break;
		}
	} while (1);
}


int uart_flush (char **buff) {
	return uart_gets (buff);
}


void read_n (char *buf, int num_char) {
	do {
		int ret = uart_getc ();
		printf ("%c", ret);
		if (ctrlc()) {
			break;
		}
	} while (1);
}


int do_uart (cmd_tbl_t * cmd, int flag, int argc, char *argv[]) {
	int cmd_done = 0;
	char *buff;
	int retval = 0;
	int i = 0;
	if (argc > 1) {
		if (strcmp(argv[1], "init") == 0 && argc == 2) {
			if (uart_init_dev ()) {
				printf ("init done\n");
			} else {
				printf ("init already done\n");
			}
			cmd_done = 1;
		}
		if (strcmp(argv[1], "view") == 0 && argc == 2) {
			uart_reg_display ();
			cmd_done = 1;
		}
		if (strcmp(argv[1], "write") == 0 && argc == 3) {
			uart_write (argv[2]);
			cmd_done = 1;
		}
		if (strcmp(argv[1], "read") == 0 && argc == 2) {
			uart_read ();
			cmd_done = 1;
		}
		if (strcmp(argv[1], "flush") == 0 && argc == 2) {
			retval = uart_flush (&buff);
			if (retval > 0) {
			printf ("Characters flushed: ");
				for (i = 0 ; i < retval ; i++) 
					printf ("%c", buff[i]);
			}
			printf ("\nTot: %d\n", retval);
			cmd_done = 1;
		}
		if (strcmp(argv[1], "readn") == 0 && argc == 3) {
			retval = uart_ngets (&buff, simple_strtoul(argv[2], NULL, 10));
			if (retval > 0) {
			printf ("Characters read: ");
				for (i = 0 ; i < retval ; i++) 
					printf ("%c", buff[i]);
			}
			printf ("\nTot: %d\n", retval);
			cmd_done = 1;
		}
		if (strcmp(argv[1], "buffer_status") == 0 && argc == 2) {
			retval = uart_RX_is_empty ();
			printf ("buffer RX empty:"); 
			if (retval == 0) {
				printf ("No\n");
			} else {
				printf ("Yes\n");
			}
			retval = uart_RX_is_full ();
			printf ("buffer RX full:"); 
			if (retval == 0) {
				printf ("No\n");
			} else {
				printf ("Yes\n");
			}
			retval = uart_TX_is_empty ();
			printf ("buffer TX empty:"); 
			if (retval == 0) {
				printf ("No\n");
			} else {
				printf ("Yes\n");
			}
			retval = uart_TX_is_full ();
			printf ("buffer TX full:"); 
			if (retval == 0) {
				printf ("No\n");
			} else {
				printf ("Yes\n");
			}
			cmd_done = 1;
		}
		if (strcmp(argv[1], "set") == 0 && argc == 4) {
			if (strcmp(argv[2], "parity") == 0) {
				if (strcmp(argv[3], "0") == 0 || strcmp(argv[3], "1") == 0) {
					printf ("val %d\n", ctoi(argv[3][0]));
					if (uart_set_parity (ctoi(argv[3][0]))) {
						cmd_done = 1;
					}
				}	
			}
			if (strcmp(argv[2], "parity_en") == 0) {
				if (strcmp(argv[3], "0") == 0 || strcmp(argv[3], "1") == 0) {
					if (uart_set_parity_en (ctoi(argv[3][0]))) {
						cmd_done = 1;
					}
				}	
			}
			if (strcmp(argv[2], "uart_en") == 0) {
				if (strcmp(argv[3], "0") == 0 || strcmp(argv[3], "1") == 0) {
					if (uart_set_uart_en (ctoi(argv[3][0]))) {
						cmd_done = 1;
					}
				}	
			}
			if (strcmp(argv[2], "baudrate") == 0) {
				if (uart_set_baudrate (simple_strtoul(argv[3], NULL, 10))) {
					cmd_done = 1;
				} else {
					printf ("Invalid BaudRate!\n");
				}
			}
		}
		if (strcmp(argv[1], "get") == 0 && argc == 3) {
			if (strcmp(argv[2], "parity") == 0) {
				printf ("parity setted: ");
				retval = uart_get_parity ();
				if (retval == 0) {
					printf ("Odd\n");
				} else {
					printf ("Even\n");
				}
				cmd_done = 1;
			}
			if (strcmp(argv[2], "parity_en") == 0) {
				printf ("parity status: ");
				retval = uart_get_parity_en ();
				if (retval == 0) {
					printf ("Disabled\n");
				} else {
					printf ("Enabled\n");
				}
				cmd_done = 1;
			}
			if (strcmp(argv[2], "uart_en") == 0) {
				printf ("UART status: ");
				retval = uart_get_uart_en ();
				if (retval == 0) {
					printf ("Disabled\n");
				} else {
					printf ("Enabled\n");
				}
				cmd_done = 1;
			}
			if (strcmp(argv[2], "baudrate") == 0) {
				printf ("BaudRate: %d\n",uart_get_baudrate ());
				cmd_done = 1;
			}
		}			
	}
	if (!cmd_done) {
		cmd_usage(cmd);
	}
	return 0;
}


U_BOOT_CMD(
	uart, 4, 1, do_uart,
	"additional uart commands",
	"                    - prints this help\n"
	"uart [init]             - inits the uart controller\n"
	"uart [view]             - stamps value of all uart controller's register\n"
	"uart [buffer_status]    - views status of RX and TX buffers\n"
	"uart [get] [obj]        - gets status of the specific object. Possibily object is:\n"
	"           parity_en    - 0: parity disabled, 1: parity enabled\n"
	"           parity       - 0: odd, 1: even\n"
	"           uart_en      - 0: UART disabled, 1: UART enabled\n"
	"           baudrate     - gets actual baudrate\n"
	"uart [set] [obj] <val>  - sets status of the specific object. Possibily object is:\n"
	"           parity_en    - 0: parity disabled, 1: parity enabled\n"
	"           partity      - 0: odd, 1: even\n"	
	"           uart_en      - 0: UART disabled, 1: UART enabled\n"
	"           baudrate     - sets baudrate with follow possible values: 115200, 9600, 38400\n"
	"uart [write] <string>   - sends a word without space\n"
	"uart [read]		 - reads indefinitely\n"
	"uart [flush]            - flushes RX buffer end prompts the content to console\n"
	"uart [readn] <num>      - reads max num characters\n"
);
