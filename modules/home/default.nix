{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  imports =
    inputs.nix-wire.lib.autoImportExcept ./. [
      "stylix"
      "hyprland"
    ]
    ++ [ inputs.sops-nix.homeManagerModules.sops ];

  home.stateVersion = "25.05";
  fonts.fontconfig.enable = true;

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/keys.yaml;
  };

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;
}
