{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.apps.keepassxc.enable = lib.mkEnableOption "KeePassXC";

  config = lib.mkIf config.apps.keepassxc.enable {
    programs.keepassxc = {
      enable = true;
      autostart = true;
    };

    # xdotool + xsel required for KeePassXC-Browser auto-fill on X11
    home.packages = with pkgs; [
      xdotool
      xsel
    ];
  };
}
