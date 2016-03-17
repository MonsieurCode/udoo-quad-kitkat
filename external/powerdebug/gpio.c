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
 *     Daniel Lezcano <daniel.lezcano@linaro.org> (IBM Corporation)
 *       - initial API and implementation
 *******************************************************************************/

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#endif
#include <mntent.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/param.h>
#include <sys/stat.h>

#include "powerdebug.h"
#include "display.h"
#include "tree.h"
#include "utils.h"

#define SYSFS_GPIO "/sys/class/gpio"

struct gpio_info {
	bool expanded;
	int active_low;
	int value;
	int direction;
	int edge;
	char *prefix;
} *gpios_info;

static struct tree *gpio_tree = NULL;

static struct gpio_info *gpio_alloc(void)
{
	struct gpio_info *gi;

	gi = malloc(sizeof(*gi));
	if (gi) {
		memset(gi, -1, sizeof(*gi));
		gi->prefix = NULL;
	}

	return gi;
}

static int gpio_filter_cb(const char *name)
{
	/* let's ignore some directories in order to avoid to be
	 * pulled inside the sysfs circular symlinks mess/hell
	 * (choose the word which fit better)
	 */
	if (!strcmp(name, "device"))
		return 1;

	if (!strcmp(name, "subsystem"))
		return 1;

	if (!strcmp(name, "driver"))
		return 1;

        /* we want to ignore the gpio chips */
	if (strstr(name, "chip"))
		return 1;

        /* we are not interested by the power value */
	if (!strcmp(name, "power"))
		return 1;

	return 0;
}

static inline int read_gpio_cb(struct tree *t, void *data)
{
	struct gpio_info *gpio = t->private;
	int gpio_num;
	file_read_value(t->path, "base", "%d", &gpio_num);
	file_write_value("/sys/class/gpio", "export","%d", &gpio_num);


	file_read_value(t->path, "active_low", "%d", &gpio->active_low);
	file_read_value(t->path, "value", "%d", &gpio->value);
	file_read_value(t->path, "edge", "%d", &gpio->edge);
	file_read_value(t->path, "direction", "%d", &gpio->direction);

	return 0;
}

static int read_gpio_info(struct tree *tree)
{
	return tree_for_each(tree, read_gpio_cb, NULL);
}

static int fill_gpio_cb(struct tree *t, void *data)
{
	struct gpio_info *gpio;

	gpio = gpio_alloc();
	if (!gpio)
		return -1;
	t->private = gpio;

        /* we skip the root node but we set it expanded for its children */
	if (!t->parent) {
		gpio->expanded = true;
		return 0;
	}

	return read_gpio_cb(t, data);

}

static int fill_gpio_tree(void)
{
	return tree_for_each(gpio_tree, fill_gpio_cb, NULL);
}

static int dump_gpio_cb(struct tree *t, void *data)
{
	struct gpio_info *gpio = t->private;
	struct gpio_info *pgpio;

	if (!t->parent) {
		printf("/\n");
		gpio->prefix = "";
		return 0;
	}

	pgpio = t->parent->private;

	if (!gpio->prefix)
		if (asprintf(&gpio->prefix, "%s%s%s", pgpio->prefix,
			     t->depth > 1 ? "   ": "", t->next ? "|" : " ") < 0)
			return -1;

	printf("%s%s-- %s (", gpio->prefix,  !t->next ? "`" : "", t->name);

	if (gpio->active_low != -1)
		printf(" active_low:%d", gpio->active_low);

	if (gpio->value != -1)
		printf(", value:%d", gpio->value);

	if (gpio->edge != -1)
		printf(", edge:%d", gpio->edge);

	if (gpio->direction != -1)
		printf(", direction:%d", gpio->direction);

	printf(" )\n");

	return 0;
}

int dump_gpio_info(void)
{
	return tree_for_each(gpio_tree, dump_gpio_cb, NULL);
}

int gpio_dump(void)
{
	int ret;

	printf("\nGpio Tree :\n");
	printf("***********\n");
	ret = dump_gpio_info();
	printf("\n\n");

	return ret;
}

static char *gpio_line(struct tree *t)
{
	struct gpio_info *gpio = t->private;
	char *gpioline;

	if (asprintf(&gpioline, "%-20s %-10d %-10d %-10d %-10d", t-> name,
		     gpio->value, gpio->active_low, gpio->edge, gpio->direction) < 0)
		return NULL;

	return gpioline;
}

static int _gpio_print_info_cb(struct tree *t, void *data)
{
	int *line = data;
	char *buffer;

        /* we skip the root node of the tree */
	if (!t->parent)
		return 0;

	buffer = gpio_line(t);
	if (!buffer)
		return -1;

	display_print_line(GPIO, *line, buffer, 0, t);

	(*line)++;

	free(buffer);

	return 0;
}

static int gpio_print_info_cb(struct tree *t, void *data)
{
        /* we skip the root node of the tree */
	if (!t->parent)
		return 0;

	return _gpio_print_info_cb(t, data);
}

static int gpio_print_header(void)
{
	char *buf;
	int ret;

	if (asprintf(&buf, "%-20s %-10s %-10s %-10s %-10s",
		     "Name", "Value", "Active_low", "Edge", "Direction") < 0)
		return -1;

	ret = display_column_name(buf);

	free(buf);

	return ret;
}

static int gpio_print_info(struct tree *tree)
{
	int ret, line = 0;

	display_reset_cursor(GPIO);

	gpio_print_header();

	ret = tree_for_each(tree, gpio_print_info_cb, &line);

	display_refresh_pad(GPIO);

	return ret;
}

static int gpio_display(bool refresh)
{
	if (refresh && read_gpio_info(gpio_tree))
		return -1;

	return gpio_print_info(gpio_tree);
}

static struct display_ops gpio_ops = {
	.display = gpio_display,
};

/*
 * Initialize the gpio framework
 */
int gpio_init(void)
{
	gpio_tree = tree_load(SYSFS_GPIO, gpio_filter_cb, false);
	if (!gpio_tree)
		return -1;

	if (fill_gpio_tree())
		return -1;
#ifdef NCURES
	return display_register(GPIO, &gpio_ops);
#else
	return 0;
#endif
}
