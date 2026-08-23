{ pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    wget
    sd
    tree
    less
    rclone

    ripgrep
    fd
    openssl.dev
    pkg-config

    gcc
    gnumake
    unzip

    nodejs_22
    python3
    lua-language-server

    nixd
    nil
    nixfmt
    cachix
    nix-info
    nixpkgs-fmt

    stylua
    prettier

    tree-sitter

    tmate
    kubectl

    nerd-fonts.jetbrains-mono
  ];

  programs.btop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };
}
