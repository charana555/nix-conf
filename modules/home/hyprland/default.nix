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
      fuzzel
    ];
    shellAliases = {
      copy = "wl-copy";
      paste = "wl-paste";
    };
  };
}
