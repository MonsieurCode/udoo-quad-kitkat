LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)


LOCAL_MODULE_TAGS := optional
LOCAL_SHARED_LIBRARIES := libstlport
ifdef NCURES
LOCAL_STATIC_LIBRARIES := libncurses
endif
LOCAL_MODULE := powerdebug

LOCAL_CPPFLAGS += \
		-DDISABLE_I18N \
		-DDISABLE_TRYCATCH \
		-DNCURSES_NOMACROS \
		-DDISABLE_WSTRING \
		-DDEFAULT_TERM=\"xterm\" \
		-DTERMINFO_PATH=\"/system/etc/terminfo\" \
		-DDEFINE_ETHTOOL_CMD \

LOCAL_C_INCLUDES += external/stlport/stlport/ \
					external/stlport/stlport/stl \
					external/stlport/stlport/using/h/ \
					bionic \
					external/ncurses \
					external/ncurses/lib \
					external/ncurses/include \
					external/ncurses/include/ncurses
ifdef NCURES
LOCAL_SRC_FILES += \
	powerdebug.c sensor.c clocks.c regulator.c \
	display.c tree.c utils.c mainloop.c gpio.c
else
LOCAL_SRC_FILES += \
	powerdebug.c sensor.c clocks.c regulator.c \
	tree.c utils.c mainloop.c gpio.c

endif
include $(BUILD_EXECUTABLE)
