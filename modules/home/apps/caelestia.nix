{
  inputs,
  lib,
  config,
  ...
}:

{
  imports = [ inputs.caelestia.homeManagerModules.default ];

  options.apps.caelestia.enable = lib.mkEnableOption "Caelestia desktop shell";

  config = lib.mkIf config.apps.caelestia.enable {
    programs.caelestia = {
      enable = true;
      cli.enable = true;
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
