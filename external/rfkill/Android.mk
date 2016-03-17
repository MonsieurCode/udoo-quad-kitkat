LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_SRC_FILES:= rfkill.c
LOCAL_MODULE := rfkill
include $(BUILD_EXECUTABLE)
