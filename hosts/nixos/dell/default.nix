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

  # Use default NixOS kernel (6.6 LTS) instead of cachyos 6.18.26 which
  # fails initrd shrink (missing aes_x86_64 module) and hangs on boot
  boot.kernelPackages = pkgs.linuxPackages;

  # Debug: bypass GPU mode-setting hang during early boot
  boot.kernelParams = [ "systemd.debug-shell" "nomodeset" ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot";
  };

  networking.networkmanager.enable = true;

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
  hm.apps.keepassxc.enable = true;
  hm.apps.nextcloud.enable = true;
  hm.apps.discord.enable = true;
  hm.apps.steam.enable = true;
  hm.apps.skLauncher.enable = true;
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
