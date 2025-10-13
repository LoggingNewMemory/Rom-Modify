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
echo "      GSI Mod      "
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
    if [ -d "system/system/priv-app/TrebleApp" ]; then
        rm -rf "system/system/priv-app/TrebleApp/"
        echo "    -> TrebleApp deleted successfully."
    else
        echo "    -> WARNING: Directory not found: system/system/priv-app/TrebleApp/"
    fi
else
    echo "    -> Skipping TrebleApp deletion."
fi
echo "--------------------------------------------------"

# --- MusicFX Removal ---
if prompt_user "Remove MusicFX?"; then
    echo "    -> Deleting MusicFX..."
    if [ -d "system/system/priv-app/MusicFX" ]; then
        rm -rf "system/system/priv-app/MusicFX/"
        echo "    -> MusicFX deleted successfully."
    else
        echo "    -> WARNING: Directory not found: system/system/priv-app/MusicFX/"
    fi
else
    echo "    -> Skipping MusicFX deletion."
fi
echo "--------------------------------------------------"

# --- Replace Chrome with Via Browser ---
if prompt_user "Replace Chrome with Via Browser?"; then
    VIA_URL="https://github.com/LoggingNewMemory/Rom-Modify/releases/download/AddOn/Via.Browser.apk"
    TARGET_CHROME_APK="system/system/product/app/Chrome64/Chrome64.apk"
    TEMP_VIA_APK="TMP/Chrome64.apk"

    echo "    -> Downloading Via Browser..."
    # Use wget with -q (quiet) and --show-progress for a clean output
    if wget -q --show-progress -O "$TEMP_VIA_APK" "$VIA_URL"; then
        echo "    -> Download successful."
        echo "    -> Replacing Chrome64.apk..."
        if [ -f "$TARGET_CHROME_APK" ]; then
            mv -f "$TEMP_VIA_APK" "$TARGET_CHROME_APK"
            echo "    -> Chrome replaced with Via Browser."
        else
            echo "    -> WARNING: Target file not found: $TARGET_CHROME_APK"
        fi
    else
        echo "    -> ERROR: Failed to download Via Browser. Skipping."
    fi
else
    echo "    -> Skipping Chrome replacement."
fi
echo "--------------------------------------------------"

# --- Yamada Patch ---
if prompt_user "Add Yamada Patch? (May Increase Performance and Extend Battery usage)"; then
    BUILD_PROP="system/system/product/etc/build.prop"
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
    BUILD_PROP="system/system/product/etc/build.prop"
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
    BUILD_PROP="system/system/product/etc/build.prop"
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
