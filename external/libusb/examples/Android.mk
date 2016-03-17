LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)

LOCAL_SRC_FILES:= lsusb.c

LOCAL_C_INCLUDES += \
	  external/libusb/

LOCAL_SHARED_LIBRARIES := \
	  libcutils \
	  liblog \
	  libusb

LOCAL_MODULE := lsusb
include $(BUILD_EXECUTABLE)
