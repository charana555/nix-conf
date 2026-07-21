{ flake, ... }:
{
  imports = [
    flake.inputs.stylix.homeModules.stylix
    ./config.nix
    ./cli-only.nix
  ];
}
