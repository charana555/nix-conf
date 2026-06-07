{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.stateVersion = "25.05";

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/keys.yaml;
  };

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.home-manager.enable = true;

  xdg.configFile."opencode/opencode.json".source = ../opencode/opencode.json;
  xdg.configFile."opencode/skills".source = ../opencode/skills;
}
