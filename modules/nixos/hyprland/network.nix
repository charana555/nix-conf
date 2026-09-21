{
  lib,
  pkgs,
  config,
  ...
}:
{
  # rofi-backed wifi (Super+W) and bluetooth (Super+B) pickers.
  # Disable on hosts where the shell (caelestia) provides the picking UI
  # through its bar popouts and nexus settings pages.
  options.hyprland.networkPickers.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "rofi-based network and bluetooth pickers";
  };

  config = lib.mkIf config.hyprland.networkPickers.enable {
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
  };
}
