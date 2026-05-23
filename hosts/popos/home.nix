let
  cfg = import ../../config.nix;
  me = cfg.me // cfg.personal;
in
{ config, pkgs, ... }:

{
  home.username = me.username;
  home.homeDirectory = "/home/${me.username}";

  imports = [
    ../../home/common.nix
  ];

  programs.git = {
    settings.user = {
      name = me.fullname;
      email = me.email;
    };
  };
}
