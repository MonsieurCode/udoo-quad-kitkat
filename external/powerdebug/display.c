/*******************************************************************************
 * Copyright (C) 2010, Linaro Limited.
 *
 * This file is part of PowerDebug.
 *
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:
 *     Amit Arora <amit.arora@linaro.org> (IBM Corporation)
 *       - initial API and implementation
 *******************************************************************************/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <ncurses.h>
#include <sys/types.h>
#include <regex.h>
#include "powerdebug.h"
#include "mainloop.h"
#include "regulator.h"
#include "display.h"

enum { PT_COLOR_DEFAULT = 1,
       PT_COLOR_HEADER_BAR,
       PT_COLOR_ERROR,
       PT_COLOR_RED,
       PT_COLOR_YELLOW,
       PT_COLOR_GREEN,
       PT_COLOR_BRIGHT,
       PT_COLOR_BLUE,
};

static WINDOW *header_win;
static WINDOW *footer_win;
static WINDOW *main_win;
static int current_win;

/* Number of lines in the virtual window */
static const int maxrows = 1024;

struct rowdata {
	int attr;
	void *data;
};

struct windata {
	WINDOW *pad;
	struct display_ops *ops;
	struct rowdata *rowdata;
	char *name;
	int nrdata;
	int scrolling;
	int cursor;
};

/* Warning this is linked with the enum { CLOCK, REGULATOR, ... } */
struct windata windata[] = {
	[CLOCK]     = { .name = "Clocks"     },
	[REGULATOR] = { .name = "Regulators" },
	[SENSOR]    = { .name = "Sensors"    },
	[GPIO]      = { .name = "Gpio"    },
};

static void display_fini(void)
{
	endwin();
}

static int display_show_header(int win)
{
	int i;
	int curr_pointer = 0;
	size_t array_size = sizeof(windata) / sizeof(windata[0]);

	wattrset(header_win, COLOR_PAIR(PT_COLOR_HEADER_BAR));
	wbkgd(header_win, COLOR_PAIR(PT_COLOR_HEADER_BAR));
	werase(header_win);

	mvwprintw(header_win, 0, curr_pointer, "PowerDebug %s", VERSION);
	curr_pointer += 20;

	for (i = 0; i < array_size; i++) {
		if (win == i)
			wattron(header_win, A_REVERSE);
		else
			wattroff(header_win, A_REVERSE);

		mvwprintw(header_win, 0, curr_pointer, " %s ", windata[i].name);
		curr_pointer += strlen(windata[i].name) + 2;
	}
	wrefresh(header_win);

	return 0;
}

#define footer_label " Q (Quit)  R (Refresh) Other Keys: 'Left', " \
	"'Right' , 'Up', 'Down', 'enter', , 'Esc'"

static int display_show_footer(int win, char *string)
{
	werase(footer_win);
	wattron(footer_win, A_REVERSE);
	mvwprintw(footer_win, 0, 0, "%s", string ? string : footer_label);
	wattroff(footer_win, A_REVERSE);
	wrefresh(footer_win);

	return 0;
}

static int display_refresh(int win, bool read)
{
	/* we are trying to refresh a window which is not showed */
	if (win != current_win)
		return 0;

	if (windata[win].ops && windata[win].ops->display)
		return windata[win].ops->display(read);

	if (werase(main_win))
		return -1;

	return wrefresh(main_win);
}

int display_refresh_pad(int win)
{
	int maxx, maxy;

	getmaxyx(stdscr, maxy, maxx);

	return prefresh(windata[win].pad, windata[win].scrolling,
			0, 2, 0, maxy - 2, maxx);
}

static int display_show_unselection(int win, int line, bool bold)
{
	if (mvwchgat(windata[win].pad, line, 0, -1,
		     bold ? WA_BOLD: WA_NORMAL, 0, NULL) < 0)
		return -1;

	return display_refresh_pad(win);
}

void *display_get_row_data(int win)
{
	return windata[win].rowdata[windata[win].cursor].data;
}

static int display_select(void)
{
	if (windata[current_win].ops && windata[current_win].ops->select)
		return windata[current_win].ops->select();

	return 0;
}

static int display_next_panel(void)
{
	size_t array_size = sizeof(windata) / sizeof(windata[0]);

	current_win++;
	current_win %= array_size;

	return current_win;
}

static int display_prev_panel(void)
{
	size_t array_size = sizeof(windata) / sizeof(windata[0]);

	current_win--;
	if (current_win < 0)
		current_win = array_size - 1;

	return current_win;
}

static int display_next_line(void)
{
	int maxx, maxy;
	int cursor = windata[current_win].cursor;
	int nrdata = windata[current_win].nrdata;
	int scrolling = windata[current_win].scrolling;
	struct rowdata *rowdata = windata[current_win].rowdata;

	getmaxyx(stdscr, maxy, maxx);

	if (cursor >= nrdata)
		return cursor;

	display_show_unselection(current_win, cursor, rowdata[cursor].attr);
	if (cursor < nrdata - 1) {
		if (cursor >= (maxy - 4 + scrolling))
			scrolling++;
		cursor++;
	}

	windata[current_win].scrolling = scrolling;
	windata[current_win].cursor = cursor;

	return cursor;
}

static int display_prev_line(void)
{
	int cursor = windata[current_win].cursor;
	int nrdata = windata[current_win].nrdata;
	int scrolling = windata[current_win].scrolling;
	struct rowdata *rowdata = windata[current_win].rowdata;

	if (cursor >= nrdata)
		return cursor;

	display_show_unselection(current_win, cursor, rowdata[cursor].attr);
	if (cursor > 0) {
		if (cursor <= scrolling)
			scrolling--;
		cursor--;
	}

	windata[current_win].scrolling = scrolling;
	windata[current_win].cursor = cursor;

	return cursor;
}

static int display_set_row_data(int win, int line, void *data, int attr)
{
	struct rowdata *rowdata =  windata[win].rowdata;

	if (line >= windata[win].nrdata) {
		rowdata = realloc(rowdata, sizeof(struct rowdata) * (line + 1));
		if (!rowdata)
			return -1;
		windata[win].nrdata = line + 1;
	}

	rowdata[line].data = data;
	rowdata[line].attr = attr;
	windata[win].rowdata = rowdata;

	return 0;
}

int display_reset_cursor(int win)
{
	windata[win].nrdata = 0;
	werase(windata[win].pad);
	return wmove(windata[win].pad, 0, 0);
}

int display_print_line(int win, int line, char *str, int bold, void *data)
{
	int attr = 0;

	if (bold)
		attr |= WA_BOLD;

	if (line == windata[win].cursor)
		attr |= WA_STANDOUT;

	if (display_set_row_data(win, line, data, attr))
		return -1;

	if (attr)
		wattron(windata[win].pad, attr);

	wprintw(windata[win].pad, "%s\n", str);

	if (attr)
		wattroff(windata[win].pad, attr);

	return 0;
}

static int display_find_keystroke(int fd, void *data);

struct find_data {
	size_t len;
	char *string;
	regex_t *reg;
	int ocursor;
	int oscrolling;
};

struct find_data *display_find_init(void)
{
	const char *regexp = "^[a-z|0-9|_|-|.]";
	struct find_data *findd;
	const size_t len = 64;
	regex_t *reg;
	char *search4;
	int maxx, maxy;

	getmaxyx(stdscr, maxy, maxx);

	reg = malloc(sizeof(*reg));
	if (!reg)
		return NULL;

	if (regcomp(reg, regexp, REG_ICASE))
		goto out_free_reg;

	search4 = malloc(len);
	if (!search4)
		goto out_free_regcomp;
	memset(search4, '\0', len);

	findd = malloc(sizeof(*findd));
	if (!findd)
		goto out_free_search4;

	findd->string = search4;
	findd->reg = reg;
	findd->len = len;

	/* save the location of the cursor on the main window in order to
	 * browse the search result
	 */
	findd->ocursor = windata[current_win].cursor;
	findd->oscrolling = windata[current_win].scrolling;

	windata[current_win].cursor = 0;
	windata[current_win].scrolling = 0;

	curs_set(1);
out:
	return findd;

out_free_search4:
	free(search4);
out_free_regcomp:
	regfree(reg);
out_free_reg:
	free(reg);

	goto out;
}

static void display_find_fini(struct find_data *findd)
{
	windata[current_win].cursor = findd->ocursor;
	windata[current_win].scrolling = findd->oscrolling;
	regfree(findd->reg);
	free(findd->string);
	free(findd);
	curs_set(0);
}

static int display_switch_to_find(int fd)
{
	struct find_data *findd;

	findd = display_find_init();
	if (!findd)
		return -1;

	if (mainloop_del(fd))
		return -1;

	if (mainloop_add(fd, display_find_keystroke, findd))
		return -1;

	if (display_show_footer(current_win, "find (esc to exit)?"))
		return -1;

	return 0;
}

static int display_keystroke(int fd, void *data)
{
	int keystroke = getch();

	switch (keystroke) {

	case KEY_RIGHT:
	case '\t':
		display_show_header(display_next_panel());
		break;

	case KEY_LEFT:
	case KEY_BTAB:
		display_show_header(display_prev_panel());
		break;

	case KEY_DOWN:
		display_next_line();
		break;

	case KEY_UP:
		display_prev_line();
		break;

	case '\r':
		display_select();
		break;

	case EOF:
	case 'q':
	case 'Q':
		return 1;

	case '/':
		return display_switch_to_find(fd);

	case 'r':
	case 'R':
		return display_refresh(current_win, true);
	default:
		return 0;
	}

	display_refresh(current_win, false);

	return 0;
}

static int display_switch_to_main(int fd)
{
	if (mainloop_del(fd))
		return -1;

	if (mainloop_add(fd, display_keystroke, NULL))
		return -1;

	if (display_show_header(current_win))
		return -1;

	if (display_show_footer(current_win, NULL))
		return -1;

	return display_refresh(current_win, false);
}

static int display_find_keystroke(int fd, void *data)
{
	struct find_data *findd = data;
	regex_t *reg = findd->reg;
	char *string = findd->string;
	int keystroke = getch();
	char match[2] = { [0] = (char)keystroke, [1] = '\0' };
	regmatch_t m[1];

	switch (keystroke) {

	case '\e':
		display_find_fini(findd);
		return display_switch_to_main(fd);

	case KEY_DOWN:
		display_next_line();
		break;

	case KEY_UP:
		display_prev_line();
		break;

	case KEY_BACKSPACE:
		if (strlen(string))
			string[strlen(string) - 1] = '\0';

		windata[current_win].cursor = 0;
		windata[current_win].scrolling = 0;

		break;

	case '\r':
		if (!windata[current_win].ops || !windata[current_win].ops->selectf)
			return 0;

		if (windata[current_win].ops->selectf())
			return -1;

		windata[current_win].cursor = 0;
		windata[current_win].scrolling = 0;

		return 0;

	default:

		/* We don't want invalid characters for a name */
		if (regexec(reg, match, 1, m, 0))
			return 0;

		if (strlen(string) < findd->len - 1)
			string[strlen(string)] = (char)keystroke;

		windata[current_win].cursor = 0;
		windata[current_win].scrolling = 0;

		break;
	}

	if (!windata[current_win].ops || !windata[current_win].ops->find)
		return 0;

	if (windata[current_win].ops->find(string))
		return -1;

	if (display_show_header(current_win))
		return -1;

	if (display_show_footer(current_win, strlen(string) ? string :
				"find (esc to exit)?"))
		return -1;

	return 0;
}

int display_init(int wdefault)
{
	int i, maxx, maxy;
	size_t array_size = sizeof(windata) / sizeof(windata[0]);

	current_win = wdefault;

	if (mainloop_add(0, display_keystroke, NULL))
		return -1;

	if (!initscr())
		return -1;

	start_color();
	use_default_colors();

	keypad(stdscr, TRUE);
	noecho();
	cbreak();
	curs_set(0);
	nonl();

	if (init_pair(PT_COLOR_DEFAULT, COLOR_WHITE, COLOR_BLACK) ||
	    init_pair(PT_COLOR_ERROR, COLOR_BLACK, COLOR_RED) ||
	    init_pair(PT_COLOR_HEADER_BAR, COLOR_WHITE, COLOR_BLACK) ||
	    init_pair(PT_COLOR_YELLOW, COLOR_WHITE, COLOR_YELLOW) ||
	    init_pair(PT_COLOR_GREEN, COLOR_WHITE, COLOR_GREEN) ||
	    init_pair(PT_COLOR_BRIGHT, COLOR_WHITE, COLOR_BLACK) ||
	    init_pair(PT_COLOR_BLUE, COLOR_WHITE, COLOR_BLUE) ||
	    init_pair(PT_COLOR_RED, COLOR_WHITE, COLOR_RED))
		return -1;

	if (atexit(display_fini))
		return -1;

	getmaxyx(stdscr, maxy, maxx);

	for (i = 0; i < array_size; i++) {

		main_win = subwin(stdscr, maxy - 2, maxx, 1, 0);
		if (!main_win)
			return -1;

		windata[i].pad = newpad(maxrows, maxx);
		if (!windata[i].pad)
			return -1;

	}

	header_win = subwin(stdscr, 1, maxx, 0, 0);
	if (!header_win)
		return -1;

	footer_win = subwin(stdscr, 1, maxx, maxy-1, 0);
	if (!footer_win)
		return -1;

	if (display_show_header(wdefault))
		return -1;

	if (display_show_footer(wdefault, NULL))
		return -1;

	return display_refresh(wdefault, true);
}

int display_column_name(const char *line)
{
	werase(main_win);
	wattron(main_win, A_BOLD);
	mvwprintw(main_win, 0, 0, "%s", line);
	wattroff(main_win, A_BOLD);
	wrefresh(main_win);

	return 0;
}

int display_register(int win, struct display_ops *ops)
{
	size_t array_size = sizeof(windata) / sizeof(windata[0]);

	if (win < 0 || win >= array_size)
		return -1;

	windata[win].ops = ops;

	return 0;
}
