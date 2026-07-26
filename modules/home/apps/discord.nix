{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.discord.enable = lib.mkEnableOption "Discord";
  config = lib.mkIf config.apps.discord.enable {

    home.packages = [
      (pkgs.discord.override {
        withVencord = true;
        withOpenASAR = true;
      })
    ];
  };

}
