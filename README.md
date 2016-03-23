# udoo-quad-kitkat
Udoo Quad KitKat Source (Incomplete)

# Missing Files

These files were too large for GitHub to accept. Consider storing them in a publicly linked zip file on Google Drive, the adding them in on initialization.

    frameworks/base/media/tests/contents/media_api/videoeditor/H264_BP_640x480_15fps_384kbps_60_0.mp4
    external/chromium-trace/trace-viewer/test_data/theverge_trace.json
    external/eclipse-basebuilder/src/eclipse-sourceBuild-srcIncluded-3.6.2.zip
    prebuilts/eclipse/deltapack/eclipse-3.7.2-delta-pack.zip
    prebuilts/eclipse/deltapack/eclipse-4.2.2-delta-pack.zip
    prebuilts/eclipse/platform/org.eclipse.platform-3.7.2.zip
    prebuilts/qemu-kernel/x86/vmlinux-vbox

# Make Case Sensitive Disk Image

    hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size 100g ~/Developer/GitHub/MonsieurCode/android.dmg -volname "Android"

# Install Mac OS SDKs

    sudo git clone git@github.com:phracker/MacOSX-SDKs.git /Developer/SDKs

# Install Java 6

https://support.apple.com/kb/DL1572?locale=en_US

# Install JEnv

    brew install jenv
    jenv add /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
    cd /Volumes/Android/
    jenv local oracle64-1.6.0.65
    java -version
    # java version "1.6.0_65"
    # Java(TM) SE Runtime Environment (build 1.6.0_65-b14-468-11M4833)
    # Java HotSpot(TM) 64-Bit Server VM (build 20.65-b04-468, mixed mode)

# References (ordered by date)
1. ????/??/?? - [Setting Up a Mac OS X Build Environment](https://source.android.com/source/initializing.html#setting-up-a-mac-os-x-build-environment)
2. 2015/10/15 - [Build Android in OS X Yosemite Xcode 7](https://github.com/sjitech/build-android-in-OS-X-Yosemite-Xcode-7)
3. 2015/01/16 - [Build Android 5.0 Lollipop on OSX 10.10 Yosemite](https://medium.com/@raminmahmoodi/build-android-5-0-lollipop-on-osx-10-10-yosemite-441bd00ee77a#.pqo9qtvsa)
4. 2014/05/03 - [Setting Up an Android Build Environment on OS X 10.9 Mavericks](http://forum.xda-developers.com/showthread.php?t=2510898) 
5. 2013/06/15 - [Build Android From Source Mac OS X](http://tryge.com/2013/06/15/build-android-from-source-macosx/)

