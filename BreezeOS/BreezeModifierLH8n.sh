#!/bin/bash

# A simple helper function to handle user prompts
prompt_user() {
    while true; do
        read -p "$1 [y/n]: " yn
        case $yn in
            [Yy]* ) return 0;; # Returns 0 for "yes"
            [Nn]* ) return 1;; # Returns 1 for "no"
            * ) echo "Please answer yes (y) or no (n).";;
        esac
    done
}

# --- Script Start ---
clear
echo "==================="
echo "   Breeze Modify"
echo "==================="
echo "By: Kanagawa Yamada"
echo ""

# Create a temporary folder for downloads
echo "==> Creating temporary directory 'TMP/'..."
mkdir -p TMP
echo ""

# --- TrebleApp Removal ---
if prompt_user "Delete TrebleApp?"; then
    echo "    -> Deleting TrebleApp..."
    if [ -d "BreezeOS/system/priv-app/TrebleApp" ]; then
        rm -rf "BreezeOS/system/priv-app/TrebleApp/"
        echo "    -> TrebleApp deleted successfully."
    else
        echo "    -> WARNING: Directory not found: BreezeOS/system/priv-app/TrebleApp/"
    fi
else
    echo "    -> Skipping TrebleApp deletion."
fi
echo "--------------------------------------------------"

# --- Accord Legacy Replacement ---
if prompt_user "Replace BOSGramophone with Accord Legacy?"; then
    ACCORD_URL="https://github.com/FoedusProgramme/AccordLegacy/releases/download/alpha12/Accord-alpha12-arm64-v8a-release.apk"
    TARGET_APK="BreezeOS/system/product/app/BOSGramophone/BOSGramophone.apk"
    TEMP_APK="TMP/BOSGramophone.apk"

    echo "    -> Downloading Accord Legacy..."
    # Use wget with -q (quiet) and --show-progress for a clean output
    if wget -q --show-progress -O "$TEMP_APK" "$ACCORD_URL"; then
        echo "    -> Download successful."
        echo "    -> Replacing BOSGramophone.apk..."
        if [ -f "$TARGET_APK" ]; then
            mv -f "$TEMP_APK" "$TARGET_APK"
            echo "    -> BOSGramophone replaced with Accord Legacy."
        else
            echo "    -> WARNING: Target file not found: $TARGET_APK"
        fi
    else
        echo "    -> ERROR: Failed to download Accord Legacy. Skipping."
    fi
else
    echo "    -> Skipping Accord Legacy replacement."
fi
echo "--------------------------------------------------"

# --- MusicFX Removal ---
if prompt_user "Remove MusicFX?"; then
    echo "    -> Deleting MusicFX..."
    if [ -d "BreezeOS/system/priv-app/MusicFX" ]; then
        rm -rf "BreezeOS/system/priv-app/MusicFX/"
        echo "    -> MusicFX deleted successfully."
    else
        echo "    -> WARNING: Directory not found: BreezeOS/system/priv-app/MusicFX/"
    fi
else
    echo "    -> Skipping MusicFX deletion."
fi
echo "--------------------------------------------------"

# --- GrapheneOS Camera Replacement ---
if prompt_user "Replace BOSCamera with GrapheneOS Camera?"; then
    TARGET_CAMERA_APK="BreezeOS/system/product/app/BOSCamera/BOSCamera.apk"
    TEMP_CAMERA_APK="TMP/BOSCamera.apk"

    echo "    -> Fetching latest GrapheneOS Camera release info..."
    # Use the GitHub API to find the download URL for the latest APK
    API_URL="https://api.github.com/repos/GrapheneOS/Camera/releases/latest"
    DOWNLOAD_URL=$(curl -s "$API_URL" | grep "browser_download_url.*\.apk" | cut -d '"' -f 4)

    if [ -n "$DOWNLOAD_URL" ]; then
        echo "    -> Downloading from: $DOWNLOAD_URL"
        if wget -q --show-progress -O "$TEMP_CAMERA_APK" "$DOWNLOAD_URL"; then
            echo "    -> Download successful."
            echo "    -> Replacing BOSCamera.apk..."
             if [ -f "$TARGET_CAMERA_APK" ]; then
                mv -f "$TEMP_CAMERA_APK" "$TARGET_CAMERA_APK"
                echo "    -> BOSCamera replaced with GrapheneOS Camera."
            else
                echo "    -> WARNING: Target file not found: $TARGET_CAMERA_APK"
            fi
        else
            echo "    -> ERROR: Failed to download GrapheneOS Camera. Skipping."
        fi
    else
        echo "    -> ERROR: Could not find GrapheneOS Camera download URL. Skipping."
    fi
else
    echo "    -> Skipping GrapheneOS Camera replacement."
fi
echo "--------------------------------------------------"

# --- Pixel Gemini Boot Animation Replacement ---
if prompt_user "Replace Bootanim to Pixel Gemini Bootanim?"; then
    BOOTANIM_URL="https://github.com/LoggingNewMemory/Rom-Modify/releases/download/AddOn/PixelBootanim.zip"
    TEMP_ZIP="TMP/PixelBootanim.zip"
    TARGET_DIR="BreezeOS/system/product/media/"

    echo "    -> Downloading Pixel Gemini Boot Animation..."
    if wget -q --show-progress -O "$TEMP_ZIP" "$BOOTANIM_URL"; then
        echo "    -> Download successful."
        echo "    -> Unzipping boot animation..."
        # Unzip to the TMP folder, overwrite without asking, and hide output
        unzip -o "$TEMP_ZIP" -d "TMP/" > /dev/null 2>&1

        echo "    -> Replacing boot animations..."
        if [ -d "$TARGET_DIR" ]; then
            # Check if files exist in TMP before moving
            if [ -f "TMP/bootanimation.zip" ] && [ -f "TMP/bootanimation-dark.zip" ]; then
                mv -f "TMP/bootanimation.zip" "$TARGET_DIR"
                mv -f "TMP/bootanimation-dark.zip" "$TARGET_DIR"
                echo "    -> Boot animations replaced successfully."
            else
                echo "    -> ERROR: Expected files not found in downloaded zip. Skipping."
            fi
        else
            echo "    -> WARNING: Target directory not found: $TARGET_DIR"
        fi
    else
        echo "    -> ERROR: Failed to download boot animation. Skipping."
    fi
else
    echo "    -> Skipping boot animation replacement."
fi
echo "--------------------------------------------------"

# --- Yamada Patch ---
if prompt_user "Add Yamada Patch? (May Increase Performance and Extend Battery usage)"; then
    BUILD_PROP="BreezeOS/system/product/etc/build.prop"
    echo "    -> Applying Yamada Patch to $BUILD_PROP..."

    if [ -f "$BUILD_PROP" ]; then
        # Use a 'here document' to append the block of text to the build.prop file
        # Quoting 'EOF' prevents the shell from expanding variables like $
        cat << 'EOF' >> "$BUILD_PROP"

##########################################
#               YAMADA PATCH             #
##########################################
# This props belongs to Kanagawa Yamada  #
#     And The Contributed Developers     #
# Please Credit or You Get a Bone Cancer #
##########################################

# Minor Graphics Tweaks
persist.sys.phh.touch_hint=rotate
debug.renderengine.backend=skiaglthreaded

# Disable FPS Drop when low battery
sys.surfaceflinger.idle_reduce_framerate_enable=no

# Disable Limit 60FPS while Gaming on AOSP 15.0
debug.graphics.game_default_frame_rate.disable=true

########################################
# Bastion Battery
########################################
# Battery Modifications
persist.sys.shutdown.mode=hibernate
persist.radio.add_power_save=1
wifi.supplicant_scan_interval=300
ro.ril.disable.power.collapse=1
ro.config.hw_fast_dormancy=1
ro.semc.enable.fast_dormancy=true
ro.config.hw_quickpoweron=true
ro.mot.eri.losalert.delay=1000
ro.config.hw_power_saving=true
pm.sleep_mode=1
ro.ril.sensor.sleep.control=1
power_supply.wakeup=enable

# Additional Battery Optimizations
ro.ril.power.collapse=1
power.saving.enabled=1
battery.saver.low_level=30
power.saving.enable=1
persist.radio.apm_sim_not_pwdn=1
ro.ril.enable.amr.wideband=0
power.saving.low_screen_brightness=1
ro.config.hw_smart_battery=1
ro.config.hw_power_profile=low

# Dalvik and Kernel Modifications
persist.android.strictmode=0
ro.kernel.android.checkjni=0
ro.kernel.checkjni=0
ro.config.nocheckin=1
ro.compcache.default=0
dalvik.vm.execution-mode=int:jit
dalvik.vm.verify-bytecode=true
dalvik.vm.jmiopts=forcecopy
debug.kill_allocating_task=0
ro.ext4fs=1
dalvik.vm.heaputilization=0.25
dalvik.vm.heaptargetutilization=0.75

# Disable USB Debugging Popup
persist.adb.notify=0

# Allow to free more RAM
persist.sys.purgeable_assets=1
ro.config.low_ram=enable

# Smoother video playback
video.accelerate.hw=1
media.stagefright.enable-player=true
media.stagefright.enable-meta=true
media.stagefright.enable-scan=false
media.stagefright.enable-http=true

# UI Tweaks
persist.sys.ui.hw=1
view.scroll_friction=10
debug.composition.type=gpu
debug.performance.tuning=1

# Miscellaneous
persist.sys.gmaps_hack=1
debug.sf.ddms=0
ro.warmboot.capability=1
logcat.live=disable

# CPU Core Control
ro.vendor.qti.core_ctl_min_cpu=4
ro.vendor.qti.core_ctl_max_cpu=4
EOF
        echo "    -> Yamada Patch applied successfully."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping Yamada Patch."
fi
echo "--------------------------------------------------"

# --- Disable Setup Wizard ---
if prompt_user "Disable Setup?"; then
    BUILD_PROP="BreezeOS/system/product/etc/build.prop"
    echo "    -> Disabling setup wizard in $BUILD_PROP..."
    if [ -f "$BUILD_PROP" ]; then
        # Use sed to find and replace the line in-place
        sed -i 's/ro.setupwizard.mode=OPTIONAL/ro.setupwizard.mode=DISABLED/g' "$BUILD_PROP"
        echo "    -> Setup wizard disabled."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping setup wizard modification."
fi
echo "--------------------------------------------------"

# --- LH8n Fix Brightness and Volume ---
if prompt_user "Include LH8n Fix Brightness and Volume fix?"; then
    BUILD_PROP="BreezeOS/system/product/etc/build.prop"
    echo "    -> Applying LH8n Fixes to $BUILD_PROP..."

    if [ -f "$BUILD_PROP" ]; then
        cat << 'EOF' >> "$BUILD_PROP"

# --- LH8n Fixes ---
# Fix Brightness
ro.vendor.transsion.backlight_hal.optimization=1

# Fix low volume
persist.audio.voip.vol=100
ro.config.media_vol_steps=30
ro.config.vc_call_vol_steps=30
persist.audio.volume_steps=30
persist.audio.max_volume=100
EOF
        echo "    -> LH8n Fixes applied successfully."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping LH8n Fixes."
fi
echo "--------------------------------------------------"

# --- Cleanup ---
echo "==> Cleaning up temporary files..."
rm -rf TMP
echo ""
echo "All Done!"
echo ""
