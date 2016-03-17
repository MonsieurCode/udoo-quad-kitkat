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

#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#include <sys/types.h>
#include <stdbool.h>
#include <dirent.h>
#include <string.h>
#include <stdlib.h>

#include "powerdebug.h"
#include "display.h"
#include "sensor.h"
#include "tree.h"
#include "utils.h"

#define SYSFS_SENSOR "/sys/class/hwmon"

static struct tree *sensor_tree;

struct temp_info {
	char name[NAME_MAX];
	int temp;
};

struct fan_info {
	char name[NAME_MAX];
	int rpms;
};

struct sensor_info {
	char name[NAME_MAX];
	struct temp_info *temperatures;
	struct fan_info *fans;
	short nrtemps;
	short nrfans;
};

static int sensor_dump_cb(struct tree *tree, void *data)
{
	int i;
	struct sensor_info *sensor = tree->private;

	if (!strlen(sensor->name))
		return 0;

	printf("%s\n", sensor->name);

	for (i = 0; i < sensor->nrtemps; i++)
		printf(" %s %.1f °C/V\n", sensor->temperatures[i].name,
		       (float)sensor->temperatures[i].temp / 1000);

	for (i = 0; i < sensor->nrfans; i++)
		printf(" %s %d rpm\n", sensor->fans[i].name,
		       sensor->fans[i].rpms);

	return 0;
}

int sensor_dump(void)
{
	printf("\nSensor Information:\n");
	printf("*******************\n\n");

	return tree_for_each(sensor_tree, sensor_dump_cb, NULL);
}

static struct sensor_info *sensor_alloc(void)
{
	struct sensor_info *sensor;

	sensor = malloc(sizeof(*sensor));
	if (sensor)
		memset(sensor, 0, sizeof(*sensor));

	return sensor;
}

static int read_sensor_cb(struct tree *tree, void *data)
{
	DIR *dir;
	int value;
        struct dirent dirent, *direntp;
	struct sensor_info *sensor = tree->private;

	int nrtemps = 0;
	int nrfans = 0;

	dir = opendir(tree->path);
	if (!dir)
		return -1;

	file_read_value(tree->path, "name", "%s", sensor->name);

	while (!readdir_r(dir, &dirent, &direntp)) {

                if (!direntp)
                        break;

		if (direntp->d_type != DT_REG)
			continue;

		if (!strncmp(direntp->d_name, "temp", 4)) {

			if (file_read_value(tree->path, direntp->d_name, "%d",
					    &value))
				continue;

			sensor->temperatures =
				realloc(sensor->temperatures,
					sizeof(struct temp_info) * (nrtemps + 1));
			if (!sensor->temperatures)
				continue;

			strcpy(sensor->temperatures[nrtemps].name,
			       direntp->d_name);
			sensor->temperatures[nrtemps].temp = value;

			nrtemps++;
		}

		if (!strncmp(direntp->d_name, "fan", 3)) {

			if (file_read_value(tree->path, direntp->d_name, "%d",
					    &value))
				continue;

			sensor->fans =
				realloc(sensor->fans,
					sizeof(struct temp_info) * (nrfans + 1));
			if (!sensor->fans)
				continue;

			strcpy(sensor->fans[nrfans].name,
			       direntp->d_name);
			sensor->fans[nrfans].rpms = value;

			nrfans++;
		}
	}

	sensor->nrtemps = nrtemps;
	sensor->nrfans = nrfans;

	closedir(dir);

	return 0;
}

static int fill_sensor_cb(struct tree *t, void *data)
{
	struct sensor_info *sensor;

	sensor = sensor_alloc();
	if (!sensor)
		return -1;

	t->private = sensor;

	if (!t->parent)
		return 0;

	return read_sensor_cb(t, data);
}

static int fill_sensor_tree(void)
{
	return tree_for_each(sensor_tree, fill_sensor_cb, NULL);
}

static int sensor_filter_cb(const char *name)
{
	/* let's ignore some directories in order to avoid to be
	 * pulled inside the sysfs circular symlinks mess/hell
	 * (choose the word which fit better)
	 */
	if (!strcmp(name, "subsystem"))
		return 1;

	if (!strcmp(name, "driver"))
		return 1;

	if (!strcmp(name, "hwmon"))
		return 1;

	if (!strcmp(name, "power"))
		return 1;

	return 0;
}

static int sensor_display_cb(struct tree *t, void *data)
{
	struct sensor_info *sensor = t->private;
	int *line = data;
	char buf[1024];
	int i;

	if (!strlen(sensor->name))
		return 0;

	sprintf(buf, "%s", sensor->name);
	display_print_line(SENSOR, *line, buf, 1, t);

	(*line)++;

	for (i = 0; i < sensor->nrtemps; i++) {
		sprintf(buf, " %-35s%.1f", sensor->temperatures[i].name,
		       (float)sensor->temperatures[i].temp / 1000);
		display_print_line(SENSOR, *line, buf, 0, t);
		(*line)++;
	}

	for (i = 0; i < sensor->nrfans; i++) {
		sprintf(buf, " %-35s%d rpm", sensor->fans[i].name,
			sensor->fans[i].rpms);
		display_print_line(SENSOR, *line, buf, 0, t);
		(*line)++;
	}

	return 0;
}

static int sensor_print_header(void)
{
	char *buf;
	int ret;

	if (asprintf(&buf, "%-36s%s", "Name", "Value") < 0)
		return -1;

	ret = display_column_name(buf);

	free(buf);

	return ret;
}

static int sensor_display(bool refresh)
{
	int ret, line = 0;

	display_reset_cursor(SENSOR);

	sensor_print_header();

	ret = tree_for_each(sensor_tree, sensor_display_cb, &line);

	display_refresh_pad(SENSOR);

	return ret;
}

static struct display_ops sensor_ops = {
	.display = sensor_display,
};

int sensor_init(void)
{
	sensor_tree = tree_load(SYSFS_SENSOR, sensor_filter_cb, false);
	if (!sensor_tree)
		return -1;

	if (fill_sensor_tree())
		return -1;
#ifdef NCURES
	return display_register(SENSOR, &sensor_ops);
#else
	return 0;
#endif
}
