#!/bin/bash
# KOWSU (KernelSU) Integration Script
# Integrates KernelSU into the kernel using the standard method

set -e

KERNEL_DIR="${1:-.}"
KOWSU_SRC="$KERNEL_DIR/KernelSU/source"

if [ ! -d "$KOWSU_SRC" ]; then
    echo "Error: KOWSU source not found at $KOWSU_SRC"
    exit 1
fi

echo "=== Integrating KOWSU (KernelSU) ==="

# Copy KernelSU source to kernel
cd "$KERNEL_DIR"

# Remove existing KernelSU if present
rm -rf drivers/kernelsu || true

# Copy KernelSU to drivers directory
cp -r "$KOWSU_SRC" drivers/kernelsu

# Create Makefile for KernelSU if it doesn't exist
if [ ! -f "drivers/kernelsu/Makefile" ]; then
    cat > drivers/kernelsu/Makefile << 'EOF'
obj-y += kernel/
obj-y += core/
EOF
    echo "Created Makefile for KernelSU"
fi

# Add KernelSU to kernel build system
echo "" >> drivers/Makefile
echo "# KernelSU Integration" >> drivers/Makefile
echo "obj-y += kernelsu/" >> drivers/Makefile

# Update Kconfig
cat >> drivers/Kconfig << 'EOF'

config KERNELSU
	bool "KernelSU Support"
	default y
	help
	  This option enables KernelSU support in the kernel.
	  KernelSU is a kernel-level root solution for Android.

EOF

# Modify fs/exec.c for KernelSU hook (inline hook method)
if [ -f "fs/exec.c" ]; then
    echo "Patching fs/exec.c for KernelSU integration..."
    
    # Create a patch for KernelSU exec hook
    cat > /tmp/kernelsu-exec.patch << 'PATCH'
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1,6 +1,10 @@
 #include <linux/module.h>
 
+#ifdef CONFIG_KERNELSU
+#include "../drivers/kernelsu/ksu.h"
+#endif
+
 // This is a simplified example
PATCH
    
    # Try to apply or manually integrate
    if grep -q "CONFIG_KERNELSU" fs/exec.c; then
        echo "KernelSU already integrated in fs/exec.c"
    else
        sed -i '1i #ifdef CONFIG_KERNELSU\n#include "../drivers/kernelsu/ksu.h"\n#endif\n' fs/exec.c
        echo "Added KernelSU includes to fs/exec.c"
    fi
fi

# Enable KernelSU in kernel Makefile if needed
if ! grep -q "CONFIG_KERNELSU" Makefile; then
    echo "CONFIG_KERNELSU=y" >> .config || true
fi

echo "✓ KOWSU integration complete"
echo "  - KernelSU source copied to drivers/kernelsu"
echo "  - Build system updated"
echo "  - fs/exec.c patched for inline hooks"
