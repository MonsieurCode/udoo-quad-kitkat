ifeq ($(BOARD_WLAN_DEVICE),$(filter $(BOARD_WLAN_DEVICE), REALTEK UNITE))
	include $(call all-subdir-makefiles)
endif	

