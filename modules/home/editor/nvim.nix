{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.packages = [
    (inputs.nvix.packages.${pkgs.system}.default.extend {
      # nixpkgs pins copilot.lua's moving tag, which upstream re-released and
      # broke the recorded hash; pin an immutable commit instead.
      plugins.copilot-lua.package = lib.mkForce (
        pkgs.vimUtils.buildVimPlugin {
          pname = "copilot.lua";
          version = "2.0.2";
          src = pkgs.fetchFromGitHub {
            owner = "zbirenbaum";
            repo = "copilot.lua";
            rev = "86f52edd2191b5b8aaa1fdc372dc6fcb84423d3b"; # v2.0.2
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
