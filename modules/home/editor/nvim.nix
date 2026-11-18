{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.packages = [
    (inputs.nvix.packages.${pkgs.system}.default.extend {
      colorschemes.kanagawa.enable = lib.mkForce false;
      colorschemes.tokyonight.enable = lib.mkForce false;
      colorschemes.catppuccin = {
        enable = lib.mkForce true;
        settings = {
          flavour = "macchiato";
          transparent_background = true;
          custom_highlights = # lua
            ''
              function(colors)
                return {
                  NormalFloat = { bg = "none" },
                  FloatBorder = { bg = "none" },
                  FloatTitle = { bg = "none" },
                  SnacksNormal = { bg = "none" },
                  SnacksNormalNC = { bg = "none" },
                  SnacksBorder = { bg = "none" },
                  SnacksTitle = { bg = "none" },
                }
              end
            '';
          integrations = {
            cmp = true;
            gitsigns = true;
            nvimtree = true;
            treesitter = true;
            notify = false;
            mini = {
              enabled = true;
              indentscope_color = "";
            };
          };
        };
      };

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
