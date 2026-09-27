{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.nautilus.enable = lib.mkEnableOption "Nautilus";
  config = lib.mkIf config.apps.nautilus.enable {

    home.packages = [ pkgs.nautilus ];
  };

}
