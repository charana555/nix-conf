{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.apps.ytmdesktop.enable = lib.mkEnableOption "YouTube Music Desktop";

  config = lib.mkIf config.apps.ytmdesktop.enable {
    home.packages = [ pkgs.ytmdesktop ];
  };
}
