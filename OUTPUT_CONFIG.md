# Kernel Build Output Configuration Guide

## Overview

The kernel build system has been configured to properly handle all outputs and ensure they are correctly organized and accessible.

## Build Output Structure

### During Build

```
out/                                    # Build output directory (--output=out)
├── arch/arm64/
│   ├── boot/
│   │   ├── Image                      # Raw kernel image
│   │   ├── Image.gz                   # Compressed kernel (used for flashing)
│   │   ├── dtbo.img                   # Device tree blob overlay
│   │   └── dts/                       # Device tree source files
│   └── configs/
│       └── .config                    # Final kernel configuration
├── lib/modules/                       # Compiled modules
│   └── *.ko                           # Kernel module object files
├── vmlinux                            # Uncompressed kernel (debug symbols)
├── System.map                         # Kernel symbol map
└── [build artifacts]
```

### After Build

```
build_artifacts/                        # Final output directory
├── boot/
│   ├── Image.gz                       # Compressed kernel image (required)
│   ├── dtbo.img                       # Device tree overlay (optional)
│   └── [other .dtb/.dtbo files]       # Additional device trees
├── modules/
│   └── *.ko                           # All kernel modules
├── dts/
│   └── *.dtb/.dtbo                    # Device tree files
└── BUILD_INFO.txt                     # Build metadata and information
```

## Output Files

### 1. **Image.gz** (REQUIRED)
- **Size**: ~15-25 MB (typical)
- **Location**: `build_artifacts/boot/Image.gz`
- **Purpose**: Main kernel image (compressed with gzip)
- **Flashing**: `fastboot flash boot Image.gz`
- **Fallback**: If `Image.gz` doesn't exist, `Image` is compressed automatically

### 2. **dtbo.img** (OPTIONAL)
- **Size**: ~1-5 MB (typical)
- **Location**: `build_artifacts/boot/dtbo.img`
- **Purpose**: Device tree binary overlay
- **Flashing**: `fastboot flash dtbo dtbo.img`
- **Note**: Only created if device tree overlays are compiled

### 3. **Kernel Modules** (OPTIONAL)
- **Size**: Varies (typically 50-500 MB)
- **Location**: `build_artifacts/modules/*.ko`
- **Purpose**: Individual kernel module files
- **Usage**: Install on device for specific features
- **Count**: Number of .ko files varies by kernel config

### 4. **Device Tree Files** (OPTIONAL)
- **Size**: Individual .dtb files (100-500 KB each)
- **Location**: `build_artifacts/dts/`
- **Purpose**: Device tree binary files
- **Usage**: Referenced during boot

### 5. **BUILD_INFO.txt** (INFORMATIONAL)
- **Location**: `build_artifacts/BUILD_INFO.txt`
- **Purpose**: Complete build metadata and instructions
- **Contents**:
  - Device information
  - Build configuration
  - Integrations applied
  - Flashing instructions
  - File verification status
  - Build statistics

## Output Configuration in Workflow

### Build Phase

```yaml
- name: Build kernel image and modules
  run: |
    make -j$(nproc) \
      ARCH=arm64 \
      CC=clang \
      LD=ld.lld \
      O=out              # Output directory
```

**Key Options**:
- `O=out` - Specifies output directory (keeps source clean)
- `-j$(nproc)` - Parallel compilation using all CPU cores
- `CC=clang` - Use Clang compiler
- `ARCH=arm64` - ARM64 architecture

### Extraction Phase

```yaml
- name: Extract kernel artifacts
  run: |
    mkdir -p build_artifacts/{boot,modules,dts}
    
    # Copy kernel image
    cp out/arch/arm64/boot/Image.gz build_artifacts/boot/
    
    # Copy DTBO
    cp out/arch/arm64/boot/dtbo.img build_artifacts/boot/
    
    # Copy modules
    find out -name "*.ko" -exec cp {} build_artifacts/modules/ \;
    
    # Generate metadata
    cat > build_artifacts/BUILD_INFO.txt << EOF
    [Build information...]
    EOF
```

### Verification Phase

```yaml
- name: Verify build artifacts
  run: |
    # Check required files
    if [ ! -f "build_artifacts/boot/Image.gz" ]; then
      echo "❌ ERROR: Kernel image not found!"
      exit 1
    fi
    
    # List all artifacts
    find build_artifacts -type f | sort
    
    # Show summary
    du -sh build_artifacts
```

### Upload Phase

```yaml
- name: Upload build artifacts
  uses: actions/upload-artifact@v3
  with:
    name: kernel-sweet-${{ github.run_number }}
    path: build_artifacts/
    retention-days: 30
    if-no-files-found: error
```

## Error Handling

### Build Failures

If the build fails, the workflow:

1. **Captures diagnostics**:
   - Kernel directory structure
   - Output directory contents
   - ARM64-specific build artifacts
   - Last 50 lines of build output

2. **Provides debugging info**:
   - Run ID and link
   - Patch compatibility notes
   - Build output analysis

3. **Posts PR comments** (if on PR):
   - Build failure notification
   - Links to full logs
   - Debugging tips

### Missing Artifacts

If required artifacts are missing:

1. **Automatic fallback**:
   - If `Image.gz` not found, compress `Image` automatically
   - If `dtbo.img` not found, continue (optional)

2. **Verification**:
   - Checks for minimum required files
   - Reports missing optional files as warnings
   - Fails build if critical files missing

3. **Reporting**:
   - Lists all available artifacts
   - Shows file sizes and counts
   - Provides total artifact size

## Artifact Statistics

### Typical Output Sizes

```
Image.gz:    15-25 MB      (Compressed kernel image)
dtbo.img:    2-5 MB        (Device tree overlay)
Modules:     50-500 MB     (Depending on kernel config)
BUILD_INFO:  5-10 KB       (Metadata file)
────────────────────────
Total:       ~100-700 MB   (Typical range)
```

### File Counts

```
Total files:     50-200 (varies by kernel config)
├─ Boot files:   2-5 (Image.gz, dtbo.img, DTS files)
├─ Modules:      30-150 (.ko files)
└─ Other:        5-50 (config files, device trees)
```

## Output Verification Checklist

The workflow automatically verifies:

```
✅ Kernel image (Image.gz)      - Present
✅ DTBO image (dtbo.img)        - Present or optional
✅ Kernel modules (.ko files)   - Present or optional
✅ Device tree files            - Present or optional
✅ BUILD_INFO.txt              - Present
✅ Total artifact size          - Reported
✅ File count                   - Reported
```

## Accessing Outputs

### Via GitHub Actions

1. **Go to workflow run**: Actions tab → Build name
2. **Scroll to artifacts**: Look for "Artifacts" section
3. **Download**: Click "kernel-sweet-[number]" to download
4. **Extract**: Unzip the archive to get build artifacts

### Via Releases (for tagged builds)

1. **Create tag**: `git tag v1.0.0 && git push origin v1.0.0`
2. **Auto-release**: Workflow creates GitHub Release
3. **Assets**: All artifacts uploaded as release assets
4. **Share**: Easy shareable download links

## Logs and Diagnostics

### Build Logs

- **Location**: Workflow run logs (Actions tab)
- **Content**: Full build output, patches applied, configurations
- **Search**: Use browser search or download log file

### Summary Output

Printed during workflow:
- Kernel version
- Patches applied
- Build time
- Artifact statistics
- File verification

### BUILD_INFO.txt Contents

```
================================================================================
  KERNEL BUILD INFORMATION
================================================================================

Device:            Redmi Note 10 Pro (sweet)
Android Version:   16 QPR2
Build Date:        2026-05-13 12:34:56
Compiler:          Clang + LLVM

================================================================================
  INTEGRATIONS
================================================================================

✅ KOWSU/KernelSU    - Kernel-level root solution
✅ SUSFS             - Inline hook security filesystem
✅ LN8000 Patches    - 5 patches from CRDroid
[... more details ...]

================================================================================
  FILE SIZES
================================================================================

Image.gz:    18M
dtbo.img:    3M
Modules:     250M
Total:       271M

================================================================================
```

## Troubleshooting Output Issues

### Issue: Image.gz not found

**Solution**:
1. Check if `Image` exists (uncompressed version)
2. Workflow auto-compresses if needed
3. Check build logs for compilation errors
4. Verify kernel config options

### Issue: No modules (.ko files)

**Solution**:
1. Check if modules are configured: `grep CONFIG_MODULES .config`
2. Enable modules if disabled
3. Some modules may require additional config options
4. Not all kernel configs include modules

### Issue: dtbo.img missing (optional)

**Solution**:
1. DTBO is optional, build continues
2. Check device tree configuration
3. Verify device has device tree overlays
4. Check SM6150 kernel docs for DTBO support

### Issue: Artifact upload fails

**Solution**:
1. Verify build succeeded (no "❌" messages)
2. Check artifact directory exists and has files
3. Check GitHub Actions permissions
4. Review workflow logs for errors

## Configuration Customization

### Change Output Directory

Edit `.github/workflows/kernel-build.yml`:
```yaml
O=out          # Change 'out' to preferred directory
```

### Change Artifact Retention

Edit in `Upload build artifacts` step:
```yaml
retention-days: 30    # Change to desired days
```

### Add Custom Output Processing

Add new step after "Extract kernel artifacts":
```yaml
- name: Custom processing
  run: |
    # Your custom output processing
    cd build_artifacts
    # ... commands ...
```

## Best Practices

1. **Monitor artifact sizes**:
   - Keep track of total size trends
   - Remove old artifacts periodically
   - Consider compression for storage

2. **Verify before flashing**:
   - Check BUILD_INFO.txt
   - Verify Image.gz size (should be 15-25 MB)
   - Confirm patches applied

3. **Archive important builds**:
   - Download releases (permanent)
   - Keep version-tagged builds
   - Store build metadata

4. **Document custom changes**:
   - Note any custom patches
   - Document config changes
   - Track kernel modifications

---

**Output Configuration Status**: ✅ **COMPLETE**

All kernel outputs are properly configured, organized, and verified during the build process.
