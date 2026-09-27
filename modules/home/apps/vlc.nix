{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.vlc.enable = lib.mkEnableOption "VLC";
  config = lib.mkIf config.apps.vlc.enable {

    home.packages = [ pkgs.vlc ];
  };

}
