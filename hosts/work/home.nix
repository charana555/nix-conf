{ config, pkgs, ... }:

{
  home.username = "charana.c";
  home.homeDirectory = "/home/charana.c";

  imports = [
    ../../home/common.nix
  ];
}
