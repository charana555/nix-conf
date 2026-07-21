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
  home.homeDirectory = "/Users/${cfg.users.work.username}";

  imports = [
    flake.homeModules.default
  ];

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
    docker
    docker-compose
    colima
    tailscale
    gitleaks
    haskell-language-server
    pinentry_mac
  ];

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };
}
