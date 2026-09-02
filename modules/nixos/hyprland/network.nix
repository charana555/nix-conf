{
  lib,
  pkgs,
  ...
}:
{
  environment.systemPackages = [
    pkgs.networkmanager_dmenu
    pkgs.rofi-bluetooth
  ];

  # rofi backend for networkmanager-dmenu (defaults to dmenu otherwise)
  hm.xdg.configFile."networkmanager-dmenu/config.ini".text = ''
    [dmenu]
    dmenu_command = rofi -dmenu -i -l 10
    rofi_highlight = True
    compact = True
    wifi_chars = ▂▄▆█

    [dmenu_passphrase]
    obscure = True
  '';

  hm.wayland.windowManager.hyprland.settings.bind = [
    "$mod,w,exec,${lib.getExe pkgs.networkmanager_dmenu}"
    "$mod,b,exec,${lib.getExe pkgs.rofi-bluetooth}"
  ];
}
