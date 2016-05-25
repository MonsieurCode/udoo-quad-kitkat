# udoo-quad-kitkat

Udoo Quad KitKat Source (Incomplete)

# Missing Files

These files were too large for GitHub to accept. Consider storing them in a publicly linked zip file on Google Drive, then adding them in on initialization.

    external/chromium-trace/trace-viewer/test_data/theverge_trace.json
    external/eclipse-basebuilder/src/eclipse-sourceBuild-srcIncluded-3.6.2.zip
    frameworks/base/media/tests/contents/media_api/videoeditor/H264_BP_640x480_15fps_384kbps_60_0.mp4
    prebuilts/eclipse/deltapack/eclipse-3.7.2-delta-pack.zip
    prebuilts/eclipse/deltapack/eclipse-4.2.2-delta-pack.zip
    prebuilts/eclipse/platform/org.eclipse.platform-3.7.2.zip
    prebuilts/qemu-kernel/x86/vmlinux-vbox


# Development

Please refer Rock/Android_Build#Initializing_a_Build_Environment to set up the building environment if you haven't set it already.

# Android4.4

Get the source code

  Download here http://dl.radxa.com/rock2/source/radxa_rock2_square_android4.4.2_sdk.tar.xz
  
Build u-boot

    cd u-boot 
    make rk3288_defconfig 
    make -j4
Build the kernel

    cd kernel
    make radxa_rock2_square_defconfig
    make radxa-rock2-square.img -j 16
Build android source code

    source build/envsetup.sh 
    lunch rk3288-eng
    make -j 8
    
Generate the image

    ./mkimage.sh ota

you will get boot.img recovery.img system.img under rockdev/Image, and update.img ( e.g. rock2_android_kitkat_15-03-23_141904.img)under rockdev
