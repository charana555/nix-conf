{
  flake,
  config,
  pkgs,
  inputs,
  ...
}:
let
  me = (import (flake + "/config.nix")).users.personal;
  nixgl = inputs.nixgl.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.username = me.username;
  home.homeDirectory = "/home/${me.username}";

  imports = [
    flake.homeModules.default
    flake.homeModules.stylix
  ];

  stylix.cliOnly = true;

  programs.kitty = {
    package = pkgs.symlinkJoin {
      name = "kitty-nixgl";
      paths = [ pkgs.kitty ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/kitty --prefix PATH : ${nixgl.nixGLIntel}/bin
      '';
    };
    settings.linux_display_server = "x11";
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
