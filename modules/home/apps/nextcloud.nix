{
  lib,
  pkgs,
  config,
  ...
}:

{
  options.apps.nextcloud.enable = lib.mkEnableOption "Nextcloud Client";

  # Installed only - launch manually; no systemd autostart at login
  config = lib.mkIf config.apps.nextcloud.enable {
    home.packages = [ pkgs.nextcloud-client ];
  };
}
