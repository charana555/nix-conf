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
    programs.caelestia = {
      enable = true;
      cli.enable = true;
      # macOS-style notification banners (see caelestia/Notification.qml)
      # and the top-left hot corner, applied over the pinned upstream rev.
      # Bump note: the substituteInPlace anchors must match
      # modules/drawers/Interactions.qml at the locked caelestia rev.
      package = inputs.caelestia.packages.${pkgs.system}.with-cli.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          cp ${./caelestia/Notification.qml} modules/notifications/Notification.qml
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
        # frosted-glass panels behind Hyprland blur (drawers layer);
        # what makes the banners read as macOS glass
        appearance.transparency.enabled = true;
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
