{ flake, ... }:
{
  home-manager.sharedModules = [
    flake.homeModules.hyprland
  ];
}
