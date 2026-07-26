{
  description = "LightX's nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Auto-wiring
    nix-wire.url = "github:semi710/nix-wire";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";

    # Home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # Secrets
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Theming
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # Disk management
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    # Kernel
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";

    # Wayland compositor
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-index database (`,` command)
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # Editor
    nixvim.url = "github:nix-community/nixvim";
    nixvim.inputs.nixpkgs.follows = "nixpkgs";

    nvix.url = "github:niksingh710/nvix";
    nvix.inputs.nixpkgs.follows = "nixpkgs";

    # opencode ecosystem
    ponytail.url = "github:DietrichGebert/ponytail";
    ponytail.flake = false;

    # OpenGL wrapper for Nix binaries on non-NixOS Linux
    nixgl.url = "github:nix-community/nixGL";

    # Custom packages (sklauncher, etc.)
    ndots.url = "github:semi710/ndots";

    openagents-control = {
      url = "git+https://github.com/darrenhinde/OpenAgentsControl?rev=ef3836efd659e451b6dbb8eee7d3213ba39f5aec";
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

  outputs =
    inputs:
    inputs.nix-wire.mkFlake {
      inherit inputs;
      imports = [ ./parts ];
    };
}
