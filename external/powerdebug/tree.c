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

#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <dirent.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

#include "tree.h"

/*
 * Allocate a tree structure and initialize the different fields.
 *
 * @path  : the absolute path to the directory
 * @depth : the depth in the tree
 * Returns a tree structure on success, NULL otherwise
 */
static inline struct tree *tree_alloc(const char *path, int depth)
{
	struct tree *t;

	t = malloc(sizeof(*t));
	if (!t)
		return NULL;

	/* Full pathname */
	t->path = strdup(path);
	if (!t->path) {
		free(t);
		return NULL;
	}

	/* Basename pointer on the full path name */
	t->name = strrchr(t->path, '/') + 1;

	t->depth = depth;
	t->tail = t;
	t->child = NULL;
	t->parent = NULL;
	t->next = NULL;
	t->prev = NULL;
	t->private = NULL;
	t->nrchild = 0;

	return t;
}

/*
 * Free a tree structure and the fields we allocated in the
 * tree_alloc function.
 *
 * @t : the tree structure to be freed
 */
static inline void tree_free(struct tree *t)
{
	free(t->path);
	free(t);
}

/*
 * Add at the end of the list the new list element.
 *
 * @head : the list to be appened
 * @new  : the new element to be added at the end of the list
 */
static inline void tree_add_tail(struct tree *head, struct tree *new)
{
	new->prev = head->tail;
	head->tail->next = new;
	head->tail = new;
}

/*
 * Add a child in to a parent list, at the end of this list.
 *
 * @parent : the parent list to add the child
 * @child  : the child to be added
 */
static inline void tree_add_child(struct tree *parent, struct tree *child)
{
	child->parent = parent;

	if (parent->child)
		return tree_add_tail(parent->child, child);

	parent->child = child;
}

/*
 * This function will browse the directory structure and build a
 * tree reflecting the content of the directory tree.
 *
 * @tree   : the root node of the tree
 * @filter : a callback to filter out the directories
 * Returns 0 on success, -1 otherwise
 */
static int tree_scan(struct tree *tree, tree_filter_t filter, bool follow)
{
	DIR *dir;
	char *basedir, *newpath;
	struct dirent dirent, *direntp;
	struct stat s;
	int ret = 0;

	dir = opendir(tree->path);
	if (!dir)
		return -1;

	while (!readdir_r(dir, &dirent, &direntp)) {

		struct tree *child;

                if (!direntp)
                        break;

                if (direntp->d_name[0] == '.')
                        continue;

		if (filter && filter(direntp->d_name))
			continue;

		ret = asprintf(&basedir, "%s", tree->path);
		if (ret < 0)
			return -1;

		ret = basename(basedir) ? 0 : -1;
		if (ret < 0)
			goto out_free_basedir;

		ret = asprintf(&newpath, "%s/%s", basedir, direntp->d_name);
		if (ret < 0)
			goto out_free_basedir;

		ret = stat(newpath, &s);
		if (ret)
			goto out_free_newpath;

		if (S_ISDIR(s.st_mode) || (S_ISLNK(s.st_mode) && follow)) {

			ret = -1;

			child = tree_alloc(newpath, tree->depth + 1);
			if (!child)
				goto out_free_newpath;

			tree_add_child(tree, child);

			tree->nrchild++;

			ret = tree_scan(child, filter, follow);
		}

	out_free_newpath:
		free(newpath);

	out_free_basedir:
		free(basedir);

		if (ret)
			break;
	}

	closedir(dir);

	return ret;
}

/*
 * This function takes the topmost directory path and populate the
 * directory tree structures.
 *
 * @tree : a path to the topmost directory path
 * Returns a tree structure corresponding to the root node of the
 * directory tree representation on success, NULL otherwise
 */
struct tree *tree_load(const char *path, tree_filter_t filter, bool follow)
{
	struct tree *tree;

	tree = tree_alloc(path, 0);
	if (!tree)
		return NULL;

	if (tree_scan(tree, filter, follow)) {
		tree_free(tree);
		return NULL;
	}

	return tree;
}

/*
 * This function will go over the tree passed as parameter and
 * will call the callback passed as parameter for each node.
 *
 * @tree : the topmost node where we begin to browse the tree
 * Returns 0 on success, < 0 otherwise
 */
int tree_for_each(struct tree *tree, tree_cb_t cb, void *data)
{
	if (!tree)
		return 0;

	if (cb(tree, data))
		return -1;

	if (tree_for_each(tree->child, cb, data))
		return -1;

	return tree_for_each(tree->next, cb, data);
}

/*
 * This function will go over the tree passed as parameter at the reverse
 * order and will call the callback passed as parameter for each.
 * @tree : the lower node where we begin to browse the tree at the reverse
 * order
 * cb : a callback for each node the function will go over
 * data : some private data to be passed across the callbacks
 * Returns 0 on success, < 0 otherwise
 */
int tree_for_each_reverse(struct tree *tree, tree_cb_t cb, void *data)
{
	if (!tree)
		return 0;

	if (cb(tree, data))
		return -1;

	if (tree_for_each_reverse(tree->prev, cb, data))
		return -1;

	return tree_for_each_reverse(tree->parent, cb, data);
}


/*
 * The function will go over all the parent of the specified node passed
 * as parameter.
 * @tree : the child node from where we back path to the parent
 * cb : a callback for each node the function will go over
 * data : some private data to be passed across the callbacks
 * Returns 0 on success, < 0 otherwise
 */
int tree_for_each_parent(struct tree *tree, tree_cb_t cb, void *data)
{
	if (!tree)
		return 0;

	if (tree_for_each_parent(tree->parent, cb, data))
		return -1;

	return cb(tree, data);
}

/*
 * The function will return the first node which match with the name as
 * parameter.
 * @tree : the tree where we begin to find
 * @name : the name of the node the function must look for.
 * Returns a pointer to the tree structure if found, NULL otherwise.
 */
struct tree *tree_find(struct tree *tree, const char *name)
{
	struct tree *t;

	if (!tree)
		return NULL;

	if (!strcmp(tree->name, name))
		return tree;

	t = tree_find(tree->child, name);
	if (t)
		return t;

	return tree_find(tree->next, name);
}

struct struct_find {
	int nr;
	const char *name;
	struct tree ***ptree;
};

static int tree_finds_cb(struct tree *tree, void *data)
{
	struct struct_find *sf = data;

	if (!strlen(sf->name))
		return 0;

	if (strncmp(sf->name, tree->name, strlen(sf->name)))
		return 0;

	if (sf->ptree)
		(*(sf->ptree))[sf->nr] = tree;

	sf->nr++;

	return 0;
}

/*
 * This function will search for all the nodes where the name begin
 * with the name passed as parameter. *Note* the function allocates
 * the array, it is up to the caller to free this array.
 * @tree : the topmost node of the tree where we being to search
 * @name : the name to find in the tree
 * @ptr  : a pointer to a pointer of pointer of tree structure :)
 * Returns the number of elements found in the tree, < 0 if something
 * went wrong.
 */
int tree_finds(struct tree *tree, const char *name, struct tree ***ptr)
{
	struct struct_find sf = { .nr = 0, .ptree = NULL, .name = name };
	int nmatch;

	/* first pass : count # of matching nodes */
	tree_for_each(tree, tree_finds_cb, &sf);

	/* no match */
	if (!sf.nr)
		return 0;

	*ptr = malloc(sizeof(struct tree *) * sf.nr);
	if (!*ptr)
		return -1;

	/* store the result as it will be overwritten by the next call */
	nmatch = sf.nr;
	sf.nr = 0;
	sf.ptree = ptr;

	/* second pass : fill with the matching nodes */
	tree_for_each(tree, tree_finds_cb, &sf);

	return nmatch;
}
