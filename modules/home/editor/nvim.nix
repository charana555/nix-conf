{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.packages = [
    (inputs.nvix.packages.${pkgs.system}.default.extend {
      # Fix copilot.lua hash mismatch
      plugins.copilot-lua.package = lib.mkForce (
        pkgs.vimUtils.buildVimPlugin {
          pname = "copilot.lua";
          version = "2.0.2";
          src = pkgs.fetchFromGitHub {
            owner = "zbirenbaum";
            repo = "copilot.lua";
            rev = "v2.0.2";
            hash = "sha256-/cYfC56DjPKEZagNg/3DP/yDs0bgTHFDPYEVd0JvVys=";
          };
        }
      );
    })
  ];

  programs.neovim = {
    defaultEditor = true;
    vimAlias = true;
  };
}
