{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.whatsapp.enable = lib.mkEnableOption "WhatsApp";
  config = lib.mkIf config.apps.whatsapp.enable {
    # whatsapp-for-mac is the official client repackaged; zapzap is the
    # maintained Linux wrapper (no official Linux client exists)
    home.packages = [
      (if pkgs.stdenv.hostPlatform.isDarwin then pkgs.whatsapp-for-mac else pkgs.zapzap)
    ];
  };
}
