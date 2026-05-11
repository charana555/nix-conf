{ config, pkgs, ... }:

{
  home.username = "charana.c";
  home.homeDirectory = "/home/charana.c";

  imports = [
    ../../home/common.nix
  ];

  home.packages = with pkgs; [
    # Rust toolchain (previously imperative)
    cargo
    rustc
    
    # Containers
    docker-compose
    
    # Dev tools
    gh
    mkpasswd
    
    # Editors/utils
    vim
    xclip
    
    # TMUX (plugins managed manually via tpm)
    tmux
  ];
}
