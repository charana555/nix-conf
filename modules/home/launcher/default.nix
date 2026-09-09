{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Power menu script using rofi dmenu mode
  power-menu = pkgs.writeShellScriptBin "power-menu" ''
    # \0icon\x1f<name> is rofi dmenu's per-entry icon markup; names
    # resolve through the configured icon-theme. printf interprets the
    # escapes at output time - bash variables cannot hold NUL bytes.
    choice=$(printf 'Shutdown\0icon\x1fsystem-shutdown\nReboot\0icon\x1fsystem-reboot\nSuspend\0icon\x1fsystem-suspend\nLogout\0icon\x1fsystem-log-out\n' | ${lib.getExe pkgs.rofi} -dmenu -p "Power" -theme-str 'window {width: 15em;} listview {lines: 4;}')
    # glob prefixes so icon markup can never leak into the match
    case "$choice" in
      Shutdown*) systemctl poweroff ;;
      Reboot*) systemctl reboot ;;
      Suspend*) systemctl suspend ;;
      Logout*) hyprctl dispatch exit ;;
    esac
  '';
in
{
  imports = [ ./theme.nix ];

  # Linux-only (rofi, systemctl, hyprctl); darwin/home configs leave this off.
  # theme.nix is imported unconditionally; its settings are inert where
  # programs.rofi is disabled.
  options.apps.launcher.enable = lib.mkEnableOption "rofi launcher with power menu";

  config = lib.mkIf config.apps.launcher.enable {
    home.packages = [ power-menu ];

    programs.rofi = {
      enable = true;
      package = pkgs.rofi;
      extraConfig = {
        modi = "drun,window,run";
        show-icons = true;
        # Papirus SVGs render with an opaque white box in rofi's
        # gdk-pixbuf loader. breeze-dark renders clean; app logos fall
        # back to hicolor PNG drops. GTK apps keep Papirus - this is
        # rofi-only.
        icon-theme = "breeze-dark";
        drun-display-format = "{name}";
        window-format = "{w} · {c} · {t}";
        sidebar-mode = false;
        matching = "fuzzy";
        scroll-method = 0;
      };
    };
  };
}
