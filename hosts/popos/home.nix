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
    flake.homeModules.stylix
  ];

  home.file = {
    ".config/gtk-3.0/gtk.css".force = true;
    ".config/gtk-4.0/gtk.css".force = true;
  };

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
