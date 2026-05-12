# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Prerequisites
- GitHub account
- Git installed
- Basic terminal knowledge

### Step 1: Initialize the Repository

```bash
cd /home/muhammad/Desktop/Kernel3-test
git init
git config user.name "Your Name"
git config user.email "your.email@example.com"
git remote add origin https://github.com/YOUR_USERNAME/kernel-sweet.git
```

### Step 2: Commit Initial Files

```bash
git add .
git commit -m "Initial kernel build setup for Redmi Note 10 Pro"
git branch -M main
git push -u origin main
```

### Step 3: Trigger First Build

**Option A: Automatic on Push**
The workflow automatically triggers when you push to `main`.

**Option B: Manual Trigger**
1. Go to GitHub repository
2. Click **Actions** tab
3. Click **Build Kernel for Sweet**
4. Click **Run workflow**
5. Select branch and click **Run workflow**

**Option C: Release Build**
```bash
git tag v1.0.0
git push origin v1.0.0
```

### Step 4: Monitor Build Progress

1. Go to **Actions** tab on GitHub
2. Click the running workflow
3. Click the **build** job
4. Watch logs in real-time

### Step 5: Download Artifacts

1. Workflow completes (typically 30-40 minutes)
2. Go to **Actions** → Completed workflow
3. Scroll to **Artifacts**
4. Download `kernel-sweet-*` zip file

## 📦 What's Included

### Build Artifacts
- `Image.gz` - Kernel image
- `dtbo.img` - Device tree overlay
- `modules/` - Kernel modules (.ko)
- `BUILD_INFO.txt` - Build metadata

### Source Files
```
.github/workflows/kernel-build.yml        # Build configuration
scripts/
  ├── apply-device-patches.sh             # 13 device-specific patches
  ├── integrate-kowsu.sh                  # KernelSU integration
  ├── integrate-susfs.sh                  # SUSFS integration
  └── configure-kernel.sh                 # Kernel tuning
patches/                                   # Custom patches (optional)
```

### Documentation
- **README.md** - Full build instructions
- **PATCHES.md** - Detailed patch references
- **SETUP.md** - Advanced setup guide
- **UPDATES.md** - Recent changes
- **Makefile** - Local build helper

## 🔧 Included Integrations

| Component | Purpose | Status |
|-----------|---------|--------|
| **KOWSU** | KernelSU root solution | ✅ Integrated |
| **SUSFS** | Enhanced security layer | ✅ Integrated |
| **LN8000** | Charger IC support (5 patches) | ✅ Patched |
| **DTBO** | Device tree updates (6 patches) | ✅ Patched |
| **LTO** | Performance optimization | ✅ Enabled |
| **KPATCH** | Live patching support | ✅ Enabled |

**Total Patches**: 13 from verified sources

## 📝 Common Tasks

### Add Custom Patches
1. Place `.patch` files in `patches/` directory
2. Commit and push
3. Patches auto-apply during build

### Modify Kernel Config
Edit `scripts/configure-kernel.sh`:
```bash
enable_config "CONFIG_YOUR_OPTION"
set_config "CONFIG_SOME_VALUE" "y"
```

### Change Kernel Branch
Edit `.github/workflows/kernel-build.yml`:
```yaml
KERNEL_BRANCH: your-branch-name
```

### Local Build (Advanced)
```bash
# Download kernel
git clone -b sixteen_qpr2 \
  https://github.com/PixelOS-Devices/android_kernel_xiaomi_sm6150 \
  kernel

cd kernel
export DEVICE_IMPORT="sweet-pixelos"
export MAIN_DEFCONFIG="arch/arm64/configs/sweet_defconfig"

# Apply all patches
bash ../scripts/apply-device-patches.sh
bash ../scripts/configure-kernel.sh

# Build
make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-
```

## 🐛 Troubleshooting

### Build Failed?
1. Check **Actions** → workflow → **build** job logs
2. Look for error message
3. Common issues:
   - Network timeout: Re-run workflow
   - Patch conflict: Check patch compatibility
   - Out of disk: GitHub Actions provides 200GB

### Patches Not Applied?
1. Check `PATCHES.md` for URLs
2. Verify internet connectivity
3. Check GitHub rate limiting

### Artifact Not Available?
1. Verify build completed successfully
2. Check retention period (30 days)
3. Look for error messages in logs

## 📚 Documentation Map

| Document | Purpose | When to Read |
|----------|---------|--------------|
| **README.md** | Complete build guide | First-time setup |
| **PATCHES.md** | Patch details & URLs | Understanding patches |
| **SETUP.md** | Advanced configuration | CI/CD setup, customization |
| **UPDATES.md** | What changed | Recent changes |
| **QUICK_START.md** | This file | Quick reference |

## 🎯 Next Steps

1. ✅ Repository initialized
2. ✅ Files in place
3. ✅ Workflow ready
4. ⏭️ **First build triggered**
5. ⏭️ Artifacts downloaded
6. ⏭️ Kernel tested on device
7. ⏭️ Customizations added

## 🤝 Support

- **GitHub Issues**: Report bugs/problems
- **Actions Logs**: Detailed build information
- **PATCHES.md**: Understanding patch sources
- **README.md**: Feature documentation

## 📋 Checklist

Before building:
- [ ] Repository created on GitHub
- [ ] Files pushed to main branch
- [ ] `.github/workflows/kernel-build.yml` exists
- [ ] `scripts/*.sh` files present
- [ ] `PATCHES.md` documentation reviewed

Ready to build:
- [ ] Push to main or create tag
- [ ] Check Actions tab
- [ ] Monitor build progress
- [ ] Download artifacts
- [ ] Verify kernel boots

## 💡 Pro Tips

1. **Speed Up Builds**: Use tags for release builds (auto-uploads to releases)
2. **Cache Optimization**: GitHub Actions caches build dependencies automatically
3. **Parallel Builds**: Can build multiple variants simultaneously with matrix strategy
4. **Custom Patches**: Add your own patches in the `patches/` directory
5. **Config Backup**: Kernel config is backed up after each build

## 🚀 Go Live

Ready to flash your kernel?

```bash
# Connect device and enable ADB
adb reboot bootloader

# Flash kernel
fastboot flash boot Image.gz
fastboot flash dtbo dtbo.img
fastboot reboot
```

---

**Device**: Redmi Note 10 Pro (sweet)  
**Android**: 16 QPR2  
**Build System**: GitHub Actions  
**Last Updated**: 2026-05-13

For detailed information, see [README.md](./README.md)
