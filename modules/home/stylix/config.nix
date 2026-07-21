{ pkgs, ... }:
let
  # Matches nvim kanagawa-wave theme
  scheme = "kanagawa";
in
{
  stylix = {
    enable = true;
    enableReleaseChecks = false;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/${scheme}.yaml";
    image = pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/pixelart/gruvbox_image55.png";
      sha256 = "sha256-lgZbAAWTimybsBD+2ZsS/jwKtyPbQ1QCgt/82RDIHug=";
    };
    opacity.terminal = 0.90;
    polarity = "dark";
    fonts.monospace = {
      name = "Monaspace Argon";
      package = pkgs.monaspace;
    };
    fonts.sizes.terminal = 14;

    # starship palette is derived manually in starship.nix
    targets.starship.enable = false;
  };
}
