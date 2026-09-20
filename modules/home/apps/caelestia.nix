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
    };
  };
}
