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
 * Author:
 *     Daniel Lezcano <daniel.lezcano@linaro.org>
 *
 *******************************************************************************/

/*
 * Structure describing a node of the clock tree
 *
 * tail  : points to the last element in the list
 * next  : points to the next element in the list
 * child  : points to the child node
 * parent : points to the parent node
 * depth  : the recursive level of the node
 * path   : absolute pathname of the directory
 * name   : basename of the directory
 */
struct tree {
	struct tree *tail;
	struct tree *next;
	struct tree *prev;
	struct tree *child;
	struct tree *parent;
	char *path;
	char *name;
	void *private;
	int   nrchild;
	unsigned char depth;
};

typedef int (*tree_cb_t)(struct tree *t, void *data);

typedef int (*tree_filter_t)(const char *name);

extern struct tree *tree_load(const char *path, tree_filter_t filter, bool follow);

extern struct tree *tree_find(struct tree *tree, const char *name);

extern int tree_for_each(struct tree *tree, tree_cb_t cb, void *data);

extern int tree_for_each_reverse(struct tree *tree, tree_cb_t cb, void *data);

extern int tree_for_each_parent(struct tree *tree, tree_cb_t cb, void *data);

extern int tree_finds(struct tree *tree, const char *name, struct tree ***ptr);
