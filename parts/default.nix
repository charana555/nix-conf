{ inputs, self, ... }:
let
  # Transitional: keep existing standalone home-manager configs working
  # until hosts are migrated to NixOS/Darwin system configs.
  # Phase 2 will move these into hosts/nixos/<host>/users/ and hosts/home/.
  homeConfigs = {
    "itachi@popos" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      extraSpecialArgs = {
        inherit inputs;
        flake = self;
      };
      modules = [
        "${self}/hosts/popos/home.nix"
        { home.stateVersion = "25.05"; }
      ];
    };
    "charana.c@work" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { system = "x86_64-linux"; };
      extraSpecialArgs = {
        inherit inputs;
        flake = self;
      };
      modules = [
        "${self}/hosts/work/home.nix"
        { home.stateVersion = "25.05"; }
      ];
    };
    "charana.c@darwin" = inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs { system = "aarch64-darwin"; };
      extraSpecialArgs = {
        inherit inputs;
        flake = self;
      };
      modules = [
        "${self}/hosts/darwin-home.nix"
        { home.stateVersion = "25.05"; }
      ];
    };
  };
in
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  flake = {
    homeConfigurations = homeConfigs;
    disko = import ./disko;
  };

  perSystem =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      # Bare `.#homeConfigurations` nix queries resolve through
      # legacyPackages.<system>.homeConfigurations (nix-wire populates it from
      # hosts/home/, empty here), which shadows flake.homeConfigurations and
      # breaks `nh home switch . -c <name>`. Mirror the configs to fix that.
      # mkForce wins over nix-wire's empty mkHomeConfigs definition
      # (legacyPackages is a raw, non-merging option).
      legacyPackages.homeConfigurations = lib.mkForce homeConfigs;

      treefmt = {
        projectRootFile = "flake.nix";
        programs.nixfmt.enable = true;
      };

      devShells.default = pkgs.mkShell {
        name = "nix-conf";
        packages = with pkgs; [
          just
          nh
        ];
      };
    };
}
