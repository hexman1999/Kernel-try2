#!/bin/bash
# Kernel Configuration Script
# Configures the kernel with required options for integrations and optimization

set -e

KERNEL_DIR="${1:-.}"
MAIN_DEFCONFIG="${MAIN_DEFCONFIG:-arch/arm64/configs/sweet_defconfig}"

echo "=== Configuring Kernel for Android 16 QPR2 ==="

cd "$KERNEL_DIR"

# Function to enable config option in defconfig
enable_config() {
    local option="$1"
    if grep -q "# $option is not set" "$MAIN_DEFCONFIG" 2>/dev/null; then
        sed -i "s/# $option is not set/$option=y/" "$MAIN_DEFCONFIG"
    elif ! grep -q "^$option=" "$MAIN_DEFCONFIG" 2>/dev/null; then
        echo "$option=y" >> "$MAIN_DEFCONFIG"
    fi
}

# Function to set config value
set_config() {
    local option="$1"
    local value="$2"
    if grep -q "^$option=" "$MAIN_DEFCONFIG" 2>/dev/null; then
        sed -i "s/^$option=.*/$option=$value/" "$MAIN_DEFCONFIG"
    else
        echo "$option=$value" >> "$MAIN_DEFCONFIG"
    fi
}

echo "Enabling kernel options for Android 16 QPR2 and Sweet..."

# Core kernel options for KernelSU/SUSFS
enable_config "CONFIG_KALLSYMS"
enable_config "CONFIG_KALLSYMS_ALL"
enable_config "CONFIG_DEBUG_SECTION_MISMATCH"
enable_config "CONFIG_HAVE_FUNCTION_TRACER"
enable_config "CONFIG_TRACE_IRQFLAGS"

# Security options
enable_config "CONFIG_SECURITY"
enable_config "CONFIG_SECURITY_SELINUX"
enable_config "CONFIG_SECURITY_APPARMOR"
enable_config "CONFIG_HAVE_ARCH_SECCOMP_FILTER"
enable_config "CONFIG_SECCOMP"

# KernelSU requirements
enable_config "CONFIG_KERNELSU"
enable_config "CONFIG_HAVE_EXECVEAT"
enable_config "CONFIG_HAVE_KPROBES"
enable_config "CONFIG_HAVE_KRETPROBES"

# SUSFS requirements
enable_config "CONFIG_SUSFS"
enable_config "CONFIG_SUSFS_INLINE_HOOK"
enable_config "CONFIG_SUSFS_SU_MOUNT"
enable_config "CONFIG_SUSFS_AUTO_ADD"
enable_config "CONFIG_SUSFS_SPOOF_UNAME"
enable_config "CONFIG_SUSFS_SPOOF_SELINUX"

# LN8000 Charger (already configured by apply-device-patches.sh)
enable_config "CONFIG_CHARGER_LN8000"
enable_config "CONFIG_POWER_SUPPLY"

# File system options
enable_config "CONFIG_EXT4_FS"
enable_config "CONFIG_F2FS_FS"
enable_config "CONFIG_EROFS_FS"

# Networking
enable_config "CONFIG_BT"
enable_config "CONFIG_BT_L2CAP"
enable_config "CONFIG_BT_SCO"
enable_config "CONFIG_BT_RFCOMM"
enable_config "CONFIG_BT_BNEP"
enable_config "CONFIG_BT_HIDP"
enable_config "CONFIG_CFG80211"
enable_config "CONFIG_CFG80211_WEXT"

# USB
enable_config "CONFIG_USB"
enable_config "CONFIG_USB_OTG"
enable_config "CONFIG_USB_GADGET"
enable_config "CONFIG_USB_GADGET_CONFIGFS"

# Display
enable_config "CONFIG_DRM"
enable_config "CONFIG_DRM_MSM"

# Input devices
enable_config "CONFIG_INPUT"
enable_config "CONFIG_INPUT_TOUCHSCREEN"
enable_config "CONFIG_INPUT_FINGERPRINT"

# Performance tuning
enable_config "CONFIG_CPU_FREQ"
enable_config "CONFIG_CPU_FREQ_STAT"
enable_config "CONFIG_CPU_IDLE"
set_config "CONFIG_HZ" "300"

# Memory and I/O
enable_config "CONFIG_ZRAM"
enable_config "CONFIG_ZSWAP"
set_config "CONFIG_ZSWAP_COMPRESSOR" "lz4"
set_config "CONFIG_ZSWAP_ZPOOL" "z3fold"

# Crypto
enable_config "CONFIG_CRYPTO"
enable_config "CONFIG_CRYPTO_AES"
enable_config "CONFIG_CRYPTO_SHA256"

# Debug options
enable_config "CONFIG_DEBUG_FS"

# LTO and optimization (already set by apply-device-patches.sh)
enable_config "CONFIG_LTO_CLANG"
enable_config "CONFIG_THINLTO"

# SELinux development mode
enable_config "CONFIG_SECURITY_SELINUX_DEVELOP"

# Disable unnecessary debug to reduce size
echo "# CONFIG_DEBUG_INFO is not set" >> "$MAIN_DEFCONFIG"
echo "# CONFIG_DEBUG_VM is not set" >> "$MAIN_DEFCONFIG"

# Remove duplicate lines from defconfig
sort "$MAIN_DEFCONFIG" | uniq > "$MAIN_DEFCONFIG.tmp"
mv "$MAIN_DEFCONFIG.tmp" "$MAIN_DEFCONFIG"

echo "✓ Kernel configuration complete"
echo "  - KernelSU enabled"
echo "  - SUSFS with inline hooks enabled"
echo "  - LN8000 charger support enabled"
echo "  - LTO optimization enabled"
echo "  - Performance optimizations applied"
echo "  - Android 16 QPR2 optimizations applied"

# Save config backup
cp "$MAIN_DEFCONFIG" "$MAIN_DEFCONFIG.backup"

echo "Configuration saved to $MAIN_DEFCONFIG"
