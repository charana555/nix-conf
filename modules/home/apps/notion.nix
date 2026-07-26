{
  pkgs,
  lib,
  config,
  ...
}:

{
  options.apps.notion.enable = lib.mkOptionEnable "Notion";

  config = lib.mkIf config.apps.notion.enable {
    home.packages = [ pkgs.notion ];
  };

}
