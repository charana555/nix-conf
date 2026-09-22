{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  me = (import (flake + "/config.nix")).users.personal;
in
{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" me.username ])
    flake.nixosModules.default
    flake.nixosModules.hardware
    flake.nixosModules.intel
    flake.nixosModules.nvidia
    flake.nixosModules.hyprland
    flake.nixosModules.stylix
    flake.nixosModules.services
    flake.inputs.sops-nix.nixosModules.sops
    flake.inputs.disko.nixosModules.disko
    ./disk.nix
    ./hardware.nix
  ];

  networking.hostName = "dell";

  # CachyOS LTS kernel with pinned overlay (binary cache availability)
  nixpkgs.overlays = [ flake.inputs.nix-cachyos-kernel.overlays.pinned ];
  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-lts;

  # Binary cache for cachyos kernel (extra- appends to cache.nixos.org, doesn't replace it)
  nix.settings.extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
  nix.settings.extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  # Graphical login screen: pixie (Pixel/MD3). autoColor extracts a Material
  # You accent from the background, matching the caelestia dynamic scheme.
  # X11 greeter: the wayland (weston) greeter coredumps when SDDM respawns it
  # after a Hyprland session ends, leaving a dead VT with a blinking cursor.
  # Only the login screen uses X11; the user session stays on Wayland.
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = false;
    theme = "pixie";
    package = pkgs.kdePackages.sddm;
    # Qt6 QML bits the greeter env needs to render the theme
    extraPackages = with pkgs.kdePackages; [
      qt5compat
      qtdeclarative
      qtsvg
    ];
  };

  # Theme must land in SDDM's ThemeDir (/run/current-system/sw/share/sddm/themes);
  # sddm.extraPackages only adds Qt bits to the greeter env, not theme files.
  # Tweaks (input locked at 1e1a863, so the splice anchors are stable):
  # - background: assets/background.jpg is replaced with the same wallpaper
  #   stylix uses (modules/home/stylix/config.nix), so pixie's autoColor
  #   extracts a matching Material You accent. Replacing the asset instead of
  #   the theme.conf path keeps the wallpaper a real derivation input (GC-safe).
  # - password field: swapped for a caelestia-lock-style one (no box, animated
  #   dots) - see pixie/ShapeField.qml.
  environment.systemPackages = [
    (flake.inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.overrideAttrs
      (old: {
        postPatch = old.postPatch + ''
          cp ${./pixie/ShapeField.qml} components/ShapeField.qml
          cp ${./pixie/avatar.jpg} assets/avatar.jpg
          cp ${../../../wallpapers/your_name_wall.jpg} assets/background.jpg
          awk -v repl=${./pixie/password-field.qml} '
            /^ *TextField \{$/ {
              while ((getline line < repl) > 0) print line
              skipping = 1
              next
            }
            skipping == 1 {
              if (/onAccepted: container\.doLogin\(\)/)
                skipping = 2
              next
            }
            skipping == 2 {
              skipping = 0
              next
            }
            { print }
          ' Main.qml > Main.qml.tmp && mv Main.qml.tmp Main.qml
        '';
      })
    )
  ];

  networking.networkmanager.enable = true;
  # wifi/bluetooth picking happens in the caelestia bar popouts instead
  hyprland.networkPickers.enable = false;

  users = {
    defaultUserShell = pkgs.zsh;
    users.${me.username} = {
      home = "/home/${me.username}";
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "networkmanager"
        "docker"
      ];
      openssh.authorizedKeys.keys = me.sshPublicKeys;
    };
  };
  programs.zsh.enable = true;
  security.sudo.wheelNeedsPassword = false;

  sops = {
    defaultSopsFile = "${flake}/secrets/keys.yaml";
    age.keyFile = "${config.users.users.${me.username}.home}/.config/sops/age/keys.txt";
  };
  hm.sops.secrets."private-keys/ssh" = {
    path = "${config.users.users.${me.username}.home}/.ssh/id_ed25519";
    mode = "0600";
  };

  # Per-user home-manager config (hm = home-manager.users.<username>)
  # caelestia is the full shell on dell: its left bar, launcher, lock,
  # notifications, OSD, screenshots, wallpaper picker and network/bluetooth
  # popouts replace waybar, rofi, mako, avizo, hyprlock and the awww stack
  # (binds switch in modules/home/hyprland/keymaps.nix).
  # ~/.face is the avatar caelestia's dashboard shows (same image as the
  # login screen).
  hm.home.file.".face".source = ./pixie/avatar.jpg;
  hm.apps.caelestia.enable = true;
  hm.waybar.enable = false;
  hm.mako.enable = false;
  hm.avizo.enable = false;
  hm.hyprlock.enable = false;
  hm.wallpaper.enable = false;
  hm.apps.bitwarden.enable = true;
  hm.apps.nextcloud.enable = true;
  hm.apps.discord.enable = true;
  hm.apps.whatsapp.enable = true;
  hm.apps.steam.enable = true;
  hm.apps.skLauncher.enable = true;
  hm.apps.localsend.enable = true;
  hm.apps.ytmdesktop.enable = true;

  # LocalSend receives on 53317 (blocked by default firewall otherwise)
  networking.firewall.allowedTCPPorts = [ 53317 ];
  networking.firewall.allowedUDPPorts = [ 53317 ];
  hm.programs.git.settings.user = {
    name = me.fullname;
    email = me.email;
  };

  nix.settings.trusted-users = [ me.username ];

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
