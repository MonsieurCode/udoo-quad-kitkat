ifeq ($(BOARD_WLAN_DEVICE),$(filter $(BOARD_WLAN_DEVICE), qcwcn UNITE))
    include $(call all-subdir-makefiles)
endif
