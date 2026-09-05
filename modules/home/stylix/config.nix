{ pkgs, ... }:
let
  scheme = "catppuccin-macchiato";
in
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    image = ../../../wallpapers/gruvbox_image55.png;
    opacity.terminal = 0.90;
    polarity = "dark";
    fonts.monospace = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
    fonts.sizes.terminal = 14;
  };
}
