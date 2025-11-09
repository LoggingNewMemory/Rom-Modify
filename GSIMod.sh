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

# --- Add Via Browser ---
if prompt_user "Add Via Browser?"; then
    VIA_URL="https://github.com/LoggingNewMemory/Rom-Modify/releases/download/AddOn/Via.Browser.apk"
    TARGET_VIA_DIR="system/system/product/app/ViaBrowser"
    TARGET_VIA_APK="$TARGET_VIA_DIR/ViaBrowser.apk"

    echo "    -> Creating directory $TARGET_VIA_DIR..."
    mkdir -p "$TARGET_VIA_DIR"

    echo "    -> Downloading Via Browser..."
    # Use wget with -q (quiet) and --show-progress for a clean output
    if wget -q --show-progress -O "$TARGET_VIA_APK" "$VIA_URL"; then
        echo "    -> Download successful."
        echo "    -> Via Browser added to $TARGET_VIA_APK"
    else
        echo "    -> ERROR: Failed to download Via Browser. Skipping."
        rm -rf "$TARGET_VIA_DIR" # Clean up empty directory
    fi
else
    echo "    -> Skipping Via Browser."
fi
echo "--------------------------------------------------"

# --- Add Aperture ---
if prompt_user "Add Aperture?"; then
    APERTURE_URL="https://github.com/LoggingNewMemory/Rom-Modify/releases/download/AddOn/Aperture.apk"
    TARGET_APERTURE_DIR="system/system/product/priv-app/Aperture"
    TARGET_APERTURE_APK="$TARGET_APERTURE_DIR/Aperture.apk"
    BUILD_PROP="system/system/product/etc/build.prop"

    echo "    -> Creating directory $TARGET_APERTURE_DIR..."
    mkdir -p "$TARGET_APERTURE_DIR"

    echo "    -> Downloading Aperture..."
    if wget -q --show-progress -O "$TARGET_APERTURE_APK" "$APERTURE_URL"; then
        echo "    -> Download successful."
        echo "    -> Applying Aperture config to $BUILD_PROP..."
        
        if [ -f "$BUILD_PROP" ]; then
            # Add a newline for separation and a comment
            echo "" >> "$BUILD_PROP"
            echo "# --- Aperture Camera Config ---" >> "$BUILD_PROP"
            echo "ro.com.google.lens.oem_camera_package=org.lineageos.aperture.dev" >> "$BUILD_PROP"
            echo "    -> Aperture config applied."
        else
            echo "    -> WARNING: $BUILD_PROP not found. APK was downloaded but config was NOT applied."
        fi
    else
        echo "    -> ERROR: Failed to download Aperture. Skipping."
        rm -rf "$TARGET_APERTURE_DIR" # Clean up
    fi
else
    echo "    -> Skipping Aperture."
fi
echo "--------------------------------------------------"

# --- Yamada Patch ---
if prompt_user "Add Yamada Patch? (May Increase Performance)"; then
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

# --- Transsion Fix Brightness and Volume ---
if prompt_user "Include Transsion Fix Brightness and Volume fix?"; then
    BUILD_PROP="system/system/product/etc/build.prop"
    echo "    -> Applying Transsion Fixes to $BUILD_PROP..."

    if [ -f "$BUILD_PROP" ]; then
        cat << 'EOF' >> "$BUILD_PROP"

# --- Transsion Fixes ---
# Fix Brightness
ro.vendor.transsion.backlight_hal.optimization=1

# Fix low volume
persist.audio.voip.vol=100
ro.config.media_vol_steps=30
ro.config.vc_call_vol_steps=30
persist.audio.volume_steps=30
persist.audio.max_volume=100
EOF
        echo "    -> Transsion Fixes applied successfully."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping Transsion Fixes."
fi
echo "--------------------------------------------------"

# --- System Wide BT HAL ---
if prompt_user "Use System Wide BT HAL?"; then
    BUILD_PROP="system/system/product/etc/build.prop"
    echo "    -> Enabling System Wide BT HAL in $BUILD_PROP..."
    if [ -f "$BUILD_PROP" ]; then
        echo "" >> "$BUILD_PROP"
        echo "# --- System Wide BT HAL ---" >> "$BUILD_PROP"
        echo "persist.bluetooth.system_audio_hal.enabled=true" >> "$BUILD_PROP"
        echo "    -> System Wide BT HAL enabled."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping System Wide BT HAL."
fi
echo "--------------------------------------------------"

# --- Spoof to Locked device ---
if prompt_user "Spoof to Locked device?"; then
    BUILD_PROP="system/system/product/etc/build.prop"
    echo "    -> Applying Locked Device Spoof to $BUILD_PROP..."

    if [ -f "$BUILD_PROP" ]; then
        cat << 'EOF' >> "$BUILD_PROP"

# --- Spoof to Locked device ---
ro.control_privapp_permissions=log
ro.boot.flash.locked=1
ro.boot.verifiedbootstate=green
ro.boot.veritymode=enforcing
ro.boot.vbmeta.device_state=locked
vendor.boot.vbmeta.device_state=locked
ro.build.type=user
ro.debuggable=0
ro.secure=1
EOF
        echo "    -> Locked Device Spoof applied successfully."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping Locked Device Spoof."
fi
echo "--------------------------------------------------"

# --- Disable Voice Call in Route ---
if prompt_user "Disable Voice Call in Route (May Fix Calls Audio)?"; then
    BUILD_PROP="system/system/product/etc/build.prop"
    echo "    -> Disabling Voice Call in Route in $BUILD_PROP..."
    if [ -f "$BUILD_PROP" ]; then
        echo "" >> "$BUILD_PROP"
        echo "# --- Disable Voice Call in Route (Fix Calls Audio) ---" >> "$BUILD_PROP"
        echo "persist.sys.phh.disable_voice_call_in=true" >> "$BUILD_PROP"
        echo "    -> Voice Call in Route disabled."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping Voice Call in Route."
fi
echo "--------------------------------------------------"

# --- Disable SF GL/HWC backpressure ---
if prompt_user "Disable SF GL/HWC backpressure (Might Improve Render Perf)?"; then
    BUILD_PROP="system/system/product/etc/build.prop"
    echo "    -> Disabling SF backpressure in $BUILD_PROP..."
    if [ -f "$BUILD_PROP" ]; then
        echo "" >> "$BUILD_PROP"
        echo "# --- Disable SF GL/HWC backpressure (Render Perf) ---" >> "$BUILD_PROP"
        echo "persist.sys.phh.enable_sf_gl_backpressure=0" >> "$BUILD_PROP"
        echo "persist.sys.phh.enable_sf_hwc_backpressure=0" >> "$BUILD_PROP"
        echo "    -> SF backpressure disabled."
    else
        echo "    -> WARNING: File not found: $BUILD_PROP"
    fi
else
    echo "    -> Skipping SF backpressure."
fi
echo "--------------------------------------------------"

# --- Cleanup ---
echo "==> Cleaning up temporary files..."
rm -rf TMP
echo ""
echo "All Done!"
echo ""