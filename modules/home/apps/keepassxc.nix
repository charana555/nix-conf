{
  lib,
  config,
  ...
}:

{
  options.apps.keepassxc.enable = lib.mkEnableOption "KeePassXC";

  config = lib.mkIf config.apps.keepassxc.enable {
    programs.keepassxc = {
      enable = true;
      autostart = true;
    };
  };
}
