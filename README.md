# Sweet (Redmi Note 10 Pro) Kernel with PixelOS

This repository contains a GitHub Actions workflow to build and compile the kernel for the Xiaomi Redmi Note 10 Pro (sweet) running PixelOS with the following integrations:

## Features & Integrations

### 1. **KOWSU (KernelSU)**
- Kernel-level root solution for Android
- Provides a sandboxed root environment
- Compatible with magisk modules
- Integrated using the standard method with fs/exec.c hooks

### 2. **SUSFS (Sensitive USer FileSystem)**
- Enhanced security filesystem for KernelSU
- **Inline Hook Method**: Uses function hooking at the kernel level instead of LSM
- Features:
  - SU mount spoofing
  - SELinux spoofing
  - Uname spoofing
  - Auto-add/deny functionality
  - Process isolation

### 3. **Device-Specific Patches (from perf_neon-builder)**
Comprehensive patches applied specifically for the Redmi Note 10 Pro:

#### LN8000 Charger Patches (5 patches from CRDroid)
- Complete LN8000 charging IC driver implementation
- Thermal management and power supply integration
- **Config**: `CONFIG_CHARGER_LN8000=y`

#### DTBO Patches (6 patches from Xiaomi SM6150)
- Device tree binary overlay updates
- SM6150 SoC compatibility enhancements

#### LTO Optimization (1 patch)
- Link-Time Optimization for performance
- **Configs**: `CONFIG_LTO_CLANG=y`, `CONFIG_THINLTO=y`

#### KPATCH Framework (1 patch)
- Live patching support
- Kernel compatibility fixes

**Total Patches**: 13 patches from verified sources
**Reference**: https://github.com/hexman1999/perf_neon-builder

### 4. **Android 16 QPR2 Support**
- Latest Android security patches
- QPR2 (Quarterly Platform Release 2) optimizations
- Enhanced memory management
- Improved performance

## Device Specifications

- **Device**: Xiaomi Redmi Note 10 Pro
- **Codename**: sweet
- **Processor**: Snapdragon 732G
- **RAM**: 6-8GB
- **Storage**: 64-128GB
- **Camera**: 108MP main sensor
- **Battery**: 5020 mAh

## Build System Requirements

### Local Build (Optional)
To build locally, you need:
- Ubuntu 22.04 or later
- Build tools: `build-essential`, `libncurses-dev`, `bison`, `flex`
- Kernel headers and sources
- Android NDK (optional, for advanced optimizations)
- LLVM/Clang toolchain
- CCleaner for faster rebuilds

### Automated Build (GitHub Actions)
Everything is handled automatically on push/PR/tag:
- Environment setup
- Kernel source download
- Patch integration
- Compilation
- Artifact generation

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── kernel-build.yml                  # Main GitHub Actions workflow
├── scripts/
│   ├── integrate-kowsu.sh                    # KOWSU/KernelSU integration
│   ├── integrate-susfs.sh                    # SUSFS with inline hooks
│   ├── apply-device-patches.sh               # Device-specific patches
│   └── configure-kernel.sh                   # Kernel configuration
├── patches/                                  # Custom patches directory
├── README.md                                 # This file
├── PATCHES.md                                # Detailed patch references
├── UPDATES.md                                # Recent changes summary
├── SETUP.md                                  # Initial setup guide
└── Makefile                                  # Local build helper
```

## Build Process

The GitHub Actions workflow applies patches and integrations in this order:

```
1. Download PixelOS Kernel (sixteen_qpr2 branch)
   ↓
2. Integrate KOWSU (KernelSU)
   ↓
3. Integrate SUSFS (inline hooks)
   ↓
4. Apply Device-Specific Patches (13 total)
   ├── LN8000 Charger (5 patches from CRDroid)
   ├── DTBO Updates (6 patches from Xiaomi)
   ├── LTO Optimization (1 patch)
   └── KPATCH Fix (1 patch)
   ↓
5. Apply Custom Patches (from patches/ directory)
   ↓
6. Configure Kernel
   ├── Enable KernelSU options
   ├── Enable SUSFS options
   ├── Enable LN8000 charger
   ├── Enable LTO optimization
   └── Apply performance tuning
   ↓
7. Build Kernel with Clang/LLVM
   ├── Image.gz
   ├── dtbo.img
   └── Kernel modules (.ko files)
```

## Usage

### 1. Trigger Build on GitHub Actions

**Push to Main Branch:**
```bash
git push origin main
```

**Create a Release Tag:**
```bash
git tag v1.0.0
git push origin v1.0.0
```

**Manual Trigger:**
Go to **Actions** → **Build Kernel** → **Run workflow** → Select branch/variant

### 2. Build Configuration Options

The workflow accepts the following inputs:
- **build_variant**: `user` (default), `userdebug`, or `eng`
  - `user`: Optimized, no debug info
  - `userdebug`: Debug symbols included
  - `eng`: Full debug, highest verbosity

### 3. Output Artifacts

Build artifacts include:
- `Image.gz` - Compressed kernel image
- `dtbo.img` - Device tree blob
- `modules/` - Compiled kernel modules (.ko files)
- `BUILD_INFO.txt` - Build metadata

## Integration Details

### KOWSU (KernelSU) Integration

KernelSU is integrated by:
1. Copying source to `drivers/kernelsu/`
2. Adding build system entries in `drivers/Makefile` and `drivers/Kconfig`
3. Patching `fs/exec.c` with KernelSU hooks
4. Enabling `CONFIG_KERNELSU` in kernel config

**Key Files:**
- `drivers/kernelsu/` - KernelSU source
- `fs/exec.c` - Execution hooks

### SUSFS Inline Hook Method

SUSFS is integrated with inline hooks by:

1. **Copying Source**: SUSFS code to `fs/susfs/`
2. **Inline Hooks Applied to**:
   - `fs/namei.c` - Path traversal operations
   - `fs/open.c` - File open syscalls
   - `fs/stat.c` - File stat operations
3. **Hook Mechanism**: 
   - Intercepts function calls at the instruction level
   - No reliance on LSM framework
   - Better performance and compatibility
4. **Configuration Options**:
   ```
   CONFIG_SUSFS=y
   CONFIG_SUSFS_INLINE_HOOK=y
   CONFIG_SUSFS_SU_MOUNT=y
   CONFIG_SUSFS_SPOOF_UNAME=y
   CONFIG_SUSFS_SPOOF_SELINUX=y
   ```

**Benefits of Inline Hooks:**
- Lower overhead than LSM
- Better app compatibility (some apps block LSM hooks)
- Works alongside LSM without conflicts
- Transparent to security frameworks

### Device-Specific Patches (13 Total)

The kernel build applies comprehensive device-specific patches sourced from verified kernel repositories:

#### LN8000 Charger Patches (CRDroid)
5 patches providing complete support for the LN8000 charging IC:
- Driver implementation and power supply integration
- Thermal management and charge control
- Configuration: `CONFIG_CHARGER_LN8000=y`
- **Source**: https://github.com/crdroidandroid/android_kernel_xiaomi_sm6150

#### DTBO Patches (Xiaomi)
6 patches for device tree updates:
- SM6150 SoC compatibility
- Device tree binary overlay enhancements
- **Source**: https://github.com/xiaomi-sm6150/android_kernel_xiaomi_sm6150

#### LTO Optimization
Link-Time Optimization for improved performance:
- Configuration: `CONFIG_LTO_CLANG=y`, `CONFIG_THINLTO=y`
- **Source**: https://github.com/TheSillyOk/kernel_ls_patches

#### KPATCH Framework
Live patching support:
- Kernel compatibility fixes
- **Source**: https://github.com/TheSillyOk/kernel_ls_patches

**Patch Reference**: See [PATCHES.md](./PATCHES.md) for complete patch URLs and details.

### LN8000 Charger Patches (Legacy)

1. **Driver Integration**:
   - Charger IC driver: `drivers/power/supply/ln8000_charger.c`
   - Configuration header: `drivers/power/supply/ln8000_config.h`

2. **Device Tree Updates**:
   - LN8000 node added to `arch/arm64/boot/dts/`
   - I2C address: `0x51`
   - Input limit: 3500 mA
   - Charging limit: 3500 mA

3. **Features**:
   - Dual charging support
   - Thermal management
   - Overvoltage protection
   - Reverse boost capability

4. **Kernel Configuration**:
   ```
   CONFIG_CHARGER_LN8000=y
   CONFIG_LN8000_THERMAL_MANAGEMENT=y
   CONFIG_LN8000_DUAL_CHARGING=y
   ```

## Kernel Configuration Options

### For Development:
```bash
# Enable debugging
CONFIG_DEBUG_FS=y
CONFIG_DEBUG_KERNEL=y
CONFIG_KALLSYMS=y
CONFIG_KALLSYMS_ALL=y
```

### For Production:
```bash
# Optimize for size and performance
# CONFIG_DEBUG_INFO is not set
# CONFIG_DEBUG_VM is not set
CONFIG_CPU_FREQ=y
CONFIG_ZRAM=y
CONFIG_ZSWAP=y
```

## Building Locally

### Prerequisites
```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  libncurses-dev \
  bison \
  flex \
  libssl-dev \
  libelf-dev \
  bc \
  pahole \
  git \
  clang \
  lld
```

### Build Steps
```bash
# Clone the repository
git clone <repo-url> kernel-sweet
cd kernel-sweet

# Run the build (scripts handle everything)
bash scripts/integrate-kowsu.sh
bash scripts/integrate-susfs.sh
bash scripts/apply-ln8000-patches.sh
bash scripts/configure-kernel.sh

# Build kernel
make -j$(nproc) \
  ARCH=arm64 \
  CROSS_COMPILE=aarch64-linux-gnu- \
  CC=clang \
  LD=ld.lld
```

## Troubleshooting

### Build Fails with "CONFIG_KERNELSU not found"
- Make sure KOWSU integration script ran successfully
- Check that `drivers/kernelsu/` directory exists
- Verify `drivers/Kconfig` includes KernelSU config

### SUSFS Hooks Not Working
- Verify inline hooks are applied: `grep "susfs_" fs/namei.c`
- Check that `CONFIG_SUSFS_INLINE_HOOK=y` in .config
- Ensure KOWSU is enabled first (dependency)

### LN8000 Not Recognized
- Check device tree has LN8000 node
- Verify I2C bus is configured for address 0x51
- Look for charger driver in kernel logs: `dmesg | grep -i ln8000`

### Build Times Out on GitHub Actions
- GitHub Actions has time limits
- For large kernels, consider splitting build steps
- Use `ccache` to speed up rebuilds

## Flashing the Kernel

### Using Fastboot
```bash
adb reboot bootloader
fastboot flash boot Image.gz
fastboot flash dtbo dtbo.img
fastboot reboot
```

### Using Recovery
1. Place kernel files on device
2. Boot into recovery
3. Flash via recovery UI or `adb sideload`

## Performance Tips

1. **Disable Unnecessary Modules**: Remove unused drivers from config
2. **Enable CPU Governors**: `CONFIG_CPU_FREQ=y`
3. **Use ZSWAP**: For better memory compression
4. **Disable Debug**: Remove `CONFIG_DEBUG_*` options in production

## Contributing

To add custom patches:
1. Place patch files in `patches/` directory
2. They will be auto-applied in the workflow
3. Ensure patches are compatible with PixelOS kernel

## License

[Choose your license: GPL v2, MIT, Apache 2.0, etc.]

## Credits

- **PixelOS**: Base kernel source
- **KernelSU**: KOWSU/KernelSU project
- **SUSFS**: SUSFS inline hook implementation
- **CRDroid**: LN8000 charger patches
- **Xiaomi**: Device support

## Support & Issues

For issues or questions:
1. Check workflow logs in GitHub Actions
2. Review kernel build output
3. Check device kernel logs: `adb logcat | grep -i kernel`
4. Open an issue with build logs

## FAQ

**Q: Will this void warranty?**
A: Flashing custom kernels may void your device warranty. Proceed at your own risk.

**Q: Does this work with the stock bootloader?**
A: Yes, this kernel is compatible with the stock MIUI/PixelOS bootloader.

**Q: Can I use this with other Android distributions?**
A: This kernel is optimized for PixelOS and Android 16 QPR2. Other distributions may require modifications.

**Q: How often are kernels updated?**
A: Automatic builds occur on every push. Manual triggers are available.

**Q: Does KernelSU conflict with Magisk?**
A: KernelSU and Magisk are separate root solutions. Use one at a time.

---

**Last Updated**: 2026-05-13
**Kernel Version**: PixelOS for sweet (Redmi Note 10 Pro)
**Android Version**: Android 16 QPR2
