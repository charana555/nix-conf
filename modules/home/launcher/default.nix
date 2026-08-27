{
  pkgs,
  lib,
  ...
}:
let
  # Power menu script using rofi dmenu mode
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    options="Shutdown\nReboot\nSuspend\nLogout"
    choice=$(echo -e "$options" | ${lib.getExe pkgs.rofi-wayland} -dmenu -p "Power" -theme-str 'window {width: 15em;} listview {lines: 4;}')
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
    # Stylix auto-themes rofi, just set minimal layout
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
    };
  };
}
