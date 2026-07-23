{
  flake,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    flake.inputs.stylix.homeModules.stylix
    ./config.nix
    ./cli-only.nix
  ];

  # starship palette is derived manually in starship.nix
  config.stylix.targets.starship.enable = lib.mkForce false;

  # btop theme derivation requires x86_64-linux builder
  config.stylix.targets.btop.enable = !pkgs.stdenv.hostPlatform.isDarwin;

  # stylix hyprland target checks this attribute which doesn't exist
  # in current home-manager. Define it so the target doesn't error.
  options.wayland.windowManager.hyprland.configType = lib.mkOption {
    type = lib.types.str;
    default = "hyprlang";
    readOnly = true;
    visible = false;
  };
}
