{
  config,
  lib,
  pkgs,
  ...
}:
let
  palette = import ../launcher/palette.nix;

  # Waybar custom-module helper for tailscale. `tailscale up/down` need
  # root unless this user was made operator once:
  #   sudo tailscale set --operator=$USER
  # (or passwordless sudo for exactly those two subcommands). Deliberately
  # not solved here.
  tailscale-waybar = pkgs.writeShellApplication {
    name = "tailscale-waybar";
    runtimeInputs = with pkgs; [
      tailscale
      jq
    ];
    text = ''
      status=$(tailscale status --json 2>/dev/null) || status=""
      state=$(jq -r '.BackendState // empty' <<<"$status")

      case "$1" in
        toggle)
          if [ "$state" = "Running" ]; then
            tailscale down
          else
            tailscale up
          fi
          ;;
        status)
          if [ "$state" = "Running" ]; then
            jq '{
              text: "󰇧",
              class: "connected",
              tooltip: ("tailscale: Running\n" +
                        (.TailscaleIPs[0] // "no ip") + "\n" +
                        ([(.Peer // {})[] | select(.Online)] | length | tostring) + "/" +
                        ((.Peer // {}) | length | tostring) + " peers online" +
                        (if .ExitNodeStatus then "\nexit node: " + .ExitNodeStatus.IP else "" end))
            }' <<<"$status"
          else
            if [ -z "$state" ]; then state="no daemon"; fi
            jq -n --arg state "$state" '{text: "󰇧", class: "disconnected", tooltip: ("tailscale: " + $state)}'
          fi
          ;;
      esac
    '';
  };
in
{
  options.waybar.battery.enable = lib.mkEnableOption "battery module (hosts with a battery)";

  config = {
    home.packages = [
      tailscale-waybar
      # nm-connection-editor, opened by the network module's right-click
      pkgs.networkmanagerapplet
    ];

    # Stylix auto-themes waybar (base16 colors, font, workspace underlines),
    # so only layout, weight and chip shape live here.
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
          "custom/tailscale"
        ]
        ++ lib.optionals config.waybar.battery.enable [ "battery" ]
        ++ [ "tray" ];

        clock = {
          # Click toggles to the bare date, tooltip carries the long one
          format = "{:%H:%M  %a %d %b}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "{:%A, %d %B %Y}";
        };

        network = {
          format-wifi = "{icon} {signalStrength}%";
          format-icons = [
            "󰤯"
            "󰤟"
            "󰤢"
            "󰤥"
            "󰤨"
          ];
          format-ethernet = "󰈀 wired";
          format-linked = "󰈁 {ifname} (no IP)";
          format-disconnected = "󰤭 offline";
          tooltip-format-wifi = "{essid}\n{signalStrength}% signal\n{ipaddr}/{cidr}";
          tooltip-format-ethernet = "{ifname}\n{ipaddr}/{cidr}";
          tooltip-format-disconnected = "Disconnected";
          interval = 5;
          # Same pickers as $mod+w / $mod+b
          on-click = "${lib.getExe pkgs.networkmanager_dmenu}";
          on-click-right = "${lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor"}";
        };

        bluetooth = {
          format = "󰂯";
          format-off = "󰂲";
          format-disabled = "󰂲";
          format-connected = "󰂱 {num_connected}";
          format-connected-battery = "󰂱 {device_battery_percentage}%";
          tooltip-format = "{controller_alias}\t{controller_address}";
          tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\t{device_battery_percentage}%";
          on-click = "${lib.getExe pkgs.rofi-bluetooth}";
          on-click-right = "${pkgs.bluez}/bin/bluetoothctl power toggle";
        };

        "custom/tailscale" = {
          exec = "${lib.getExe tailscale-waybar} status";
          on-click = "${lib.getExe tailscale-waybar} toggle";
          interval = 5;
          return-type = "json";
          format = "{}";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-plugged = "󰂄 {capacity}%";
          format-alt = "{icon} {time}";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
          tooltip-format = "{capacity}% · {time} remaining";
          interval = 30;
        };

        tray = {
          icon-size = 14;
          spacing = 8;
        };
      };

      style = ''
        * {
          font-weight: 600;
        }

        window#waybar {
          border-radius: 10px;
        }

        #workspaces button {
          padding: 0 5px;
        }

        /* module chips - same card language as rofi (launcher/palette.nix) */
        #network,
        #bluetooth,
        #custom-tailscale,
        #battery,
        #tray {
          background-color: ${palette.bg-input};
          border-radius: 8px;
          padding: 0 8px;
          margin: 4px 2px;
        }

        #custom-tailscale.connected {
          color: ${palette.accent};
        }
        #custom-tailscale.disconnected {
          color: ${palette.fg-dim};
        }

        #battery.warning {
          color: ${palette.warn};
        }
        #battery.critical {
          color: ${palette.critical};
        }
      '';
    };
  };
}
