/*******************************************************************************
 * Copyright (C) 2011, Linaro Limited.
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

#define _GNU_SOURCE
#include <stdio.h>
#undef _GNU_SOURCE
#include <stdlib.h>

/*
 * This functions is a helper to read a specific file content and store
 * the content inside a variable pointer passed as parameter, the format
 * parameter gives the variable type to be read from the file.
 *
 * @path : directory path containing the file
 * @name : name of the file to be read
 * @format : the format of the format
 * @value : a pointer to a variable to store the content of the file
 * Returns 0 on success, -1 otherwise
 */
int file_read_value(const char *path, const char *name,
                    const char *format, void *value)
{
        FILE *file;
        char *rpath;
        int ret;

        ret = asprintf(&rpath, "%s/%s", path, name);
        if (ret < 0)
                return ret;

        file = fopen(rpath, "r");
        if (!file) {
                ret = -1;
                goto out_free;
        }

        ret = fscanf(file, format, value) == EOF ? -1 : 0;

        fclose(file);
out_free:
        free(rpath);
        return ret;
}


/*
 * This functions is a helper to write a specific file content and store
 * the content inside a variable pointer passed as parameter, the format
 * parameter gives the variable type to be read from the file.
 *
 * @path : directory path containing the file
 * @name : name of the file to be read
 * @format : the format of the format
 * @value : a pointer to a variable to store the content of the file
 * Returns 0 on success, -1 otherwise
 */
int file_write_value(const char *path, const char *name,
                    const char *format, void *value)
{
        FILE *file;
        char *rpath;
        int ret;

        ret = asprintf(&rpath, "%s/%s", path, name);
        if (ret < 0)
                return ret;

        file = fopen(rpath, "w");
        if (!file) {
                ret = -1;
                goto out_free;
        }

        ret = fprintf(file, format, value) == EOF ? -1 : 0;

        fclose(file);
out_free:
        free(rpath);
        return ret;
}
