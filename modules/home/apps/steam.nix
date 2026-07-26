{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf config.apps.steam.enable {
    home.packages = [
      pkgs.steam
    ];
  };
}
