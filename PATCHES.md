# Kernel Patches Reference for Sweet (Redmi Note 10 Pro)

This document lists all patches applied during the kernel build process for the Redmi Note 10 Pro (sweet) with PixelOS.

## Reference Source

The patches are primarily sourced from the following builder script:
- **GitHub**: https://github.com/hexman1999/perf_neon-builder
- **Script**: https://github.com/hexman1999/perf_neon-builder/blob/master/scripts/apply-device-patches.sh

## Patch Categories

### 1. LN8000 Charger IC Patches (CRDroid)

**Repository**: `android_kernel_xiaomi_sm6150` (CRDroid)

These patches enable support for the LN8000 charging IC found in the Redmi Note 10 Pro.

| # | Commit SHA | Description |
|---|-----------|-------------|
| 1 | `7b73f853977d2c016e30319dffb1f49957d30b40` | LN8000 driver implementation |
| 2 | `63dddc108d57dc43e1cd0da0f1445875f760cf97` | LN8000 power supply integration |
| 3 | `95816dff2ecc7ddd907a56537946b5cf1e864953` | LN8000 thermal management |
| 4 | `330c60abc13530bd05287f9e5395d283ebfd6d0b` | LN8000 charge control |
| 5 | `0477c7006b41a1763b3314af9eb300491b91fc25` | LN8000 configuration options |

**Direct Links**:
```
https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/7b73f853977d2c016e30319dffb1f49957d30b40.patch
https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/63dddc108d57dc43e1cd0da0f1445875f760cf97.patch
https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/95816dff2ecc7ddd907a56537946b5cf1e864953.patch
https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/330c60abc13530bd05287f9e5395d283ebfd6d0b.patch
https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150/commit/0477c7006b41a1763b3314af9eb300491b91fc25.patch
```

**Kernel Config**:
```
CONFIG_CHARGER_LN8000=y
```

---

### 2. DTBO (Device Tree Binary Overlay) Patches

**Repository**: `android_kernel_xiaomi_sm6150` (Xiaomi Official)

These patches provide device tree updates for SM6150 SoC compatibility.

| # | Commit SHA | Description |
|---|-----------|-------------|
| 1 | `e517bc363a19951ead919025a560f843c2c03ad3` | DTBO update 1 |
| 2 | `a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98` | DTBO update 2 |
| 3 | `4b89948ec7d610f997dd1dab813897f11f403a06` | DTBO update 3 |
| 4 | `fade7df36b01f2b170c78c63eb8fe0d11c613c4a` | DTBO update 4 |
| 5 | `2628183db0d96be8dae38a21f2b09cb10978f423` | DTBO update 5 |
| 6 | `31f4577af3f8255ae503a5b30d8f68906edde85f` | DTBO update 6 |

**Direct Links**:
```
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/e517bc363a19951ead919025a560f843c2c03ad3.patch
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/a62a3b05d0f29aab9c4bf8d15fe786a8c8a32c98.patch
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/4b89948ec7d610f997dd1dab813897f11f403a06.patch
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/fade7df36b01f2b170c78c63eb8fe0d11c613c4a.patch
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/2628183db0d96be8dae38a21f2b09cb10978f423.patch
https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150/commit/31f4577af3f8255ae503a5b30d8f68906edde85f.patch
```

---

### 3. LTO (Link-Time Optimization) Patches

**Repository**: `kernel_ls_patches` (TheSillyOk)

LTO optimization patches for improved kernel performance and security.

| # | Filename | Description |
|---|----------|-------------|
| 1 | `fix_lto.patch` | LTO compatibility fix |

**Direct Link**:
```
https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/fix_lto.patch
```

**Kernel Configs**:
```
CONFIG_LTO_CLANG=y
CONFIG_THINLTO=y
```

---

### 4. KPATCH Fix

**Repository**: `kernel_ls_patches` (TheSillyOk)

Shared patches for kpatch integration.

| # | Filename | Description |
|---|----------|-------------|
| 1 | `kpatch_fix.patch` | kpatch framework fix |

**Direct Link**:
```
https://github.com/TheSillyOk/kernel_ls_patches/raw/refs/heads/master/kpatch_fix.patch
```

---

## Additional Kernel Configurations

### Applied in apply-device-patches.sh

```bash
CONFIG_CHARGER_LN8000=y
CONFIG_LTO_CLANG=y
CONFIG_THINLTO=y
CONFIG_EROFS_FS=y
CONFIG_SECURITY_SELINUX_DEVELOP=y
```

### Applied in configure-kernel.sh

**KernelSU/SUSFS**:
```
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
CONFIG_SECURITY=y
CONFIG_SECURITY_SELINUX=y
CONFIG_KERNELSU=y
CONFIG_SUSFS=y
CONFIG_SUSFS_INLINE_HOOK=y
CONFIG_SUSFS_SU_MOUNT=y
CONFIG_SUSFS_AUTO_ADD=y
CONFIG_SUSFS_SPOOF_UNAME=y
CONFIG_SUSFS_SPOOF_SELINUX=y
```

**Performance**:
```
CONFIG_CPU_FREQ=y
CONFIG_CPU_IDLE=y
CONFIG_ZRAM=y
CONFIG_ZSWAP=y
```

**File Systems**:
```
CONFIG_EXT4_FS=y
CONFIG_F2FS_FS=y
CONFIG_EROFS_FS=y
```

---

## Patch Application Order

The GitHub Actions workflow applies patches in this sequence:

1. **Download Kernel Source** (PixelOS sixteen_qpr2)
2. **Integrate KOWSU** (KernelSU)
3. **Integrate SUSFS** (with inline hooks)
4. **Apply Device-Specific Patches** (LN8000, DTBO, LTO, KPATCH)
5. **Apply Custom Patches** (from `patches/` directory)
6. **Configure Kernel** (additional kernel options)
7. **Build Kernel**

---

## Alternative MIUI Build

If building for MIUI (`sweet-miui`), additional patches would be applied:

Additional LN8000 patches from tbyool:
- https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/aa5ddad5be03aa7436e7ce6e84d46b280849acae.patch
- https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/857638b0da6f80830122b8d1b45c7842970e76c3.patch
- https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/3a68adff14cbedd09ce2a735d575c3bf92dd696f.patch
- https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/30fcc15d5dcf2cfc3b83a5a7d4a77e2880639fa5.patch
- https://github.com/tbyool/android_kernel_xiaomi_sm6150/commit/1a17a6fbbf59d901c4b3aec66c06a1c96cd89c7e.patch

Plus revert commits for MIUI compatibility.

---

## Patch Sources Summary

| Source | Repo | Type | Count |
|--------|------|------|-------|
| CRDroid | `android_kernel_xiaomi_sm6150` | LN8000 | 5 |
| Xiaomi | `android_kernel_xiaomi_sm6150` | DTBO | 6 |
| TheSillyOk | `kernel_ls_patches` | LTO + KPATCH | 2 |
| **Total** | | | **13** |

---

## Verification

To verify patches were applied correctly:

```bash
# Check for LN8000 driver
grep -r "CONFIG_CHARGER_LN8000" arch/arm64/configs/

# Check for LTO
grep -r "CONFIG_LTO_CLANG" arch/arm64/configs/

# Check for DTBO updates
grep -r "dtbo" arch/arm64/boot/dts/

# Check kernel config
cat .config | grep "^CONFIG_" | wc -l
```

---

## Testing the Build

### Local Build Test
```bash
cd kernel-sweet
export DEVICE_IMPORT="sweet-pixelos"
export MAIN_DEFCONFIG="arch/arm64/configs/sweet_defconfig"
bash scripts/apply-device-patches.sh
bash scripts/configure-kernel.sh
make -j$(nproc) ARCH=arm64
```

### GitHub Actions Test
1. Push to `main` branch
2. Check **Actions** tab for build progress
3. Download artifacts from completed workflow

---

## Troubleshooting

### Patch Application Fails
- Check internet connectivity
- Verify GitHub is accessible
- Check patch fuzzy matching settings (currently set to `--fuzz=5`)

### Configuration Conflicts
- Duplicates are automatically removed from defconfig
- Conflicting options are handled by kernel's oldconfig

### Build Time Issues
- Patches download can take 2-5 minutes
- Total patch application usually takes 1-2 minutes
- Build itself takes 15-30 minutes depending on parallelization

---

## License & Attribution

These patches are sourced from:
- **CRDroid**: GPL v2
- **Xiaomi**: GPL v2
- **Linux Kernel**: GPL v2
- **Individual Contributors**: As per their respective licenses

All patches maintain their original license terms.

---

**Last Updated**: 2026-05-13
**Device**: Redmi Note 10 Pro (sweet)
**Android Version**: Android 16 QPR2
**Reference**: perf_neon-builder v1.0
