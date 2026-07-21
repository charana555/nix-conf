{ inputs, self, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
  ];

  # Transitional: keep existing standalone home-manager configs working
  # until hosts are migrated to NixOS/Darwin system configs.
  # Phase 2 will move these into hosts/nixos/<host>/users/ and hosts/home/.
  flake = {
    homeConfigurations = {
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

    disko = import ./disko;
  };

  perSystem =
    { pkgs, config, ... }:
    {
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
