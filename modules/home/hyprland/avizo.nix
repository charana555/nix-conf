# Volume/brightness OSD popups; stylix auto-themes the colors.
# Caller side (osd script + keybinds) lives in keymaps.nix.
# Disable on hosts where the shell (caelestia) provides its own OSD.
{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.avizo.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "avizo volume/brightness OSD";
  };

  config = lib.mkIf config.avizo.enable {
    services.avizo.enable = true;

    wayland.windowManager.hyprland.settings.exec-once = [
      (lib.getExe' pkgs.avizo "avizo-service")
    ];
  };
}
