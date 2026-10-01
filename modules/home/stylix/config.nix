{ pkgs, lib, ... }:
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
    # papirus-icon-theme has no darwin build in nixpkgs
    icons = lib.mkIf pkgs.stdenv.isLinux {
      enable = true;
      # stylix has no default icon theme - name + package are required
      dark = "Papirus-Dark";
      light = "Papirus-Light";
      package = pkgs.papirus-icon-theme;
    };
    fonts.monospace = {
      inherit (selectedFont) name package;
    };
    fonts.sizes.terminal = 14;
  };
}
