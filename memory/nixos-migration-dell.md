# NixOS Migration Plan - Dell laptop (PopOS to NixOS)

**Source system**: Pop!_OS 24.04 LTS with COSMIC desktop
**Target system**: NixOS 25.05 with Hyprland
**Hardware**: Dell laptop, Intel i5-13450HX, 16GB RAM, Intel UHD + NVIDIA RTX 3050 6GB (Optimus)
**Disk**: 1TB NVMe SK hynix BC901, UEFI boot, currently LUKS + LVM + ext4
**Date**: 2026-08-23

---

## Decisions

| Decision | Choice |
|----------|--------|
| Desktop | Hyprland (already wired in flake) |
| Disk | Fresh LUKS + btrfs via disko (wipes 1TB NVMe) |
| Services to keep | Tailscale, Docker, k3s agent, thermald + PPD, NVIDIA powerManagement |
| Services dropped | PostgreSQL, MySQL, Ollama, input-remapper, CUPS, OpenVPN, VirtualBox |

**Minor defaults** (trivial to change later):
- Hostname: `dell`
- Username: `itachi` (from config.nix `users.personal`, matches current user)
- NVIDIA driver: proprietary stable (580.x)
- Kernel: default NixOS kernel (cachyos kernel input available if wanted)

---

## Hardware audit

- CPU: Intel i5-13450HX (Raptor Lake, 10C/16T, up to 4.6GHz)
- RAM: 16GB
- iGPU: Intel UHD Graphics (`i915`), Bus ID `PCI:0:2:0`
- dGPU: NVIDIA RTX 3050 6GB Laptop (`nvidia` 580.173.02), Bus ID `PCI:1:0:0`
- Storage: 1TB NVMe SK hynix BC901
- WiFi+BT: Intel AX201 (USB bus)
- Webcam: Microdia Integrated_Webcam_HD
- Boot: UEFI, systemd-boot, kernel 7.0.11 (PopOS)
- Current disk layout: LUKS -> LVM -> ext4 root + 4G encrypted swap + zram 15.3G + ESP + 4G recovery

---

## What nix-conf already has (reusable)

- `nix-wire` + `flake-parts` flake structure
- sops-nix, disko, stylix, home-manager, hyprland, nixvim inputs
- Home-manager fully migrated (zsh, git, starship, tmux, kitty, nixvim, fzf, bat, eza, zoxide, direnv)
- NixOS base modules: `nix-ld`, `envfs`, audio, bluetooth, touchpad, intel graphics
- Existing `hosts/nixos/vivo/` as template (different machine: Ice Lake, 8GB, SATA HDD)
- disko btrfs-enc template

---

## Gaps for this Dell laptop

1. New NixOS host for this machine (vivo is wrong hardware + wrong DE)
2. `hardware.nix` via `nixos-generate-config` (Raptor Lake, NVMe, dual GPU)
3. NVIDIA module (`modules/nixos/nvidia.nix`) - does not exist; need modesetting + Prime offload
4. COSMIC module - not in nix config (only Hyprland) - NOT being built (chose Hyprland)
5. `disk.nix` - use existing disko btrfs-enc template
6. System-service modules - k3s, tailscale, docker, thermald, PPD - none wired yet
7. App packages - Brave/Edge/IntelliJ/Telegram/VLC/GIMP not in home modules (deferred)

---

## Phase 0 - Pre-migration (before touching the disk)

### 0.1 Back up data to external drive
- `/home/itachi/` - dotfiles, `.config/`, `.mozilla/`, `.minecraft/`, `.claude/`, `.ssh/` (only known_hosts, keys come from sops), Documents, Downloads, code repos
- DB dumps: not needed (dropping postgres/mysql)
- Docker volumes: `docker save` any images to keep, or re-pull on NixOS
- k3s: note cluster join token + server URL (check `/etc/rancher/k3s/k3s.yaml` or `install-k3s.sh`)
- Tailscale: `tailscale up` on new install re-auths same device (or `tailscale login` after removing old node)
- Browser profiles (Brave, Edge, Firefox): sync to cloud or copy `~/.config/BraveSoftware/`, `~/.mozilla/`
- Flatpak app data: most is cloud-synced or disposable

### 0.2 Prepare install media
- Download NixOS 25.05 ISO (matches `system.stateVersion`)
- Flash to USB: `cp nixos.iso /dev/sdX && sync`
- Boot from USB (Dell F12 boot menu)

### 0.3 Verify backup is restorable
- Mount external drive, spot-check files. This is the one irreversible step.

---

## Phase 1 - Scaffold new NixOS host in the flake

Create `hosts/nixos/dell/` modeled on `hosts/nixos/vivo/` corrected for this hardware.

### 1.1 `hosts/nixos/dell/default.nix` - host entry
- Imports: `nixosModules.default`, `nixosModules.hardware`, `nixosModules.intel`, `nixosModules.nvidia` (new), `nixosModules.hyprland`, `nixosModules.stylix`, `nixosModules.services` (new), `sops-nix`, `disko`, `./disk.nix`, `./hardware.nix`, `./users/itachi.nix`
- `networking.hostName = "dell"`
- `boot.loader.systemd-boot` with `efiSysMountPoint = "/boot"`
- `networking.networkmanager.enable = true`
- User `itachi` (from `config.nix` -> `users.personal`), shell zsh, wheel + docker + networkmanager groups
- `security.sudo.wheelNeedsPassword = false`
- Sops: age key at `~/.config/sops/age/keys.txt`, SSH private key secret at `~/.ssh/id_ed25519`
- `zramSwap` enable with zstd (16GB RAM)
- `time.timeZone = "Asia/Kolkata"`, `i18n.defaultLocale = "en_US.UTF-8"`
- `system.stateVersion = "25.05"`

### 1.2 `hosts/nixos/dell/hardware.nix` - generated, not hand-written
- Run `sudo nixos-generate-config --show-hardware-config --root /mnt` after disko partitioning (Phase 3)
- Will contain: Raptor Lake initrd modules (`nvme`, `xhci_pci`, `usbhid`, `aes_x86_64` for LUKS), `kvm-intel`
- `hardware.enableRedistributableFirmware = true`
- `services.fstrim.enable = true` (SSD trim)
- `nixpkgs.hostPlatform = "x86_64-linux"`

### 1.3 `hosts/nixos/dell/disk.nix` - disko config
- Use `flake.disko.partition` with `device = "/dev/nvme0n1"`, `encrypted = true`, `ssd = true`
- SSD options: `["ssd" "discard=async" "space_cache=v2"]`
- No HDD mount (this laptop has no secondary HDD)
- ESP at `/boot` (512M), root LUKS -> btrfs with subvolumes `/root`, `/persistent`, `/nix`

### 1.4 `hosts/nixos/dell/users/itachi.nix` - home-manager wiring
- Based on `hosts/nixos/vivo/users/charana.nix` but uses `users.personal` (username `itachi`)
- Imports: `homeModules.terminal`, `homeModules.browser`, `homeModules.editor`, `homeModules.apps`
- `apps.keepassxc.enable = true`, `apps.nextcloud.enable = true`, `apps.discord.enable = true`, `apps.steam.enable = true`, `apps.skLauncher.enable = true`
- Git identity from `config.nix` -> `users.personal`
- Hyprland added via `nixosModules.hyprland` sharedModules (same as vivo)

### 1.5 Wire the host into the flake
- `nix-wire` auto-discovers `hosts/nixos/*/default.nix`, no manual `nixosConfigurations` entry needed
- Verify with `nix flake show` after scaffolding

---

## Phase 2 - New NixOS modules

### 2.1 `modules/nixos/nvidia.nix` (new)

Optimus hybrid setup for Intel iGPU + RTX 3050 dGPU:

```nix
hardware.nvidia = {
  modesetting.enable = true;         # already in kernel cmdline
  powerManagement.enable = true;      # dGPU sleep (Optimus)
  powerManagement.finegrained = true; # finer-grained power control (Ampere+)
  open = false;                       # proprietary (stable); open works on Ampere
  package = config.boot.kernelPackages.nvidiaPackages.stable;  # 580.x
  prime = {
    offload = {
      enable = true;                  # dGPU on-demand (battery-friendly)
      enableOffloadCmd = true;        # `nvidia-offload` command
    };
    intelBusId = "PCI:0:2:0";         # from lspci: 0000:00:02.0
    nvidiaBusId = "PCI:1:0:0";        # from lspci: 0000:01:00.0
  };
};
```

Bus IDs verified from lspci output: Intel at `00:02.0`, NVIDIA at `01:00.0`.

### 2.2 `modules/nixos/services/` module group (new)

Create `modules/nixos/services/default.nix` that auto-imports:

- `tailscale.nix` - `services.tailscale.enable = true`, `services.tailscale.useSettle = true`. Auth key in sops for unattended re-auth, or manual `tailscale up` on first boot.
- `docker.nix` - `virtualisation.docker.enable = true`, add user to `docker` group, `virtualisation.docker.storageDriver = "btrfs"` (matches filesystem).
- `k3s.nix` - `services.k3s.role = "agent"`, `services.k3s.serverAddr` from sops secret, `services.k3s.tokenPath` from sops secret. Extract from `install-k3s.sh` and current `/etc/rancher/k3s/` config.
- `power.nix` - `services.thermald.enable = true`, `services.power-profiles-daemon.enable = true`. Replaces System76 PowerDaemon.

Add `services` to the host imports in `default.nix`.

### 2.3 Update `modules/nixos/default.nix`
- Add `flake.nixosModules.services` to the export list alongside existing `default`, `hardware`, `intel`, `hyprland`, `stylix`.

---

## Phase 3 - Install procedure

### 3.1 Boot NixOS live USB, connect to WiFi

### 3.2 Partition with disko (wipes the disk)
```bash
git clone <your-repo> /tmp/nix-conf
cd /tmp/nix-conf

sudo nix --experimental-features "nix-flakes nix-command" \
  run github:nix-community/disko -- \
  --flake /tmp/nix-conf#dell --mode destroy,format,mount
```
This creates the LUKS + btrfs layout, opens it, and mounts at `/mnt`.

### 3.3 Generate hardware config
```bash
sudo nixos-generate-config --root /mnt --show-hardware-config > /tmp/nix-conf/hosts/nixos/dell/hardware.nix
```
Review the output - verify it has `nvme`, `xhci_pci`, `usbhid`, LUKS-related modules.

### 3.4 Install
```bash
sudo nixos-install --flake /tmp/nix-conf#dell --root /mnt
```
Set root password when prompted. Reboot.

### 3.5 First boot
- Hyprland launches via greetd or auto-login
- Run `tailscale up` to re-auth the node
- Restore data from backup to `/home/itachi/`

---

## Phase 4 - Post-install verification checklist

| Check | Command | Expected |
|-------|---------|----------|
| Hyprland launches | Login -> Hyprland session | Desktop appears |
| Intel iGPU rendering | `glxinfo \| grep "OpenGL renderer"` | Intel UHD |
| NVIDIA dGPU offload | `nvidia-offload glxinfo \| grep renderer` | RTX 3050 |
| dGPU sleeps when idle | `cat /proc/driver/nvidia/gpus/*/power` | D3cold |
| Tailscale connected | `tailscale status` | Connected |
| Docker works | `docker run hello-world` | Runs |
| k3s agent joined | `kubectl get nodes` | Node ready |
| Thermal protection | `systemctl status thermald` | Active |
| Power profiles | `powerprofilesctl get` | balanced |
| zsh + starship + tmux | Open kitty | All present |
| nixvim | `nvim` | Loads config |
| Git identity | `git config user.email` | charanchandrashekar555@gmail.com |
| Sops SSH key | `cat ~/.ssh/id_ed25519` | Decrypted, 0600 |
| btrfs trim | `systemctl status fstrim.timer` | Active |
| Disk space | `df -h /` | ~900G available |

---

## Out of scope (deferred)

- COSMIC on NixOS - chose Hyprland. Can add as module later.
- PostgreSQL/MySQL/Ollama - dropped per choice. Add as modules when needed.
- VirtualBox - dropped. `virtualisation.libvirtd` is the NixOS-native path for VMs later.
- Flatpak apps (Brave, Edge, IntelliJ, Telegram, VLC, GIMP) - not yet in home modules. Some have nixpkgs equivalents (`brave`, `telegram-desktop`, `vlc`, `gimp`, `jetbrains.idea-community`). Add to `modules/home/apps/` during/after migration.
- Firefox/Zen browser - `browser/zen.nix` module + firefox-addons input exist. Add Zen to user imports if wanted.
- OpenVPN - dropped. Tailscale covers device mesh.

---

## Execution order

1. Scaffold Phase 1 files (host + user + disk)
2. Write Phase 2 modules (nvidia + services)
3. `nix flake check` - verify evaluation
4. Back up data (Phase 0)
5. Boot USB, disko, install (Phase 3)
6. Verify (Phase 4)

Steps 1-3 are safe to do now on this PopOS system - they only add files to the flake, nothing runs. The disk only gets touched in Phase 3 when booting the USB and running disko.
