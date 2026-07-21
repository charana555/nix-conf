{
  flake,
  lib,
  pkgs,
  config,
  ...
}:
let
  me = (import (flake + "/config.nix")).users.me;
in
{
  imports = [
    (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" me.username ])
    flake.nixosModules.default
    flake.nixosModules.hardware
    flake.nixosModules.intel
    flake.nixosModules.hyprland
    flake.inputs.sops-nix.nixosModules.sops
    flake.inputs.disko.nixosModules.disko
    ./disk.nix
    ./hardware.nix
  ];

  # Use the hostname from the directory name
  networking.hostName = "vivo";

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  networking.networkmanager.enable = true;

  # Primary user
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

  # Auto-login on tty1 for convenience (Hyprland will replace this)
  services.getty.autologinUser = me.username;

  # Sops secrets
  sops = {
    defaultSopsFile = "${flake}/secrets/keys.yaml";
    age.keyFile = "${config.users.users.${me.username}.home}/.config/sops/age/keys.txt";
  };
  hm.sops.secrets."private-keys/ssh" = {
    path = "${config.users.users.${me.username}.home}/.ssh/id_ed25519";
    mode = "0600";
  };

  nix.settings.trusted-users = [ me.username ];

  time.timeZone = "Asia/Kolkata";
  i18n.defaultLocale = "en_US.UTF-8";

  # Zram for 8GB RAM system
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "25.05";
}
