{ config, pkgs, ... }:

{
  home.username = "itachi";
  home.homeDirectory = "/home/itachi";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    neovim
    tmux
    ripgrep
    fd
    fzf
    lazygit
    wget
    curl
    htop
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
}
