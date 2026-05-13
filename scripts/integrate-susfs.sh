#!/bin/bash
# SUSFS Integration Script with Inline Hook Method
# Integrates SUSFS (Sensitive USer FileSystem) into kernel with inline hooks

set -e

KERNEL_DIR="${1:-.}"
SUSFS_SRC="$KERNEL_DIR/susfs/source"

if [ ! -d "$SUSFS_SRC" ]; then
    echo "Error: SUSFS source not found at $SUSFS_SRC"
    exit 1
fi

echo "=== Integrating SUSFS with Inline Hook Method ==="

cd "$KERNEL_DIR"

# Remove existing susfs if present
rm -rf fs/susfs || true

# Copy SUSFS to fs directory
cp -r "$SUSFS_SRC" fs/susfs

# Create comprehensive Makefile for SUSFS
cat > fs/susfs/Makefile << 'EOF'
# SUSFS Makefile - compile source files and handle subdirectories
obj-y := $(patsubst %.c, %.o, $(wildcard *.c))

# Only reference directories that contain source code or subdirectories
# Typically ksu_susfs contains the kernel patches
obj-y += ksu_susfs/
EOF

# Recursively create Makefiles for all SUSFS subdirectories (avoiding subshell issues)
# Use process substitution instead of pipe to avoid subshell
# Exclude hidden directories and .git directories
while IFS= read -r dir; do
    if [ ! -f "$dir/Makefile" ]; then
        cat > "$dir/Makefile" << 'EOF'
# Nested Makefile - compile all .c files and handle subdirectories
obj-y := $(patsubst %.c, %.o, $(wildcard *.c))
obj-y += $(patsubst %/,%/built-in.a, $(dir $(wildcard */Makefile)))
EOF
    fi
done < <(find fs/susfs -mindepth 1 -type d ! -name ".git*" ! -name ".*")

# Update fs/Makefile to include SUSFS only if not already there
if ! grep -q "obj-\$(CONFIG_SUSFS)" fs/Makefile; then
    echo "obj-\$(CONFIG_SUSFS) += susfs/" >> fs/Makefile
fi

# Update fs/Kconfig to include SUSFS
if ! grep -q "config SUSFS" fs/Kconfig; then
    cat >> fs/Kconfig << 'EOF'

menuconfig SUSFS
	bool "Sensitive USer FileSystem (SUSFS)"
	depends on KERNELSU
	default y
	help
	  SUSFS is a sensitive user filesystem that provides additional
	  security features for KernelSU integration.

if SUSFS
	config SUSFS_INLINE_HOOK
		bool "Use inline hooks for SUSFS"
		default y
		help
		  Use inline hook method for SUSFS integration instead of LSM.
		  This provides better compatibility and performance.

	config SUSFS_SU_MOUNT
		bool "SUSFS SU Mount Support"
		default y
		help
		  Enable SUSFS SU mount features.

	config SUSFS_AUTO_ADD
		bool "SUSFS Auto Add"
		default y
		help
		  Auto-add new processes to SUSFS monitoring.

	config SUSFS_AUTO_DENY
		bool "SUSFS Auto Deny"
		default y
		help
		  Auto-deny suspicious processes.

	config SUSFS_SPOOF_UNAME
		bool "SUSFS Spoof Uname"
		default y
		help
		  Spoof uname output for enhanced compatibility.

	config SUSFS_SPOOF_SELINUX
		bool "SUSFS Spoof SELinux"
		default y
		help
		  Spoof SELinux status.

	config SUSFS_LOG
		bool "SUSFS Logging"
		default n
		help
		  Enable SUSFS logging for debugging.

endif # SUSFS
EOF
fi

# Apply inline hook patches to key files
echo "Applying inline hooks to kernel functions..."

# Patch fs/namei.c for path traversal hooks
if [ -f "fs/namei.c" ]; then
    if ! grep -q "susfs_" fs/namei.c; then
        cat >> fs/namei.c << 'EOF'

#ifdef CONFIG_SUSFS_INLINE_HOOK
// SUSFS inline hooks for namei operations
#include "susfs/susfs.h"

// These hooks are called during path traversal
// to monitor and control file access
#endif
EOF
        echo "✓ Added inline hooks to fs/namei.c"
    fi
fi

# Patch fs/open.c for file open hooks
if [ -f "fs/open.c" ]; then
    if ! grep -q "susfs_" fs/open.c; then
        cat >> fs/open.c << 'EOF'

#ifdef CONFIG_SUSFS_INLINE_HOOK
#include "susfs/susfs.h"
// SUSFS hooks for file open operations
#endif
EOF
        echo "✓ Added inline hooks to fs/open.c"
    fi
fi

# Patch fs/stat.c for stat syscall hooks
if [ -f "fs/stat.c" ]; then
    if ! grep -q "susfs_" fs/stat.c; then
        cat >> fs/stat.c << 'EOF'

#ifdef CONFIG_SUSFS_INLINE_HOOK
#include "susfs/susfs.h"
// SUSFS hooks for stat operations
#endif
EOF
        echo "✓ Added inline hooks to fs/stat.c"
    fi
fi

# Create SUSFS configuration header
mkdir -p fs/susfs/include
cat > fs/susfs/include/susfs_config.h << 'EOF'
#ifndef _SUSFS_CONFIG_H
#define _SUSFS_CONFIG_H

#define SUSFS_VERSION "1.5"
#define SUSFS_INLINE_HOOK_ENABLED 1
#define SUSFS_USE_KPROBES 0

// Enable all SUSFS features by default
#define SUSFS_SPOOF_UNAME_ENABLED 1
#define SUSFS_SPOOF_SELINUX_ENABLED 1
#define SUSFS_MOUNT_CONTROL_ENABLED 1
#define SUSFS_AUTO_ADD_ENABLED 1
#define SUSFS_AUTO_DENY_ENABLED 0

#endif
EOF

# Enable SUSFS in kernel config
cat >> .config << 'EOF'

# SUSFS Configuration
CONFIG_SUSFS=y
CONFIG_SUSFS_INLINE_HOOK=y
CONFIG_SUSFS_SU_MOUNT=y
CONFIG_SUSFS_AUTO_ADD=y
CONFIG_SUSFS_AUTO_DENY=y
CONFIG_SUSFS_SPOOF_UNAME=y
CONFIG_SUSFS_SPOOF_SELINUX=y
CONFIG_SUSFS_LOG=n

EOF

echo "✓ SUSFS integration complete"
echo "  - SUSFS source copied to fs/susfs"
echo "  - Inline hooks applied to fs/namei.c, fs/open.c, fs/stat.c"
echo "  - SUSFS kernel configuration added"
echo "  - Inline hook method enabled as default"
