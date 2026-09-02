{
  pkgs,
  lib,
  ...
}:
let
  # Power menu script using rofi dmenu mode
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    options="Shutdown\nReboot\nSuspend\nLogout"
    choice=$(echo -e "$options" | ${lib.getExe pkgs.rofi} -dmenu -p "Power" -theme-str 'window {width: 15em;} listview {lines: 4;}')
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
    package = pkgs.rofi;
    extraConfig = {
      modi = "drun,window,run";
      show-icons = true;
      drun-display-format = "{name}";
      window-format = "{w} · {c} · {t}";
      sidebar-mode = false;
      matching = "fuzzy";
      scroll-method = 0;
    };
    # Custom layout (stylix handles colors/fonts, this handles spacing)
    theme = with pkgs.lib; {
      "*" = {
        border-colour = mkForce "#00000000";
      };
      "window" = {
        width = mkForce "40em";
        border = mkForce "0px";
        border-radius = mkForce "12px";
        padding = mkForce "12px";
        background-color = mkForce "#1e1e2eee";
      };
      "inputbar" = {
        padding = mkForce "8px 12px";
        border-radius = mkForce "8px";
        background-color = mkForce "#313244cc";
        children = mkForce [ "entry" ];
      };
      "entry" = {
        placeholder = "Search...";
        horizontal-align = mkForce "0.5";
        padding = mkForce "6px";
      };
      "listview" = {
        lines = mkForce "8";
        padding = mkForce "8px 0px";
        border-radius = mkForce "8px";
        background-color = mkForce "#00000000";
      };
      "element" = {
        padding = mkForce "8px 12px";
        border-radius = mkForce "8px";
        spacing = mkForce "10px";
      };
      "element.selected" = {
        background-color = mkForce "#cba6f733";
      };
      "element-icon" = {
        size = mkForce "1.5em";
      };
    };
  };
}
