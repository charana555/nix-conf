{ pkgs, ... }:
let
  scheme = "catppuccin-macchiato";

  # Font switch - change one word, applies to every machine via stylix.
  # Add entries from pkgs.nerd-fonts.* as needed.
  fonts = {
    fira-code = {
      name = "FiraCode Nerd Font";
      package = pkgs.nerd-fonts.fira-code;
    };
    jetbrains-mono = {
      name = "JetBrainsMono Nerd Font";
      package = pkgs.nerd-fonts.jetbrains-mono;
    };
  };
  selectedFont = fonts.fira-code;
in
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    image = ../../../wallpapers/your_name_wall.jpg;
    opacity.terminal = 0.90;
    polarity = "dark";
    fonts.monospace = {
      inherit (selectedFont) name package;
    };
    fonts.sizes.terminal = 14;
  };
}
