{
  inputs,
  lib,
  config,
  ...
}:

{
  imports = [ inputs.caelestia.homeManagerModules.default ];

  # Trial: the shell is not autostarted (systemd unit off) and
  # waybar/rofi/mako/avizo stay enabled. Preview with `caelestia shell -d`.
  options.apps.caelestia.enable = lib.mkEnableOption "Caelestia desktop shell";

  config = lib.mkIf config.apps.caelestia.enable {
    programs.caelestia = {
      enable = true;
      cli.enable = true;
      systemd.enable = false;
      settings = {
        # awww + stylix own the wallpaper; without this the shell stacks
        # its own background layer (bundled fallback) over it on startup
        background.wallpaperEnabled = false;
        # left-edge vertical taskbar is structural (BarConfig has no
        # position option) - exclude it on all screens, waybar stays top
        bar.excludedScreens = [ ".*" ];
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
