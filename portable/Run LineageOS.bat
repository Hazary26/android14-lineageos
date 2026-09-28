@echo off
rem Android 14 (LineageOS 21) - double-click to start.
cd /d "%~dp0"
title LineageOS - Android 14

rem --- first run: join the downloaded system-disk pieces into one file ---
if not exist "system-disk.vmdk" if exist "system-disk.vmdk.part000" (
    echo Joining system-disk.vmdk.part000, part001 ... into system-disk.vmdk
    echo This happens only once and takes a minute or two.
    copy /b "system-disk.vmdk.part000" "system-disk.vmdk" >nul
    for %%p in (001 002 003 004 005 006 007 008 009) do (
        if exist "system-disk.vmdk.part%%p" copy /b "system-disk.vmdk" + "system-disk.vmdk.part%%p" "system-disk.vmdk" >nul
    )
    del "system-disk.vmdk.part*"
)

if not exist "system-disk.vmdk" (
    echo.
    echo   system-disk.vmdk is missing.
    echo   Download every system-disk.vmdk.part file from the GitHub release
    echo   and put them in this folder, next to this file.
    echo.
    pause
    exit /b 1
)

echo Starting Android... the first boot takes a few minutes.
"%~dp0qemu\qemu-system-x86_64.exe" ^
  -name "LineageOS-PC" ^
  -m 4096 ^
  -smp 4 ^
  -machine q35,accel=whpx:tcg ^
  -cpu max ^
  -drive if=pflash,format=raw,readonly=on,file="%~dp0qemu\share\edk2-x86_64-code.fd" ^
  -drive if=pflash,format=raw,file="%~dp0run_VARS.fd" ^
  -drive file="%~dp0system-disk.vmdk",if=virtio,format=vmdk ^
  -drive file="%~dp0userdata-disk.qcow2",if=virtio,format=qcow2 ^
  -vga virtio ^
  -display gtk ^
  -netdev user,id=net0 ^
  -device virtio-net-pci,netdev=net0 ^
  -usb -device usb-tablet

pause
