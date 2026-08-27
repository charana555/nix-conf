{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Power menu script using rofi dmenu mode
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    options="Shutdown\nReboot\nSuspend\nLogout"
    choice=$(echo -e "$options" | ${lib.getExe config.programs.rofi.finalPackage} -dmenu -p "Power" -theme-str 'window {width: 15em;} listview {lines: 4;}')
    case "$choice" in
      Shutdown) systemctl poweroff ;;
      Reboot) systemctl reboot ;;
      Suspend) systemctl suspend ;;
      Logout) hyprctl dispatch exit ;;
    esac
  '';
in
{
  home.packages = [ power-menu ];

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;
    plugins = [ pkgs.rofi-power-menu ];
    # Stylix auto-themes rofi, just set minimal layout
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      icon-theme = config.gtk.iconTheme.name;
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };
  };
}
