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

typedef int (*mainloop_callback_t)(int fd, void *data);

extern int mainloop(unsigned int timeout);
extern int mainloop_add(int fd, mainloop_callback_t cb, void *data);
extern int mainloop_del(int fd);
extern int mainloop_init(void);
extern void mainloop_fini(void);
