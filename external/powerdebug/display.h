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

enum { CLOCK, REGULATOR, SENSOR, GPIO };

struct display_ops {
	int (*display)(bool refresh);
	int (*select)(void);
	int (*find)(const char *);
	int (*selectf)(void);
};

extern int display_print_line(int window, int line, char *str,
			      int bold, void *data);

extern int display_refresh_pad(int window);
extern int display_reset_cursor(int window);
extern void *display_get_row_data(int window);

extern int display_init(int wdefault);
extern int display_register(int win, struct display_ops *ops);
extern int display_column_name(const char *line);

#define NAME_MAX 255
