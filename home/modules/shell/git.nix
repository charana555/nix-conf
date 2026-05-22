{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    lfs.enable = true;

    ignores = [
      "*~"
      "*.swp"
    ];

    iniContent = {
      branch.sort = "-committerdate";
    };

    settings = {
      user = {
        name = "Charana555";
        email = "charanchandrashekar555@gmail.com";
      };
      aliases.gl = "log --oneline --graph --decorate";
      init.defaultBranch = "main";
      core.editor = "nvim";
      pull.rebase = "true";
    };
  };

  programs.gh = {
    enable = true;
    extensions = [ pkgs.gh-notify ];
  };

  programs.lazygit = {
    enable = true;
    settings = {
      promptToReturnFromSubprocess = false;
      os.editPreset = "nvim-remote";
      gui = {
        nerdFontsVersion = "3";
        theme.lightTheme = false;
      };
      os.copyToClipboardCmd = ''
        if [[ "$TERM" =~ ^(screen|tmux) ]]; then printf "\033Ptmux;\033\033]52;c;$(printf "%s" {{text}} | base64 -w 0)\a\033\\" > /dev/tty; else printf "\033]52;c;$(printf "%s" {{text}} | base64 -w 0)\a" > /dev/tty; fi
      '';
    };
  };
}
