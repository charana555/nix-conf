{ config, pkgs, ... }:

{
  home.username = "itachi";
  home.homeDirectory = "/home/itachi";

  imports = [
    ../../home/common.nix
  ];
}
