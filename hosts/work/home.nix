let
  cfg = import ../../config.nix;
  me = cfg.me // cfg.work;
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

    includes = [
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = cfg.work.fullname;
            email = cfg.work.email;
          };
        };
      }
    ];
  };

  home.packages = with pkgs; [
    cargo
    rustc
    docker-compose
    mkpasswd
    xclip
  ];
}
