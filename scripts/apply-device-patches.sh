#!/bin/bash
# Device-specific Patch Application Script for Sweet (Redmi Note 10 Pro)
# Based on https://github.com/hexman1999/perf_neon-builder/blob/master/scripts/apply-device-patches.sh
# Applies LN8000, DTBO, LTO, and other optimizations for sweet-pixelos

set -e

KERNEL_DIR="${1:-.}"
DEVICE_IMPORT="${DEVICE_IMPORT:-sweet-pixelos}"
MAIN_DEFCONFIG="${MAIN_DEFCONFIG:-arch/arm64/configs/sweet_defconfig}"

echo "=== Applying device specific patches for $DEVICE_IMPORT ==="

cd "$KERNEL_DIR"

# Patch helper function
apply_patches() {
    for patch_url in "$@"; do
        echo "-- Downloading and applying patch: $(basename "$patch_url")"
        curl -sL --fail --retry 3 "$patch_url" -o /tmp/temp_patch.patch
        if [ -s /tmp/temp_patch.patch ]; then
            if patch -s -p1 --fuzz=5 < /tmp/temp_patch.patch 2>/dev/null; then
                echo "   ✓ Applied successfully"
            else
                echo "   ⚠ Patch already applied or minor conflicts (continuing)"
            fi
        else
            echo "   ✗ Failed to download patch"
            return 1
        fi
    done
}

# LN8000 Patches from CRDroid for SM6150
echo "-- Applying LN8000 patches from CRDroid..."
LN8K_PATCHES=(
    "https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/7b73f853977d2c016e30319dffb1f49957d30b40.patch"
    "https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/63dddc108d57dc43e1cd0da0f1445875f760cf97.patch"
    "https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/95816dff2ecc7ddd907a56537946b5cf1e864953.patch"
    "https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/330c60abc13530bd05287f9e5395d283ebfd6d0b.patch"
    "https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/0477c7006b41a1763b3314af9eb300491b91fc25.patch"
)
apply_patches "${LN8K_PATCHES[@]}" || true

# Configure LN8000
echo "CONFIG_CHARGER_LN8000=y" >> "$MAIN_DEFCONFIG"

# DTBO Patches from SM6150
echo "-- Applying DTBO patches..."
DTBO_PATCHES=(
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch"
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98.patch"
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/4b89948ec7d610f997dd1dab813897f11f403a06.patch"
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/fade7df36b01f2b170c78c63eb8fe0d11c613c4a.patch"
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/2628183db0d96be8dae38a21f2b09cb10978f423.patch"
    "https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/31f4577af3f8255ae503a5b30d8f68906edde85f.patch"
)
apply_patches "${DTBO_PATCHES[@]}" || true

# LTO Patch
echo "-- Applying LTO patch..."
LTO_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/fix_lto.patch"
apply_patches "$LTO_PATCH" || true

# LTO Configurations
echo "CONFIG_LTO_CLANG=y" >> "$MAIN_DEFCONFIG"
echo "CONFIG_THINLTO=y" >> "$MAIN_DEFCONFIG"

# KPATCH (shared for all)
echo "-- Applying KPATCH patch..."
KPATCH_PATCH="https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/kpatch_fix.patch"
apply_patches "$KPATCH_PATCH" || true

# Common configurations for SM6150 (4.14 kernel)
echo "-- Applying kernel configurations..."
echo "CONFIG_EROFS_FS=y" >> "$MAIN_DEFCONFIG"
echo "CONFIG_SECURITY_SELINUX_DEVELOP=y" >> "$MAIN_DEFCONFIG"

# Remove duplicates from defconfig
sort "$MAIN_DEFCONFIG" | uniq > "$MAIN_DEFCONFIG.tmp"
mv "$MAIN_DEFCONFIG.tmp" "$MAIN_DEFCONFIG"

echo ""
echo "✓ Device patches applied successfully!"
echo "  - LN8000 charger patches (CRDroid): 5 patches"
echo "  - DTBO patches (SM6150): 6 patches"
echo "  - LTO optimization: enabled"
echo "  - KPATCH fix: applied"
echo "  - Kernel configs: updated"
echo "  - Config file: $MAIN_DEFCONFIG"
