{
  flake,
  config,
  pkgs,
  ...
}:
let
  me = (import (flake + "/config.nix")).users.personal;
in
{
  home.username = me.username;
  home.homeDirectory = "/home/${me.username}";

  imports = [
    flake.homeModules.default
  ];

  sops.secrets."private-keys/ssh" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  programs.git = {
    settings.user = {
      name = me.fullname;
      email = me.email;
    };
  };
}
