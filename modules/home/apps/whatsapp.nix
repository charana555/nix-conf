{
  pkgs,
  lib,
  config,
  ...
}:

let
  # ponytail: pinned nixpkgs ships 2.26.10.18, which WhatsApp's CDN now
  # 500s; bump to the version current nixpkgs ships. Drop this override
  # when the nixpkgs flake input is updated past 2.26.31.27.
  whatsappVersion = "2.26.31.27";
  whatsapp-for-mac = pkgs.whatsapp-for-mac.overrideAttrs (_: {
    version = whatsappVersion;
    src = pkgs.fetchzip {
      extension = "zip";
      name = "WhatsApp.app";
      url = "https://web.whatsapp.com/desktop/mac_native/release/?version=${whatsappVersion}&extension=zip&configuration=Release&branch=master";
      hash = "sha256-bB4RVqk+v5QdsOvgTc4hA6EF/s1KIBnrL+HXwsm89/c=";
    };
  });
in
{
  options.apps.whatsapp.enable = lib.mkEnableOption "WhatsApp";
  config = lib.mkIf config.apps.whatsapp.enable {
    # whatsapp-for-mac is the official client repackaged; zapzap is the
    # maintained Linux wrapper (no official Linux client exists)
    home.packages = [
      (if pkgs.stdenv.hostPlatform.isDarwin then whatsapp-for-mac else pkgs.zapzap)
    ];
  };
}
