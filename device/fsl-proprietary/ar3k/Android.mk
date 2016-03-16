ifeq ($(BOARD_USE_AR3K_BLUETOOTH),true)

LOCAL_PATH:= $(call my-dir)
define include-ar3k-prebuilt
    include $$(CLEAR_VARS)
    LOCAL_MODULE := $(4)
    LOCAL_MODULE_STEM := $(3)
    LOCAL_MODULE_TAGS := debug eng optional
    LOCAL_MODULE_CLASS := ETC
    LOCAL_MODULE_PATH := $(2)
    LOCAL_SRC_FILES := $(1)
    ALL_DEFAULT_INSTALLED_MODULES += $(LOCAL_MODULE)
    include $$(BUILD_PREBUILT)
endef

define add-ar3k-prebuilt-file
    $(eval $(include-ar3k-prebuilt))
endef

# ar3001 firmware
ar3k_hw3001_dst_dir := $(TARGET_OUT)/etc/firmware/ar3k/30101
$(call add-ar3k-prebuilt-file,30101/ar3kbdaddr.pst,$(ar3k_hw3001_dst_dir),ar3kbdaddr.pst,ar3kbdaddr_ar3001)
$(call add-ar3k-prebuilt-file,30101/PS_ASIC.pst,$(ar3k_hw3001_dst_dir),PS_ASIC.pst,PS_ASIC_ar3001)
$(call add-ar3k-prebuilt-file,30101/RamPatch.txt,$(ar3k_hw3001_dst_dir),RamPatch.txt,RamPatch_ar3001)
ar3k_hw3001_dst_dir :=

# ar3002 firmware
ar3k_hw1020200_dst_dir := $(TARGET_OUT)/etc/firmware/ar3k/1020200
$(call add-ar3k-prebuilt-file,1020200/ar3kbdaddr.pst,$(ar3k_hw1020200_dst_dir),ar3kbdaddr.pst,ar3kbdaddr_ar3002)
$(call add-ar3k-prebuilt-file,1020200/PS_ASIC.pst,$(ar3k_hw1020200_dst_dir),PS_ASIC.pst,PS_ASIC_ar3002)
$(call add-ar3k-prebuilt-file,1020200/RamPatch.txt,$(ar3k_hw1020200_dst_dir),RamPatch.txt,RamPatch_ar3002)

ar3k_hw1020200_dst_dir :=

endif
