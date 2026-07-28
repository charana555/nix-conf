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
    package = pkgs.buildEnv {
      name = "kitty-nixgl";
      paths = [
        (pkgs.writeShellScriptBin "kitty" ''
          exec ${nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.kitty}/bin/kitty "$@"
        '')
        (pkgs.writeShellScriptBin "kitten" ''
          exec ${nixgl.nixGLIntel}/bin/nixGLIntel ${pkgs.kitty}/bin/kitten "$@"
        '')
      ];
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

  apps.discord.enable = true;
  apps.skLauncher.enable = true;
  apps.steam.enable = true;
  apps.keepassxc.enable = true;
  apps.nextcloud.enable = true;
}
