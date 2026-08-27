{
  inputs,
  pkgs,
  ...
}:
{
  imports = inputs.nix-wire.lib.autoImport ./.;

  programs.zsh.profileExtra = # sh
    ''
      if [[ -z "$SSH_CONNECTION" ]] && [[ -n "$XDG_VTNR" ]] && uwsm check may-start && [[ -z "$TMUX" ]]; then
          exec uwsm start hyprland-uwsm.desktop
      fi
    '';

  home = {
    packages = with pkgs; [
      grim
      slurp
      wl-clipboard
      brightnessctl
      libnotify
    ];
    shellAliases = {
      copy = "wl-copy";
      paste = "wl-paste";
    };
  };

  # Cursor theme (matches catppuccin-macchiato stylix scheme)
  home.pointerCursor = {
    name = "catppuccin-macchiato-dark-cursors";
    package = pkgs.catppuccin-cursors.macchiatoDark;
    size = 24;
    gtk.enable = true;
  };
}
