{
  pkgs,
  lib,
  ...
}:
{
  # Volume/brightness OSD popups; stylix auto-themes the colors.
  # Caller side (osd script + keybinds) lives in keymaps.nix.
  services.avizo.enable = true;

  wayland.windowManager.hyprland.settings.exec-once = [
    (lib.getExe' pkgs.avizo "avizo-service")
  ];
}
