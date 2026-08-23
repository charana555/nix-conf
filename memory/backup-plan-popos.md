# Backup Plan - PopOS Data Before NixOS Migration

**System**: Dell laptop, Pop!_OS 24.04 -> NixOS 25.05
**Total disk used**: 471G, but only ~30-40G is real user data. The rest is disposable.
**Date**: 2026-08-23

---

## What NOT to backup (disposable - 430G+)

These regenerate, re-download, or get replaced by NixOS config. Skip entirely.

### System and package data (regenerates from flake or re-install)
| Path | Size | Why skip |
|------|------|----------|
| `/nix/store` | 55G | Regenerates from flake |
| `/usr` | 26G | System packages, NixOS replaces |
| `/var/lib/rancher/k3s` | 125G | Container images/snapshots, re-pull on NixOS k3s |
| `/var/lib/flatpak` | 9G | Flatpak runtimes, re-install |
| `/var/lib/snapd` | 1.9G | Snaps, re-install (dropping snap on NixOS) |
| `/var/lib/apt` | 376M | Apt metadata |
| `/var/lib/dpkg` | 114M | Dpkg database |

### Game data (re-downloadable from Steam)
| Path | Size | Why skip |
|------|------|----------|
| `~/.local/share/Steam/steamapps/common/PUBG` | 53G | Re-download from Steam |
| `~/.local/share/Steam/steamapps/common/Warframe` | 53G | Re-download from Steam |
| `~/.local/share/Steam/steamapps/common/*` (other) | ~9G | Re-download from Steam |
| `~/.local/share/Steam/*` (client binaries) | ~3G | Steam client, regenerates |
| `~/.var/app/org.tlauncher.TLauncher` | 1.8G | Minecraft launcher, re-install |

### Caches and toolchains (regenerates)
| Path | Size | Why skip |
|------|------|----------|
| `~/.cache` | 16G | Caches, disposable |
| `~/.npm` | 7.8G | npm cache |
| `~/.config/colima` | 9.7G | Colima VM image (using native docker on NixOS) |
| `~/VirtualBox VMs` | 10G | Dropping VirtualBox. If a VM is irreplaceable, export it separately first. |
| `~/.vscode` | 1.5G | VS Code extensions, re-install |
| `~/.config/Code` | 693M | VS Code cache/data |
| `~/.local/share/flatpak` | 11G | Flatpak app data (per-app data backed up selectively below) |
| `~/.local/share/pnpm` | 740M | pnpm store, regenerates |
| `~/.config/discord` | 1.3G | Discord cache (chat data backed up below) |
| `~/.local/share/fonts` | 420M | Fonts managed by stylix/nix now |
| `~/.local/share/icons` | 101M | Icons |
| `~/.rustup` | 1.4G | Rust toolchain, reinstall via nix |
| `~/.cargo` | 32M | Cargo cache |
| `~/.nvm` | 1.2G | Node version manager, use nix |
| `~/.m2` | 324M | Maven cache |
| `~/.jdks` | 346M | JDKs, use nix |
| `~/.dotnet` | 256K | .NET, use nix |
| `~/.bun` | 620K | Bun, use nix |
| `~/.yarn` | 418M | Yarn cache |
| `go` | 4.1G | Go workspace cache |
| `~/.openjfx` | 104M | JavaFX |
| `~/squashfs-root` | 41M | Extracted snap, disposable |
| `~/discord.deb` | 2.1M | Installer |
| `~/TslGame.exe` | 221M | Random game binary |
| `~/.var/app/com.discordapp.Discord` | 516M | Discord cache |
| `~/.var/app/com.microsoft.Edge` | 277M | Edge browser data (if not synced) |

### Downloads to skip (re-downloadable)
| Path | Size | Why skip |
|------|------|----------|
| `~/Downloads/rhel-10.1-x86_64-dvd.iso` | 9.5G | ISO, re-download |
| `~/Downloads/mysql-*.deb` | ~600M | MySQL debs, not needed |
| `~/Downloads/code_*.deb` | 112M | VS Code deb |
| `~/Downloads/virtualbox-*.deb` | 109M | VirtualBox deb |
| `~/Downloads/TLauncher.flatpak` | 48M | Re-download |
| `~/Downloads/steam_latest.deb` | 20M | Re-download |

---

## MUST backup (irreplaceable user data) - ~30G

### Photos and media
| Path | Size | Notes |
|------|------|-------|
| `~/Pictures` | 19G | Photos, screenshots. Irreplaceable. |
| `~/charana/ydl` | 8.0G | YouTube downloads. Keep if you want them. |

### Documents and work
| Path | Size | Notes |
|------|------|-------|
| `~/charana/Books` | 454M | Books |
| `~/charana/Docs` | 40M | Documents |
| `~/charana/juspay` | 14M | Work files |
| `~/charana/SSH` | 20K | SSH-related files |
| `~/Documents` | 7M | Resumes, templates, Swagger |
| `~/Downloads/Lecture *.pdf` | ~20M | Academic material (matrix algebra lectures) |
| `~/Downloads/Booksmart*.mkv` | 3.5G | Movie. Your call. Skip if disposable. |
| `~/Downloads/wallpaperflare*.jpg` | 1.5M | Wallpaper |

### Code
| Path | Size | Notes |
|------|------|-------|
| `~/codebase/*` | 6.6G | Check each project: if pushed to GitHub/GitLab, skip. If local-only, backup. |

### Secrets and keys (CRITICAL)
| Path | Size | Notes |
|------|------|-------|
| `~/.config/secrets/aws-token` | 133B | AWS token. Better: move to sops-nix on NixOS. |
| `~/.config/secrets/env` | 213B | Env secrets. Better: move to sops-nix. |
| `~/.config/secrets/test-dummy` | 40B | Test secret. |
| `~/.gnupg` | small | GPG keyring (pubring.kbx, trustdb.gpg). Check for private keys. |
| `~/.ssh/id_ed25519.pub` | 81B | Public key (already in config.nix, but keep for reference) |
| `~/.ssh/known_hosts` | 5K | Known hosts (regenerates, but keep for reference) |
| `~/.ssh/config.backup` | 971B | Old SSH config (reference) |
| `~/.ssh/authorized_keys` | 101B | Authorized keys |

Note: `~/.ssh/id_ed25519` is a symlink to sops secret - it comes from sops-nix on NixOS, do not backup the symlink.

### Fonts
| Path | Size | Notes |
|------|------|-------|
| `~/Fonts` | 274M | Custom fonts. Some may be in nixpkgs, but keep for reference. |

---

## RECOMMEND backup (saves time reconfiguring) - ~5G

### Browser data (if not cloud-synced)
| Path | Size | Notes |
|------|------|-------|
| `~/.config/mozilla` | 62M | Firefox profile (bookmarks, passwords, history) |
| `~/.var/app/com.brave.Browser` | 2.4G | Brave profile (check if Brave Sync is on - if so, skip) |
| `~/.config/zen` | 249M | Zen browser profile |

### App data with value
| Path | Size | Notes |
|------|------|-------|
| `~/.local/share/Steam/userdata` | 228K | Steam cloud saves (small, always backup) |
| `~/.var/app/org.telegram.desktop` | 73M | Telegram chat data |
| `~/.var/app/com.jetbrains.IntelliJ-IDEA-Community` | 636M | IntelliJ config (settings, plugins list) |
| `~/.local/share/claude` | 429M | Claude AI data (conversations) |
| `~/.local/share/opencode` | 35M | Opencode data |
| `~/.config/opencode` | 59M | Opencode config |
| `~/.claude` | 6.7M | Claude config |
| `~/.local/share/nvim` | 224M | Neovim data (sessions, undo history) - may be redundant with nixvim |

### Config references
| Path | Size | Notes |
|------|------|-------|
| `~/.config/cosmic` | 792K | COSMIC settings (reference for future COSMIC module) |
| `~/.config/Nextcloud` | 352K | Nextcloud client config |
| `~/.config/input-remapper-2` | 24K | Key remapping config (reference, dropping service) |
| `~/Backups` | 507M | Existing backup dir (discord-flatpak-config) |

### Existing backups
| Path | Size | Notes |
|------|------|-------|
| `~/Backups` | 507M | Existing backup dir (discord-flatpak-config) |

---

## k3s agent details (needed for NixOS re-join)

Before wiping, extract these from the current k3s setup:
- Cluster server URL: check `/etc/systemd/system/k3s-agent.service` or `~/.kube/config`
- Join token: check `/etc/rancher/k3s/k3s.yaml` or the `install-k3s.sh` script in home dir
- Node name: `hostname` (currently `pop-os`)

Store these in sops secrets for the NixOS k3s module.

---

## Backup procedure

### Step 1: External drive
- Get an external drive with at least 50G free space
- Format as ext4 or exFAT (ext4 preferred for permissions)

### Step 2: Quick check - is code pushed to git?
```bash
cd ~/codebase
for d in */; do
  echo "=== $d ==="
  git -C "$d" status 2>/dev/null || echo "NOT A GIT REPO"
  git -C "$d" remote -v 2>/dev/null
  git -C "$d" log --oneline -1 2>/dev/null
done
```
Skip backing up any project that is pushed to a remote and clean.

### Step 3: Backup commands

```bash
# Set backup destination
BACKUP=/mnt/external/backup-$(date +%Y%m%d)
mkdir -p "$BACKUP"

# === MUST backup ===
# Photos (largest, do first)
rsync -avh --progress ~/Pictures/ "$BACKUP/Pictures/"

# YouTube downloads (if wanted)
rsync -avh --progress ~/charana/ydl/ "$BACKUP/charana/ydl/"

# Documents and work
rsync -avh ~/charana/Books ~/charana/Docs ~/charana/juspay ~/charana/SSH "$BACKUP/charana/"
rsync -avh ~/Documents/ "$BACKUP/Documents/"
rsync -avh ~/Downloads/Lecture*.pdf ~/Downloads/wallpaperflare*.jpg "$BACKUP/Downloads/"
# Movie (uncomment if keeping)
# rsync -avh ~/Downloads/Booksmart*.mkv "$BACKUP/Downloads/"

# Code (only projects not pushed to git - check first)
rsync -avh ~/codebase/ "$BACKUP/codebase/"

# Secrets (CRITICAL)
mkdir -p "$BACKUP/secrets"
cp ~/.config/secrets/aws-token ~/.config/secrets/env ~/.config/secrets/test-dummy "$BACKUP/secrets/"
cp -r ~/.gnupg "$BACKUP/gnupg"
cp ~/.ssh/id_ed25519.pub ~/.ssh/known_hosts ~/.ssh/authorized_keys ~/.ssh/config.backup "$BACKUP/ssh/"

# Fonts
rsync -avh ~/Fonts/ "$BACKUP/Fonts/"

# === RECOMMEND backup ===
# Browser profiles
rsync -avh ~/.config/mozilla/ "$BACKUP/config/mozilla/"
rsync -avh ~/.var/app/com.brave.Browser/ "$BACKUP/brave/"
rsync -avh ~/.config/zen/ "$BACKUP/config/zen/"

# App data
cp -r ~/.local/share/Steam/userdata "$BACKUP/steam-userdata"
rsync -avh ~/.var/app/org.telegram.desktop/ "$BACKUP/telegram/"
rsync -avh ~/.var/app/com.jetbrains.IntelliJ-IDEA-Community/ "$BACKUP/intellij/"
rsync -avh ~/.local/share/claude/ "$BACKUP/claude-data/"
rsync -avh ~/.local/share/opencode/ "$BACKUP/opencode-data/"
rsync -avh ~/.config/opencode/ "$BACKUP/opencode-config/"
cp -r ~/.claude "$BACKUP/claude-config"
rsync -avh ~/.local/share/nvim/ "$BACKUP/nvim-data/"

# Config references
cp -r ~/.config/cosmic "$BACKUP/config/cosmic"
cp -r ~/.config/Nextcloud "$BACKUP/config/Nextcloud"
cp -r ~/.config/input-remapper-2 "$BACKUP/config/input-remapper-2"
rsync -avh ~/Backups/ "$BACKUP/Backups/"

# === k3s agent details ===
cat /etc/systemd/system/k3s-agent.service 2>/dev/null > "$BACKUP/k3s-agent.service"
cat /etc/rancher/k3s/k3s.yaml 2>/dev/null > "$BACKUP/k3s.yaml"
cat ~/install-k3s.sh 2>/dev/null > "$BACKUP/install-k3s.sh"
hostname > "$BACKUP/hostname"
```

### Step 4: Verify backup
```bash
# Check sizes match
du -sh "$BACKUP"
ls -la "$BACKUP"

# Spot check critical files
cat "$BACKUP/secrets/aws-token"
ls "$BACKUP/Pictures/" | head
ls "$BACKUP/codebase/" | head
```

### Step 5: Extract k3s details for sops
```bash
# Get k3s server URL and token for NixOS module
grep -i "server" ~/install-k3s.sh
grep -i "token" ~/install-k3s.sh
# Or from the service file
grep -i "server" /etc/systemd/system/k3s-agent.service
grep -i "token" /etc/systemd/system/k3s-agent.service
```
These go into `secrets/keys.yaml` for the NixOS k3s module.

---

## Backup size estimate

| Category | Size |
|----------|------|
| Pictures | 19G |
| YouTube downloads (if kept) | 8G |
| Code (if not all on git) | 6.6G |
| Browser profiles | 2.7G |
| App data (Claude, IntelliJ, Telegram, nvim, opencode) | 1.4G |
| Fonts | 274M |
| Documents + lectures | 80M |
| Secrets + keys | small |
| k3s config | small |
| Backups dir | 507M |
| **Total** | **~38G** |

Without YouTube downloads: ~30G. Without code (if on git): ~23G.

---

## Post-restore on NixOS

After installing NixOS and restoring from backup:

1. **Pictures**: `rsync -avh /mnt/external/backup-*/Pictures/ ~/Pictures/`
2. **Code**: re-clone from git, or `rsync` local-only projects
3. **Secrets**: move AWS token and env to sops (`secrets/keys.yaml`), do NOT restore plaintext files
4. **GPG**: `gpg --import "$BACKUP/gnupg/pubring.kbx"` (import public keys; private keys if any)
5. **SSH**: known_hosts regenerates; authorized_keys comes from config.nix; private key comes from sops
6. **Browser**: Brave/Firefox/Zen - log in to sync, or restore profile dirs
7. **Steam**: re-install Steam via nix, games re-download, cloud saves restore from `userdata/`
8. **Telegram**: log in (chat data tied to phone number, restore may not work from flatpak data)
9. **Fonts**: most come from nixpkgs/stylix now, add any missing ones to home config
10. **k3s**: configure with server URL + token from sops secrets

---

## What to verify before wiping the disk

- [ ] External drive mounted and writable
- [ ] `~/Pictures/` backed up (19G)
- [ ] `~/charana/` backed up (8.5G, or at least Books/Docs/juspay/SSH = 508M)
- [ ] `~/Documents/` backed up (7M)
- [ ] `~/codebase/` checked against git remotes, local-only projects backed up
- [ ] `~/.config/secrets/` backed up (aws-token, env)
- [ ] `~/.gnupg/` backed up
- [ ] `~/.ssh/id_ed25519.pub` backed up (private key is in sops)
- [ ] Lecture PDFs backed up
- [ ] k3s server URL + token extracted
- [ ] Browser profiles backed up (or confirmed cloud-synced)
- [ ] Steam userdata (cloud saves) backed up (228K)
- [ ] Spot-check: open a few files from the backup to confirm they work
