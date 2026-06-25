{  pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    wget
    sd
    tree
    less

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

    nerd-fonts.jetbrains-mono
    (writeShellScriptBin "opencode" ''
      exec ${nodejs_22}/bin/npx opencode-ai "$@"
    '')
  ];

  programs.btop = {
    enable = true;
  };

  programs.jq = {
    enable = true;
  };
}
