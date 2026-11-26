{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    # nushell is not used here, and the pinned fzf (0.72) is below the
    # 0.73 the nushell integration requires
    enableNushellIntegration = false;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
  };
}
