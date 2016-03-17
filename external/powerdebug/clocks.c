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
 *
 *     Daniel Lezcano <daniel.lezcano@linaro.org> (IBM Corporation)
 *       - Rewrote code and API
 *
 *******************************************************************************/

#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#endif
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/param.h>
#include <mntent.h>
#include <sys/stat.h>

#include "powerdebug.h"
#include "display.h"
#include "clocks.h"
#include "tree.h"
#include "utils.h"

struct clock_info {
	int flags;
	float rate;
	int usecount;
	bool expanded;
	char *prefix;
} *clocks_info;

static struct tree *clock_tree = NULL;

static int locate_debugfs(char *clk_path)
{
	strcpy(clk_path, "/sys/kernel/debug");
	return 0;
}

static struct clock_info *clock_alloc(void)
{
	struct clock_info *ci;

	ci = malloc(sizeof(*ci));
	if (ci)
		memset(ci, 0, sizeof(*ci));

	return ci;
}

static inline const char *clock_rate(float *rate)
{
        float r;

        /* GHZ */
        r = *rate ;
        if (r >= 1000000000) {
                *rate = r/1000000000;
                return "GHZ";
        }

        /* MHZ */
	else if (r>=1000000) {
                *rate = r/1000000;
                return "MHZ";
        }

        /* KHZ */
	else if (r>=1000) {
                *rate = r/1000;
                return "KHZ";
        }
	else 
                *rate = r;
                return "HZ";

        return "";
}

static int dump_clock_cb(struct tree *t, void *data)
{
	struct clock_info *clk = t->private;
	struct clock_info *pclk;
	const char *unit;
	int ret = 0;
	float rate = clk->rate;

	if (!t->parent) {
		printf("/\n");
		clk->prefix = "";
		return 0;
	}

	pclk = t->parent->private;

	if (!clk->prefix)
		ret = asprintf(&clk->prefix, "%s%s%s", pclk->prefix,
			       t->depth > 1 ? "   ": "", t->next ? "|" : " ");
	if (ret < 0)
		return -1;

	unit = clock_rate(&rate);

	printf("%s%s-- %s (flags:0x%x, usecount:%d, rate: %f %s)\n",
	       clk->prefix,  !t->next ? "`" : "", t->name, clk->flags,
	       clk->usecount, rate, unit);

	return 0;
}

int dump_clock_info(void)
{
	return tree_for_each(clock_tree, dump_clock_cb, NULL);
}

static int dump_all_parents(char *clkarg)
{
	struct tree *tree;

	tree = tree_find(clock_tree, clkarg);
	if (!tree) {
		printf("Clock NOT found!\n");
		return -1;
	}

	return tree_for_each_parent(tree, dump_clock_cb, NULL);
}

static inline int read_clock_cb(struct tree *t, void *data)
{
	struct clock_info *clk = t->private;

	file_read_value(t->path, "flags", "%x", &clk->flags);
	file_read_value(t->path, "rate", "%f", &clk->rate);
	file_read_value(t->path, "usecount", "%d", &clk->usecount);

	return 0;
}

static int read_clock_info(struct tree *tree)
{
	return tree_for_each(tree, read_clock_cb, NULL);
}

static int fill_clock_cb(struct tree *t, void *data)
{
	struct clock_info *clk;

	clk = clock_alloc();
	if (!clk)
		return -1;
	t->private = clk;

        /* we skip the root node but we set it expanded for its children */
	if (!t->parent) {
		clk->expanded = true;
		return 0;
	}

	return read_clock_cb(t, data);
}

static int fill_clock_tree(void)
{
	return tree_for_each(clock_tree, fill_clock_cb, NULL);
}

static int is_collapsed(struct tree *t, void *data)
{
	struct clock_info *clk = t->private;

	if (!clk->expanded)
		return 1;

	return 0;
}

static char *clock_line(struct tree *t)
{
	struct clock_info *clk;
	float rate;
	const char *clkunit;
	char *clkrate, *clkname, *clkline = NULL;

	clk = t->private;
	rate = clk->rate;
	clkunit = clock_rate(&rate);

	if (asprintf(&clkname, "%*s%s", (t->depth - 1) * 2, "", t->name) < 0)
		return NULL;

	if (asprintf(&clkrate, "%d%s", rate, clkunit) < 0)
		goto free_clkname;

	if (asprintf(&clkline, "%-55s 0x%-16x %-12s %-9d %-8d", clkname,
		     clk->flags, clkrate, clk->usecount, t->nrchild) < 0)
		goto free_clkrate;

free_clkrate:
	free(clkrate);
free_clkname:
	free(clkname);

	return clkline;
}

static int _clock_print_info_cb(struct tree *t, void *data)
{
	struct clock_info *clock = t->private;
	int *line = data;
	char *buffer;

        /* we skip the root node of the tree */
	if (!t->parent)
		return 0;

	buffer = clock_line(t);
	if (!buffer)
		return -1;

	display_print_line(CLOCK, *line, buffer, clock->usecount, t);

	(*line)++;

	free(buffer);

	return 0;
}

static int clock_print_info_cb(struct tree *t, void *data)
{
        /* we skip the root node of the tree */
	if (!t->parent)
		return 0;

        /* show the clock when *all* its parent is expanded */
	if (tree_for_each_parent(t->parent, is_collapsed, NULL))
		return 0;

	return _clock_print_info_cb(t, data);
}

static int clock_print_header(void)
{
	char *buf;
	int ret;

	if (asprintf(&buf, "%-55s %-16s %-12s %-9s %-8s",
		     "Name", "Flags", "Rate", "Usecount", "Children") < 0)
		return -1;

	ret = display_column_name(buf);

	free(buf);

	return ret;
}

static int clock_print_info(struct tree *tree)
{
	int ret, line = 0;

	display_reset_cursor(CLOCK);

	clock_print_header();

	ret = tree_for_each(tree, clock_print_info_cb, &line);

	display_refresh_pad(CLOCK);

	return ret;
}

static int clock_select(void)
{
	struct tree *t = display_get_row_data(CLOCK);
	struct clock_info *clk = t->private;

	clk->expanded = !clk->expanded;

	return 0;
}

/*
 * Read the clock information and fill the tree with the information
 * found in the files. Then print the result to the text based interface
 * Return 0 on success, < 0 otherwise
 */
static int clock_display(bool refresh)
{
	if (refresh && read_clock_info(clock_tree))
		return -1;

	return clock_print_info(clock_tree);
}

static int clock_find(const char *name)
{
	struct tree **ptree = NULL;
	int i, nr, line = 0, ret = 0;

	nr = tree_finds(clock_tree, name, &ptree);

	display_reset_cursor(CLOCK);

	for (i = 0; i < nr; i++) {

		ret = _clock_print_info_cb(ptree[i], &line);
		if (ret)
			break;

	}

	display_refresh_pad(CLOCK);

	free(ptree);

	return ret;
}

static int clock_selectf(void)
{
	struct tree *t = display_get_row_data(CLOCK);
	int line = 0;

	display_reset_cursor(CLOCK);

	if (tree_for_each_parent(t, _clock_print_info_cb, &line))
		return -1;

	return display_refresh_pad(CLOCK);
}

/*
 * Read the clock information and fill the tree with the information
 * found in the files. Then dump to stdout a formatted result.
 * @clk : a name for a specific clock we want to show
 * Return 0 on success, < 0 otherwise
 */
int clock_dump(char *clk)
{
	int ret;

	if (read_clock_info(clock_tree))
		return -1;

	if (clk) {
		printf("\nParents for \"%s\" Clock :\n\n", clk);
		ret = dump_all_parents(clk);
		printf("\n\n");
	} else {
		printf("\nClock Tree :\n");
		printf("**********\n");
		ret = dump_clock_info();
		printf("\n\n");
	}

	return ret;
}

static struct display_ops clock_ops = {
	.display = clock_display,
	.select  = clock_select,
	.find    = clock_find,
	.selectf = clock_selectf,
};

/*
 * Initialize the clock framework
 */
int clock_init(void)
{
	char clk_dir_path[PATH_MAX];

	if (locate_debugfs(clk_dir_path))
		return -1;

	sprintf(clk_dir_path, "%s/clock", clk_dir_path);

	if (access(clk_dir_path, F_OK))
		return -1;

	clock_tree = tree_load(clk_dir_path, NULL, false);
	if (!clock_tree)
		return -1;

	if (fill_clock_tree())
		return -1;
#ifdef NCURES
	return display_register(CLOCK, &clock_ops);
#else
	return 0;
#endif
}
