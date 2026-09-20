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
        # left-edge vertical taskbar is structural (BarConfig has no
        # position option) - exclude it on all screens, waybar stays top
        bar.excludedScreens = [ ".*" ];
        # stock wallpapers are symlinked here by wallpaper.nix
        paths.wallpaperDir = "~/.local/share/wallpapers";
        # match the old wpctl/osd behavior: 5% steps, 150% volume cap
        services = {
          maxVolume = 1.5;
          audioIncrement = 0.05;
          brightnessIncrement = 0.05;
        };
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
