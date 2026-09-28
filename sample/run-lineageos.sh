#!/bin/bash
# Android 14 (LineageOS 21) - start it on Linux:   bash run-lineageos.sh
# Needs QEMU:  sudo apt install qemu-system-x86      (Ubuntu / Debian)
#              sudo dnf install qemu-system-x86      (Fedora)
cd "$(dirname "$0")" || exit 1

# --- first run: join the downloaded system-disk pieces into one file ---
if [ ! -f system-disk.vmdk ] && [ -f system-disk.vmdk.part000 ]; then
    echo "Joining system-disk.vmdk.part000, part001 ... into system-disk.vmdk (only once)"
    cat system-disk.vmdk.part[0-9][0-9][0-9] > system-disk.vmdk && rm -f system-disk.vmdk.part[0-9][0-9][0-9]
fi
if [ ! -f system-disk.vmdk ]; then
    echo "system-disk.vmdk is missing."
    echo "Download every system-disk.vmdk.part file from the GitHub release into this folder."
    exit 1
fi

if ! command -v qemu-system-x86_64 >/dev/null; then
    echo "QEMU is not installed. Install it first:"
    echo "   sudo apt install qemu-system-x86"
    exit 1
fi

# KVM makes it fast; without it QEMU still works, just slowly.
ACCEL=tcg
if [ -w /dev/kvm ]; then
    ACCEL=kvm
else
    echo "Note: KVM is not available, so Android will be slow."
    echo "      Fix: enable VT-x/AMD-V in the BIOS, then:  sudo usermod -aG kvm \$USER  (and log in again)"
fi

echo "Starting Android... the first boot takes a few minutes."
exec qemu-system-x86_64 \
  -name "LineageOS-PC" \
  -m 4096 \
  -smp 4 \
  -machine q35,accel=$ACCEL \
  -cpu max \
  -drive if=pflash,format=raw,readonly=on,file="qemu/share/edk2-x86_64-code.fd" \
  -drive if=pflash,format=raw,file="lineageos_VARS.fd" \
  -drive file="system-disk.vmdk",if=virtio,format=vmdk \
  -drive file="userdata-disk.qcow2",if=virtio,format=qcow2 \
  -vga virtio \
  -netdev user,id=net0 \
  -device virtio-net-pci,netdev=net0 \
  -usb -device usb-tablet
