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

#include <getopt.h>
#include <stdbool.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#ifdef NCURES
#include <ncurses.h>
#endif
#include "display.h"
#include "regulator.h"
#include "clocks.h"
#include "sensor.h"
#include "gpio.h"
#include "mainloop.h"
#include "powerdebug.h"

void usage(void)
{
	printf("Usage: powerdebug [OPTIONS]\n");
	printf("\n");
	printf("powerdebug -d [ -r ] [ -s ] [ -c [ -p <clock-name> ] ] "
		"[ -v ]\n");
	printf("powerdebug [ -r | -s | -c ]\n");
	printf("  -r, --regulator 	Show regulator information\n");
	printf("  -g, --gpio 		Show gpio information\n");
	printf("  -s, --sensor		Show sensor information\n");
	printf("  -c, --clock		Show clock information\n");
	printf("  -p, --findparents	Show all parents for a particular"
		" clock\n");
	printf("  -t, --time		Set ticktime in seconds (eg. 10.0)\n");
	printf("  -d, --dump		Dump information once (no refresh)\n");
	printf("  -v, --verbose		Verbose mode (use with -r and/or"
		" -s)\n");
	printf("  -V, --version		Show Version\n");
	printf("  -h, --help 		Help\n");
}

void version()
{
	printf("powerdebug version %s\n", VERSION);
}

/*
 * Options:
 * -r, --regulator      : regulators
 * -s, --sensor	 	: sensors
 * -c, --clock	  	: clocks
 * -g, --gpio           : gpios
 * -p, --findparents    : clockname whose parents have to be found
 * -t, --time		: ticktime
 * -d, --dump		: dump
 * -v, --verbose	: verbose
 * -V, --version	: version
 * -h, --help		: help
 * no option / default : show usage!
 */

static struct option long_options[] = {
	{ "regulator", 0, 0, 'r' },
	{ "sensor", 0, 0, 's' },
	{ "clock",  0, 0, 'c' },
	{ "gpio",  0, 0, 'g' },
	{ "findparents", 1, 0, 'p' },
	{ "time", 1, 0, 't' },
	{ "dump", 0, 0, 'd' },
	{ "verbose", 0, 0, 'v' },
	{ "version", 0, 0, 'V' },
	{ "help", 0, 0, 'h' },
	{ 0, 0, 0, 0 }
};

struct powerdebug_options {
	bool verbose;
	bool regulators;
	bool sensors;
	bool clocks;
	bool gpios;
	bool dump;
	unsigned int ticktime;
	int selectedwindow;
	char *clkname;
};

int getoptions(int argc, char *argv[], struct powerdebug_options *options)
{
	int c;

	memset(options, 0, sizeof(*options));
	options->ticktime = 10;
	options->selectedwindow = -1;

	while (1) {
		int optindex = 0;

		c = getopt_long(argc, argv, "rscgp:t:dvVh",
				long_options, &optindex);
		if (c == -1)
			break;

		switch (c) {
		case 'r':
			options->regulators = true;
			options->selectedwindow = REGULATOR;
			break;
		case 's':
			options->sensors = true;
			options->selectedwindow = SENSOR;
			break;
		case 'c':
			options->clocks = true;
			options->selectedwindow = CLOCK;
			break;
		case 'g':
			options->gpios = true;
			options->selectedwindow = GPIO;
			break;
		case 'p':
			options->clkname = strdup(optarg);
			if (!options->clkname) {
				fprintf(stderr, "failed to allocate memory");
				return -1;
			}
			options->dump = true;   /* Assume -dc in case of -p */
			options->clocks = true;
			break;
		case 't':
			options->ticktime = atoi(optarg);
			break;
		case 'd':
			options->dump = true;
			break;
		case 'v':
			options->verbose = true;
			break;
		case 'V':
			version();
			break;
		case '?':
			fprintf(stderr, "%s: Unknown option %c'.\n",
				argv[0], optopt);
		default:
			return -1;
		}
	}

	/* No system specified to be dump, let's default to all */
	if (!options->regulators && !options->clocks &&
	    !options->sensors && !options->gpios)
		options->regulators = options->clocks =
			options->sensors = options->gpios = true;

	if (options->selectedwindow == -1)
		options->selectedwindow = CLOCK;

	return 0;
}

static int powerdebug_dump(struct powerdebug_options *options)
{
	if (options->regulators)
		regulator_dump();

	if (options->clocks)
		clock_dump(options->clkname);

	if (options->sensors)
		sensor_dump();

	if (options->gpios)
		gpio_dump();

	return 0;
}
#ifdef NCURES
static int powerdebug_display(struct powerdebug_options *options)
{
	if (display_init(options->selectedwindow)) {
		printf("failed to initialize display\n");
		return -1;
	}

	if (mainloop(options->ticktime * 1000))
		return -1;

	return 0;
}
#endif

static struct powerdebug_options *powerdebug_init(void)
{
	struct powerdebug_options *options;

	options = malloc(sizeof(*options));
	if (!options)
		return NULL;

	memset(options, 0, sizeof(*options));

	return options;
}

int main(int argc, char **argv)
{
	struct powerdebug_options *options;
	int ret;

	options = powerdebug_init();
	if (!options) {
		fprintf(stderr, "not enough memory to allocate options\n");
		return 1;
	}

	if (getoptions(argc, argv, options)) {
		usage();
		return 1;
	}

	if (mainloop_init()) {
		fprintf(stderr, "failed to initialize the mainloop\n");
		return 1;
	}

	if (regulator_init()) {
		printf("not enough memory to allocate regulators info\n");
		options->regulators = false;
	}

	if (clock_init()) {
		printf("failed to initialize clock details (check debugfs)\n");
		options->clocks = false;
	}

	if (sensor_init()) {
		printf("failed to initialize sensors\n");
		options->sensors = false;
	}
	if (gpio_init()) {
		printf("failed to initialize gpios\n");
		options->gpios = false;
	}

#ifdef NCURES
	ret = options->dump ? powerdebug_dump(options) :
		powerdebug_display(options);
#else
	ret = powerdebug_dump(options);
#endif
	return ret < 0;
}
