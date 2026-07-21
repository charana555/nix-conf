{
  flake,
  config,
  pkgs,
  ...
}:
let
  cfg = import (flake + "/config.nix");
in
{
  home.username = cfg.users.work.username;
  home.homeDirectory = "/home/${cfg.users.work.username}";

  imports = [
    flake.homeModules.default
    flake.homeModules.stylix
  ];

  stylix.cliOnly = true;

  sops.secrets."private-keys/ssh" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  programs.git = {
    settings.user = {
      name = cfg.users.work.fullname;
      email = cfg.users.work.email;
    };

    includes = [
      {
        condition = "gitdir:~/personal/";
        contents = {
          user = {
            name = cfg.users.me.fullname;
            email = cfg.users.me.email;
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
