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
 *     Daniel Lezcano <daniel.lezcano@linaro.org> (IBM Corporation)
 *       - rewrote code and API based on the tree
 *******************************************************************************/

#include "regulator.h"

#define SYSFS_REGULATOR "/sys/class/regulator"
#define VALUE_MAX 16

#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#include <sys/types.h>
#include <stdbool.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>
#include "display.h"
#include "powerdebug.h"
#include "tree.h"
#include "utils.h"

struct regulator_info {
	char name[NAME_MAX];
	char state[VALUE_MAX];
	char status[VALUE_MAX];
	char type[VALUE_MAX];
	char opmode[VALUE_MAX];
	int microvolts;
	int min_microvolts;
	int max_microvolts;
	int microamps;
	int min_microamps;
	int max_microamps;
	int requested_microamps;
	int num_users;
};

struct regulator_data {
	const char *name;
	const char *ifmt;
	const char *ofmt;
	bool derefme;
};

static struct regulator_data regdata[] = {
	{ "name",           "%s", "\tname: %s\n"                 },
	{ "status",         "%s", "\tstatus: %s\n"               },
	{ "state",          "%s", "\tstate: %s\n"                },
	{ "type",           "%s", "\ttype: %s\n"                 },
	{ "num_users",      "%d", "\tnum_users: %d\n",      true },
	{ "microvolts",     "%d", "\tmicrovolts: %d\n",     true },
	{ "max_microvolts", "%d", "\tmax_microvolts: %d\n", true },
	{ "min_microvolts", "%d", "\tmin_microvolts: %d\n", true },
};

static struct tree *reg_tree;

static struct regulator_info *regulator_alloc(void)
{
	struct regulator_info *regi;

	regi = malloc(sizeof(*regi));
	if (regi)
		memset(regi, 0, sizeof(*regi));

	return regi;
}

static int regulator_dump_cb(struct tree *tree, void *data)
{
	int i;
	char buffer[NAME_MAX];
	size_t nregdata = sizeof(regdata) / sizeof(regdata[0]);

	if (!strncmp("regulator.", tree->name, strlen("regulator.")))
		printf("\n%s:\n", tree->name);

	for (i = 0; i < nregdata; i++) {

		if (file_read_value(tree->path, regdata[i].name,
				    regdata[i].ifmt, buffer))
			continue;

		printf(regdata[i].ofmt, regdata[i].derefme ?
		       *((int *)buffer) : buffer);
	}

	return 0;
}

int regulator_dump(void)
{
	printf("\nRegulator Information:\n");
	printf("*********************\n\n");

	return tree_for_each(reg_tree, regulator_dump_cb, NULL);
}

static int regulator_display_cb(struct tree *t, void *data)
{
	struct regulator_info *reg = t->private;
	int *line = data;
	char *buf;

        /* we skip the root node of the tree */
	if (!t->parent)
		return 0;

	if (!strlen(reg->name))
		return 0;

	if (asprintf(&buf, "%-11s %-11s %-11s %-11s %-11d %-11d %-11d %-12d",
		     reg->name, reg->status, reg->state, reg->type,
		     reg->num_users, reg->microvolts, reg->min_microvolts,
		     reg->max_microvolts) < 0)
		return -1;

	display_print_line(REGULATOR, *line, buf, reg->num_users, t);

	(*line)++;

	free(buf);

	return 0;
}

static int regulator_print_header(void)
{
	char *buf;
	int ret;

	if (asprintf(&buf, "%-11s %-11s %-11s %-11s %-11s %-11s %-11s %-12s",
		     "Name", "Status", "State", "Type", "Users", "Microvolts",
		     "Min u-volts", "Max u-volts") < 0)
		return -1;

	ret = display_column_name(buf);

	free(buf);

	return ret;

}

static int regulator_display(bool refresh)
{
	int ret, line = 0;

	display_reset_cursor(REGULATOR);

	regulator_print_header();

	ret = tree_for_each(reg_tree, regulator_display_cb, &line);

	display_refresh_pad(REGULATOR);

	return ret;
}

static int regulator_filter_cb(const char *name)
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

	return 0;
}

static inline int read_regulator_cb(struct tree *t, void *data)
{
	struct regulator_info *reg = t->private;

	file_read_value(t->path, "name", "%s", reg->name);
	file_read_value(t->path, "state", "%s", reg->state);
	file_read_value(t->path, "status", "%s", reg->status);
	file_read_value(t->path, "type", "%s", reg->type);
	file_read_value(t->path, "opmode", "%s", reg->opmode);
	file_read_value(t->path, "num_users", "%d", &reg->num_users);
	file_read_value(t->path, "microvolts", "%d", &reg->microvolts);
	file_read_value(t->path, "min_microvolts", "%d", &reg->min_microvolts);
	file_read_value(t->path, "max_microvolts", "%d", &reg->max_microvolts);
	file_read_value(t->path, "microamps", "%d", &reg->microamps);
	file_read_value(t->path, "min_microamps", "%d", &reg->min_microamps);
	file_read_value(t->path, "max_microamps", "%d", &reg->max_microamps);

	return 0;
}

static int fill_regulator_cb(struct tree *t, void *data)
{
	struct regulator_info *reg;

	reg = regulator_alloc();
	if (!reg)
		return -1;
	t->private = reg;

        /* we skip the root node but we set it expanded for its children */
	if (!t->parent)
		return 0;

	return read_regulator_cb(t, data);
}

static int fill_regulator_tree(void)
{
	return tree_for_each(reg_tree, fill_regulator_cb, NULL);
}

static struct display_ops regulator_ops = {
	.display = regulator_display,
};

int regulator_init(void)
{
	reg_tree = tree_load(SYSFS_REGULATOR, regulator_filter_cb, false);
	if (!reg_tree)
		return -1;

	if (fill_regulator_tree())
		return -1;
#ifdef NCURES
	return display_register(REGULATOR, &regulator_ops);
#else
	return 0;
#endif
}
