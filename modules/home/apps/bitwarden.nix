{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.bitwarden.enable = lib.mkEnableOption "Bitwarden";

  config = lib.mkIf config.apps.bitwarden.enable {
    home.packages = [ pkgs.bitwarden-desktop ];
  };
}
