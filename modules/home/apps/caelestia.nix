{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:

let
  # Top-left hot corner that reveals the notification sidebar (macOS-style
  # message center). Caelestia's sidebar.showOnHover only triggers on the
  # right screen edge; these patches add a 150px top-left corner square to
  # the trigger and keep the panel open along the top strip while the
  # pointer travels from the corner to the panel.
  hotspotOpen = "const showSidebarHover = x > Math.min(width - Config.border.minThickness, bar.implicitWidth + panels.sidebar.x) && y <= sidebarTriggerY;";
  hotspotOpenPatched = "const showSidebarHover = (x > Math.min(width - Config.border.minThickness, bar.implicitWidth + panels.sidebar.x) || x < 150 && y < 150) && y <= sidebarTriggerY;";
  hotspotHide = "if (!inSidebarArea)\n                        screenState.sidebar = false;";
  hotspotHidePatched = "if (!inSidebarArea && y > sidebarTriggerY)\n                        screenState.sidebar = false;";
in

{
  imports = [ inputs.caelestia.homeManagerModules.default ];

  options.apps.caelestia.enable = lib.mkEnableOption "Caelestia desktop shell";

  config = lib.mkIf config.apps.caelestia.enable {
    # Brightness.qml drives external displays via DDC/CI (`ddcutil detect`
    # maps connectors to i2c buses). Without ddcutil in PATH every monitor
    # falls back to brightnessctl, which only knows the internal panel -
    # focused-display brightness then silently changes the laptop screen.
    # Hosts enabling this module also need, on the NixOS side:
    #   hardware.i2c.enable + user in the i2c group (DDC brightness)
    #   services.upower.enable (battery status via Quickshell UPower)
    # See hosts/nixos/dell/default.nix.
    home.packages = [ pkgs.ddcutil ];

    programs.caelestia = {
      enable = true;
      cli.enable = true;
      # Top-left hot corner for the notification sidebar, applied over the
      # pinned upstream rev. Bump note: the substituteInPlace anchors must
      # match modules/drawers/Interactions.qml at the locked caelestia rev.
      package = inputs.caelestia.packages.${pkgs.system}.with-cli.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace modules/drawers/Interactions.qml \
            --replace-fail "${hotspotOpen}" "${hotspotOpenPatched}" \
            --replace-fail "${hotspotHide}" "${hotspotHidePatched}"
        '';
      });
      # systemd user unit on graphical-session.target; uwsm starts it on
      # login. Stop with `systemctl --user stop caelestia` - pkill restarts it.
      systemd.enable = true;
      settings = {
        # stock wallpapers are symlinked here by wallpaper.nix
        paths.wallpaperDir = "~/.local/share/wallpapers";
        # match the old wpctl/osd behavior: 5% steps, 150% volume cap
        services = {
          maxVolume = 1.5;
          audioIncrement = 0.05;
          brightnessIncrement = 0.05;
        };
        # speaker/volume icon in the bar's status icons (opens the audio
        # popout with output device picker). Upstream defaults it to false,
        # and shell.json replaces the whole list instead of merging, so
        # every entry must be listed. Keep in sync with BarConfig
        # statusIcons defaults at the locked caelestia rev.
        bar.statusIcons = [
          {
            id = "lockStatus";
            enabled = true;
          }
          {
            id = "audio";
            enabled = true;
          }
          {
            id = "microphone";
            enabled = false;
          }
          {
            id = "kbLayout";
            enabled = false;
          }
          {
            id = "network";
            enabled = true;
          }
          {
            id = "bluetooth";
            enabled = true;
          }
          {
            id = "battery";
            enabled = true;
          }
        ];
        # default logout is a loginctl Terminate alias: a hard SIGTERM of the
        # session that leaves the GPU/VT wedged, so SDDM's greeter never
        # respawns (dead VT, blinking cursor). uwsm stop exits Hyprland
        # cleanly and the greeter comes back.
        session.commands.logout = [
          "uwsm"
          "stop"
        ];
        # reveal the notification sidebar from the top-left hot corner
        # (also keeps stock right-edge hover reveal)
        sidebar.showOnHover = true;
        # no weather tab in the dashboard
        dashboard.showWeather = false;
      };
      cli.settings = {
        # stylix owns terminal/GTK/Qt theming; `caelestia scheme set`
        # live-rethemes all three by default (cli.json theme.* default true)
        theme = {
          enableTerm = false;
          enableGtk = false;
          enableQt = false;
        };
      };
    };
  };
}
