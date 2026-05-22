{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
  # Core
  curl
  wget

  # CLI tooling
  ripgrep
  fd
  fzf
  bat
  eza
  zoxide
  sesh
  openssl.dev
  pkg-config
  # Neovim ecosystem
  neovim
  gcc
  gnumake
  unzip

  # Languages
  nodejs_22
  python3
  lua-language-server

  # Nix tooling
  nixd
  nil
  nixfmt

  #Shell
  kitty

  # Formatters
  stylua
  prettier

  # LSP utilities
  tree-sitter
    
    nerd-fonts.jetbrains-mono
    (writeShellScriptBin "opencode" ''
    exec ${nodejs_22}/bin/npx opencode-ai "$@"
  '')
   ];

  programs.kitty = {
  enable = true;
};

  programs.fzf.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  
  xdg.configFile."nvim".source = ../nvim;
  xdg.configFile."kitty/kitty.conf".source = ../kitty/kitty.conf;
  xdg.configFile."opencode/opencode.json".source = ../opencode/opencode.json;
  xdg.configFile."opencode/skills".source = ../opencode/skills;
}
