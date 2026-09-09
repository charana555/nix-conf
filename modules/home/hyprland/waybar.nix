{
  lib,
  pkgs,
  ...
}:
{
  # Stylix auto-themes waybar (base16 colors, font, workspace underlines),
  # so only layout and shape live here.
  programs.waybar = {
    enable = true;

    # Started by the uwsm graphical session, no exec-once needed
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 32;
      # Float the bar off the screen edge, matches gaps_out = 4
      margin-top = 4;
      margin-left = 8;
      margin-right = 8;

      modules-left = [ "hyprland/workspaces" ];
      modules-center = [ "clock" ];
      modules-right = [
        "network"
        "bluetooth"
        "tray"
      ];

      clock = {
        format = "{:%H:%M}";
        # Click toggles to date, tooltip carries the full one
        format-alt = "{:%a %d %b}";
        tooltip-format = "{:%A, %d %B %Y}";
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "󰈀 wired";
        format-disconnected = "󰤭 offline";
        tooltip-format = "{ifname} · {ipaddr}";
        # Same pickers as $mod+w / $mod+b
        on-click = "${lib.getExe pkgs.networkmanager_dmenu}";
      };

      bluetooth = {
        format = "󰂯";
        format-off = "󰂲";
        format-connected = "󰂱 {num_connected}";
        on-click = "${lib.getExe pkgs.rofi-bluetooth}";
      };

      tray = {
        icon-size = 14;
        spacing = 8;
      };
    };

    style = ''
      window#waybar {
        border-radius: 10px;
      }
      #workspaces button {
        padding: 0 5px;
      }
      #tray {
        padding: 0 5px;
      }
    '';
  };
}
