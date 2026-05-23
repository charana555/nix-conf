{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    curl
    wget

    ripgrep
    fd
    sesh
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

    stylua
    prettier

    tree-sitter

    nerd-fonts.jetbrains-mono
    (writeShellScriptBin "opencode" ''
      exec ${nodejs_22}/bin/npx opencode-ai "$@"
    '')
  ];
}
