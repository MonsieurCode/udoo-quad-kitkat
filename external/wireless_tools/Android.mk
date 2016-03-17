LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= iwlib.c
LOCAL_CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wpointer-arith -Wcast-qual -Winline -MMD -fPIC
LOCAL_MODULE := libiw
LOCAL_STATIC_LIBRARIES := libcutils libc libm
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := iwconfig.c
LOCAL_CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wpointer-arith -Wcast-qual -Winline -MMD -fPIC
LOCAL_MODULE:= iwconfig
LOCAL_STATIC_LIBRARIES := libcutils libc libm libiw
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := iwlist.c iwlib.h
LOCAL_CFLAGS += -Wstrict-prototypes -Wmissing-prototypes -Wshadow -Wpointer-arith -Wcast-qual -Winline -MMD -fPIC
LOCAL_MODULE:= iwlist
LOCAL_STATIC_LIBRARIES := libcutils libc libm libiw
include $(BUILD_EXECUTABLE)
