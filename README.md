# Android 14 (LineageOS 21) on your PC

Run **Android 14** as a window on your Windows or Linux computer. It uses **QEMU**, a free
virtual-machine program. There's nothing to install on Windows, because QEMU is included.

It comes in two editions. Both run the same Android 14 (LineageOS 21.0, with Google Play):

| Edition | Download page | What's in it |
|---|---|---|
| **Android 14 LineageOS Portable** | [Release: portable-v1](../../releases/tag/portable-v1) | The ready-to-run version. **Start here.** |
| **Android 14 LineageOS** | [Release: lineageos-v1](../../releases/tag/lineageos-v1) | The original ("sample") build, plus its extra boot and installer images. |

Each edition is a complete download of about 6.5 GB. You only need one of them.

---

## What you need

- A 64-bit **Windows 10/11** or **Linux** PC
- **8 GB RAM** or more (Android uses 4 GB)
- **20 GB free disk space** (the data disk grows as you install apps, up to 128 GB)
- **Virtualization turned on** in the BIOS (called *Intel VT-x*, *AMD-V* or *SVM*).
  Without it, Android still works, but very slowly.

---

## Step 1 – Download

Open the release page for the edition you want (links in the table above). Under **Assets**,
download **all** of these files:

| File | What it is |
|---|---|
| `LineageOS-Portable.zip` *(or `SampleLineageOS.zip`)* | Start scripts, QEMU, firmware and an empty data disk |
| `system-disk.vmdk.part000` | Android itself, piece 1 |
| `system-disk.vmdk.part001` | piece 2 |
| `system-disk.vmdk.part002` | piece 3 |
| `system-disk.vmdk.part003` | piece 4 |
| `SHA256SUMS.txt` | Optional: checksums to check your download |

> Android itself is 6.5 GB, and GitHub only allows files up to 2 GB, so it's split into
> 4 pieces. The start script joins them back together the first time you run it.

## Step 2 – Put the files together

1. **Extract** the `.zip` file (right-click → *Extract All…* on Windows). You get a folder called
   `LineageOS-Portable` (or `SampleLineageOS`).
2. **Move** all four `system-disk.vmdk.part…` files **into that folder**.

The folder should now look like this:

```
LineageOS-Portable/
├── Run LineageOS.bat        ← Windows: double-click this
├── run-lineageos.sh         ← Linux: run this
├── system-disk.vmdk.part000
├── system-disk.vmdk.part001
├── system-disk.vmdk.part002
├── system-disk.vmdk.part003
├── userdata-disk.qcow2
├── run_VARS.fd
├── README.txt
└── qemu/
```

## Step 3 – Start Android

### Windows
Double-click **`Run LineageOS.bat`**.

- The first time, it spends a minute or two joining the pieces.
- An Android window then opens. **The first boot takes 3–5 minutes**, and a black screen is normal during this time.
- If Windows shows "*Windows protected your PC*", click **More info → Run anyway**.

**Make it fast (recommended):** open *Start → "Turn Windows features on or off"*, tick
**Windows Hypervisor Platform**, click OK and restart the PC. Without this, Android runs
in slow software mode.

### Linux
```bash
sudo apt install qemu-system-x86
```
```bash
cd ~/Downloads/LineageOS-Portable && bash run-lineageos.sh
```
(Use `dnf` instead of `apt` on Fedora.) If it says *KVM is not available*, enable
virtualization in the BIOS and run `sudo usermod -aG kvm $USER`, then log out and back in.

## Step 4 – Set up Android

On the **"Hi there"** screen, press **Start** and go through the setup like on a new phone.
Connect to Wi-Fi when asked (the network already works through your PC). To install apps,
open the **Play Store** and sign in with your Google account.

Everything you do in Android is saved in `userdata-disk.qcow2` inside the folder.

---

## Tips

- **Shut down properly:** use Android's power menu → *Power off*. Closing the window
  while Android runs is like pulling the plug, and it can damage your saved data.
- **Start over / factory reset:** delete `userdata-disk.qcow2`, then put back a fresh copy from
  the `.zip`.
- **Mouse stuck in the window?** Press **Ctrl + Alt + G** to release it.
- **More RAM or CPU cores:** open the start script in a text editor and change
  `-m 4096` (MB of RAM) and `-smp 4` (CPU cores).
- **Move it to another PC or a USB drive:** copy the whole folder. It's fully portable.

## Troubleshooting

| Problem | Fix |
|---|---|
| `system-disk.vmdk is missing` | You didn't put all 4 `.part` files into the folder. Download them again. |
| Very slow / takes forever | Turn on virtualization in the BIOS, and on Windows enable *Windows Hypervisor Platform* (see Step 3). |
| Black window for a long time | The first boot takes up to 5 minutes. Wait. |
| Android shows *"Can't load Android system"* | The data disk was damaged. Delete `userdata-disk.qcow2`, then copy a fresh one from the `.zip`. |
| Pieces joined, but it won't boot | A piece may be damaged. Check it against `SHA256SUMS.txt` (see below) and re-download any that don't match. |

**Check the downloaded pieces.** Do this before the first run, because the script deletes the pieces after joining them.
- Linux: `sha256sum -c SHA256SUMS.txt --ignore-missing`
- Windows (PowerShell): `Get-FileHash system-disk.vmdk.part000` and compare the value with `SHA256SUMS.txt`

---

## About

- **Android:** LineageOS 21.0 (Android 14), x86_64 build, kernel 6.1
- **Emulator:** QEMU for Windows 11.1.0 (included in `qemu/`), licensed under GPL v2. Its source code is available at
  <https://www.qemu.org/download/>, and the license is in `qemu/COPYING`.
- The data disk ships **empty**, so no personal data is included. Everyone starts from the setup screen.
