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
#ifndef __UTILS_H
#define __UTILS_H

extern int file_read_value(const char *path, const char *name,
                           const char *format, void *value);
extern int file_write_value(const char *path, const char *name,
                           const char *format, void *value);


#endif
