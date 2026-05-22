{ config, pkgs, ... }:

{
  home.username = "charana.c";
  home.homeDirectory = "/home/charana.c";

  imports = [
    ../../home/common.nix
  ];

  programs.git = {
    includes = [
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = "charana.c";
            email = "charana.c@juspay.in";
          };
        };
      }
    ];
  };

  home.packages = with pkgs; [
    # Rust toolchain (previously imperative)
    cargo
    rustc
    
    # Containers
    docker-compose
    
    # Dev tools
    mkpasswd
    
    # Editors/utils
    vim
    xclip
  ];
}
