{ config, pkgs, ... }:

{
  home.username = "itachi";
  home.homeDirectory = "/home/itachi";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
  # Core
  git
  curl
  wget

  # CLI tooling
  ripgrep
  fd
  fzf
  bat
  eza
  lazygit
  tmux
  zoxide

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
  nixfmt-rfc-style

  # Formatters
  stylua
  prettier

  # LSP utilities
  tree-sitter
   ];
  programs.git = {
    enable = true;
    
    settings = {
	user = {
	    name = "Charana555";
	    email = "charanchandrashekar555@gmail.com";
	};
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  programs.fzf.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  
  xdg.configFile."nvim".source = ../nvim;
  xdg.configFile."tmux/tmux.conf".source = ../tmux/tmux.conf;
}
