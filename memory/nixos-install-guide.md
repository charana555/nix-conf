# NixOS Install Guide - Dell Laptop (Step by Step)

## Before you reboot (do this in PopOS now)

### 1. Flash the ISO to USB
```bash
sudo cp /tmp/nixos-25.05-minimal.iso /dev/sda
sudo sync
```
Wait for sync to finish (returns to prompt).

### 2. Unplug phone (backup is done, safe to remove)

### 3. Keep USB plugged in. Reboot.
```bash
sudo reboot
```

---

## In NixOS Installer (after booting USB)

### 4. At Dell logo, press F12 repeatedly -> select USB drive

### 5. At NixOS boot menu, select default (NixOS 25.05 Installer)

### 6. At login prompt, log in as `root` (no password)

### 7. Connect to WiFi
```bash
# List networks
nmcli device wifi list

# Connect (replace YOUR_SSID and YOUR_PASSWORD)
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
```

### 8. Enable flakes + nix-command
```bash
nix-env -iA nixpkgs.git nixpkgs.just nixpkgs.nh
export NIX_CONFIG="experimental-features = nix-command flakes"
```

### 9. Clone your flake
```bash
cd /tmp
git clone git@github.com:charana555/nix-conf.git
cd nix-conf
```

If git clone fails (SSH key not available), use HTTPS instead:
```bash
git clone https://github.com/charana555/nix-conf.git
cd nix-conf
```

If that also fails, restore from phone backup (plug phone in, approve ADB):
```bash
nix-env -iA nixpkgs.android-tools
adb shell cat /sdcard/Download/popos-backup/nix-conf.tar > /tmp/nix-conf.tar
tar xf /tmp/nix-conf.tar -C /tmp
cd /tmp/nix-conf
```

### 10. Partition the disk with disko (THIS WIPES EVERYTHING)
```bash
nix run github:nix-community/disko -- \
  --flake /tmp/nix-conf#dell --mode destroy,format,mount
```

This will:
- Wipe /dev/nvme0n1 completely (all partitions, LUKS, LVM, data)
- Create ESP (512M, /boot) + LUKS + btrfs (/root, /persistent, /nix)
- Mount everything at /mnt

Type "y" when prompted to confirm destruction.

### 11. Generate hardware config
```bash
nixos-generate-config --root /mnt --show-hardware-config > /tmp/nix-conf/hosts/nixos/dell/hardware.nix
```

Review it to verify it detected NVMe + Raptor Lake modules:
```bash
cat /tmp/nix-conf/hosts/nixos/dell/hardware.nix
```

### 12. Copy age key for sops decryption
The age key is needed to decrypt SSH key + k3s token during install.

From phone (if plugged in + ADB approved):
```bash
adb shell cat /sdcard/Download/popos-backup/age-key.txt > /mnt/home/itachi/.config/sops/age/keys.txt
mkdir -p /mnt/home/itachi/.config/sops/age
```

Wait - do this AFTER creating the user. Actually, sops-nix handles this during nixos-install.
The age key needs to be at the path specified in dell/default.nix:
  /home/itachi/.config/sops/age/keys.txt

But the user home doesn't exist yet. Create the directory:
```bash
mkdir -p /mnt/home/itachi/.config/sops/age
```

Then copy the key (from phone):
```bash
adb shell cat /sdcard/Download/popos-backup/age-key.txt > /mnt/home/itachi/.config/sops/age/keys.txt
chmod 600 /mnt/home/itachi/.config/sops/age/keys.txt
```

If phone not available, you can type it manually (it's 189 bytes).
Or use the backup on gdrive:
```bash
nix-env -iA nixpkgs.rclone
rclone copy gdrive:popos-backup-2026-08-23/secrets/aws-token /mnt/tmp-secrets/
```

### 13. Install NixOS
```bash
nixos-install --flake /tmp/nix-conf#dell --root /mnt
```

This will take 10-30 minutes (downloading/building packages).
It will prompt you to set a root password at the end.

### 14. Reboot
```bash
reboot
```
Remove the USB when the screen goes black.

---

## Post-Install (first boot in NixOS)

### 15. Login as `itachi` (auto-login on tty1, Hyprland launches)

### 16. Hyprland should launch automatically (via uwsm)
If it doesn't, check:
```bash
uwsm start hyprland-uwsm.desktop
```

### 17. Connect to WiFi
```bash
nmcli device wifi connect "YOUR_SSID" password "YOUR_PASSWORD"
```

### 18. Start Tailscale
```bash
sudo tailscale up
```
Authenticate via the URL it prints. This re-auths your device on the tailnet.

### 19. Verify k3s agent joined the cluster
```bash
sudo systemctl status k3s
```
It should connect to https://100.126.165.111:6443 automatically (token from sops).

### 20. Restore data from phone
Plug phone in, approve ADB:
```bash
# Pictures
adb shell cat /sdcard/Download/popos-backup/pictures.tar > /tmp/pictures.tar
tar xf /tmp/pictures.tar -C ~/
rm /tmp/pictures.tar

# Codebase
adb shell cat /sdcard/Download/popos-backup/codebase.tar > /tmp/codebase.tar
tar xf /tmp/codebase.tar -C ~/
rm /tmp/codebase.tar

# YouTube downloads
mkdir -p ~/charana/ydl
adb shell ls /sdcard/Download/popos-backup/ydl/
adb pull /sdcard/Download/popos-backup/ydl/ ~/charana/ydl/
```

### 21. Restore browser profiles from gdrive (optional)
```bash
rclone copy gdrive:popos-backup-2026-08-23/brave/brave.tar /tmp/
tar xf /tmp/brave.tar -C ~/.var/app/
```

### 22. Verify everything works
```bash
# GPU
nvidia-offload glxinfo | grep "OpenGL renderer"

# Docker
docker run hello-world

# Git identity
git config user.email
# Should show: charanchandrashekar555@gmail.com

# SSH key decrypted by sops
cat ~/.ssh/id_ed25519 | head -1
# Should show: -----BEGIN OPENSSH PRIVATE KEY-----

# Thermal
systemctl status thermald

# Power profiles
powerprofilesctl get
```

---

## Troubleshooting

### disko fails
- Make sure you're using `--mode destroy,format,mount`
- Check the disk device: `lsblk` - should be /dev/nvme0n1
- If LUKS is giving issues, manually wipe first:
  ```bash
  cryptsetup luksErase /dev/nvme0n1p3
  ```

### nixos-install fails to decrypt sops secrets
- The age key must be at /mnt/home/itachi/.config/sops/age/keys.txt BEFORE running nixos-install
- Verify: `cat /mnt/home/itachi/.config/sops/age/keys.txt`
- It should start with "AGE-SECRET-KEY-"

### Hyprland doesn't launch
- Check logs: `journalctl -u display-manager.service`
- Try manual start: `uwsm start hyprland-uwsm.desktop`
- Fall back to TTY: Ctrl+Alt+F2, then `start-hyprland`

### No WiFi
- Check interface: `ip link`
- NetworkManager should be enabled: `systemctl status NetworkManager`
- If not: `sudo systemctl start NetworkManager`

### k3s doesn't connect
- Check logs: `sudo systemctl status k3s`
- Verify Tailscale is up: `tailscale status`
- The server IP (100.126.165.111) must be reachable via Tailscale
- Token is in sops at k3s/token

---

## Files on phone (/sdcard/Download/popos-backup/)
- age-key.txt (189 bytes) - sops decryption key
- nix-conf.tar (990K) - flake repo backup
- pictures.tar (18G) - all photos
- codebase.tar (6.1G) - code projects
- ydl/ (7.9G) - YouTube downloads

## Files on gdrive (gdrive:popos-backup-2026-08-23/)
- secrets/ - aws-token, env
- ssh/ - public keys, known_hosts
- gnupg/ - GPG keyring
- Documents/ - resumes, templates
- charana/ - Books, Docs, juspay, SSH
- Downloads/ - lecture PDFs, wallpaper
- k3s/ - join script
- Fonts/ (tar)
- Backups/ (tar)
- brave/ (tar) - browser profile
- edge/ (tar) - browser profile
- zen/ (tar) - browser profile
- mozilla/ - Firefox profile
- telegram/ - chat data
- intellij/ (tar) - IDE config
- whatsapp/ (tar) - chat data
- claude-data/ - Claude AI data
- claude-config/ - Claude config
- opencode-data/ - opencode data
- opencode-config/ (tar)
- nvim-data/ (tar)
- steam-userdata/ - cloud saves
- config/cosmic/ - COSMIC settings
- config/Nextcloud/ - Nextcloud config
- config/input-remapper-2/
