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
    mkHomeConfig = username: hostname: system: modules:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = modules ++ [
          nixvim.homeModules.default
          { home.stateVersion = "25.05"; }
        ];
      };
  in {
    homeConfigurations = {
      "itachi@popos" = mkHomeConfig "itachi" "popos" "x86_64-linux" [ ./hosts/popos/home.nix ];
      "charana.c@work" = mkHomeConfig "charana.c" "work" "x86_64-linux" [ ./hosts/work/home.nix ];
      "charana.c@darwin" = mkHomeConfig "charana.c" "darwin" "aarch64-darwin" [ ./hosts/darwin/home.nix ];
    };
  };
}

