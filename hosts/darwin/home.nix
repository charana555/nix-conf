let
  cfg = import ../../config.nix;
in
{ config, pkgs, ... }:

{
  home.username = cfg.work.username;
  home.homeDirectory = "/Users/${cfg.work.username}";

  imports = [
    ../../home/common.nix
  ];

  sops.secrets."private-keys/ssh" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  programs.git = {
    settings.user = {
      name = cfg.work.fullname;
      email = cfg.work.email;
    };

    includes = [
      {
        condition = "gitdir:~/personal/";
        contents = {
          user = {
            name = cfg.me.fullname;
            email = cfg.me.email;
          };
        };
      }
    ];
  };

  home.packages = with pkgs; [
    cargo
    rustc
    docker-compose
    colima
  ];
}

