{ lib, pkgs, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        forwardAgent = true;
        addKeysToAgent = "yes";
      };
      dsd = {
        hostname = "100.77.128.13";
        user = "charana.c";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions.MACs = "hmac-sha2-512-etm@openssh.com";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
      "ssh.bitbucket.juspay.net" = {
        hostname = "ssh.bitbucket.juspay.net";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
    };
  };

  home.file.".ssh/config".force = true;
  services.ssh-agent = lib.mkIf pkgs.stdenv.isLinux { enable = true; };
}
