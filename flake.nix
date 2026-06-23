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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvix = {
      url = "github:niksingh710/nvix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ponytail = {
      url = "github:DietrichGebert/ponytail";
      flake = false;
    };

    # zen till https://github.com/NixOS/nixpkgs/issues/327982 is resolved
    # ponytail: git+https (not github:) to dodge unauthenticated GitHub API rate limits
    zen-browser.url = "git+https://github.com/0xc000022070/zen-browser-flake";

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs:
  let
    mkHomeConfig = username: hostname: system: modules:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
        };
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = modules ++ [
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

