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
