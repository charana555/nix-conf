{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.apps.localsend.enable = lib.mkEnableOption "LocalSend";

  config = lib.mkIf config.apps.localsend.enable {
    home.packages = [ pkgs.localsend ];
  };
}
