{
  description = "LightX's nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim }:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
    };

    mkHomeConfig = username: hostname: modules:
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = modules ++ [
          nixvim.homeModules.default
          { home.stateVersion = "25.05"; }
        ];
      };
  in {
    homeConfigurations = {
      "itachi@popos" = mkHomeConfig "itachi" "popos" [ ./hosts/popos/home.nix ];
      "charana.c@work" = mkHomeConfig "charana.c" "work" [ ./hosts/work/home.nix ];
    };
  };
}
