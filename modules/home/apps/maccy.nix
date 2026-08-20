{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.maccy.enable = lib.mkEnableOption "Maccy";
  config = lib.mkIf config.apps.maccy.enable {
    home.packages = [ pkgs.maccy ];
  };
}
