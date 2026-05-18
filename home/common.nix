{ config, pkgs, ... }:

{
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
  starship
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

  programs.git = {
    enable = true;
    
    settings = {
	user = {
	    name = "Charana555";
	    email = "charanchandrashekar555@gmail.com";
	};
    };
  };

  programs.starship = {
  enable = true;
};

  programs.kitty = {
  enable = true;
};

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      oc = "npx opencode-ai";
    };

     initExtraFirst = ''
    # Source Nix daemon for non-login shells (tmux, etc.)
    if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
      . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    if [ -f ~/.config/secrets/env ]; then
    source ~/.config/secrets/env
  fi
  '';

   initExtra = ''
    to() {
      if [ -n "$TMUX" ]; then
        tmux switch-client -t "$1"
      else
        tmux attach -t "$1"
      fi
    }
     # ... your existing initExtra ...
  export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
  '';
  };

  programs.fzf.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
  };
  
  xdg.configFile."nvim".source = ../nvim;
  xdg.configFile."tmux/tmux.conf".source = ../tmux/tmux.conf;
  xdg.configFile."kitty/kitty.conf".source = ../kitty/kitty.conf;
  xdg.configFile."starship.toml".source = ../starship/starship.toml;
  xdg.configFile."opencode/opencode.json".source = ../opencode/opencode.json;
  xdg.configFile."opencode/skills".source = ../opencode/skills;
}
