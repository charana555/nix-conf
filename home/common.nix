{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  xdg.configFile."opencode/opencode.json".source = ../opencode/opencode.json;
  xdg.configFile."opencode/skills".source = ../opencode/skills;
}
