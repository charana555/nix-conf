{
  lib,
  config,
  ...
}:

{
  options.apps.nextcloud.enable = lib.mkEnableOption "Nextcloud Client";

  config = lib.mkIf config.apps.nextcloud.enable {
    services.nextcloud-client = {
      enable = true;
      startInBackground = true;
    };
  };
}
