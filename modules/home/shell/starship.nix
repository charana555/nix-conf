{
  lib,
  config,
  ...
}:

{
  programs.starship = {
    enable = true;
    # Config is in starship.toml — keeps TOML as-is, no Nix attrset conversion
    settings = { };
  };

  xdg.configFile."starship.toml".source = ./starship.toml;
}
