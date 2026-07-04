#!/bin/bash
set -e

echo "=================================================="
echo "Building DDNet for Wii U..."
echo "=================================================="

# Check if Docker is running
if ! docker ps >/dev/null 2>&1; then
    echo "ERROR: Docker is not running!"
    echo "Please start the Docker daemon and try again."
    exit 1
fi

# 1. Rebuild ELF
echo "[1/3] Compiling fresh binary via devkitpro Docker..."
docker run --rm -v "$(pwd):/src" -w /src/build devkitpro/devkitppc:latest bash -c "make -j4"

# 2. Apply Patches
echo "[2/3] Applying PowerPC instruction patches..."
python3 wiiu_tools/patch_atomics_universal.py build/DDNet.elf
python3 wiiu_tools/patch_elf.py build/DDNet.elf

# 3. Package
echo "[3/3] Packaging RPX and WUHB..."
docker run --rm -v "$(pwd):/src" -w /src devkitpro/devkitppc:latest bash -c "/opt/devkitpro/tools/bin/elf2rpl build/DDNet.elf build/DDNet.rpx && /opt/devkitpro/tools/bin/wuhbtool build/DDNet.rpx build/DDNet.wuhb --content=build/wiiu_content --name='DDraceNetwork' --short-name='DDNet' --author='DDNet team' --icon=build/icon.png --tv-image=build/tv_image.png --drc-image=build/drc_image.png > /dev/null"

echo "=================================================="
echo "SUCCESS: build/DDNet.wuhb is ready!"
echo "=================================================="
