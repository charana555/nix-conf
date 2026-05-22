{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    keyMode = "vi";
    baseIndex = 1;
    mouse = true;
    escapeTime = 0;
    historyLimit = 1000000;
    secureSocket = false;
    terminal = "tmux-256color";

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      better-mouse-mode
      fzf-tmux-url
      tmux-which-key
      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-processes '"~vim->vim" "~nvim->nvim" "~ssh->ssh" "~lazygit->lazygit" "~htop->htop"'
          set -g @resurrect-strategy-nvim 'session'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      set -as terminal-overrides ",*:Tc"
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      set-environment -g COLORTERM "truecolor"

      set -g allow-passthrough on
      set -s set-clipboard on

      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#T"
      set-option -g automatic-rename on
      set -g detach-on-destroy off

      set -g status-interval 2
      set -g status-position bottom
      set -g status-justify left
      set -g status-style "bg=#181825 fg=#bac2de"
      set -g window-status-format "#[fg=#6c7086 bg=#181825] #I #[fg=#6c7086]#W "
      set -g window-status-current-format "#[fg=#1e1e2e bg=#b4befe bold] #I #[fg=#1e1e2e]#W #[fg=#b4befe bg=#181825]"
      set -g window-status-separator ""
      set -g status-left-length 40
      set -g status-left "#[fg=#1e1e2e bg=#f5c2e7 bold]  #S #[fg=#f5c2e7 bg=#181825]"
      set -g status-right-length 60
      set -g status-right "#[fg=#181825 bg=#89dceb] #{pane_current_command} #[fg=#89dceb bg=#181825]#[fg=#1e1e2e bg=#cba6f7] %H:%M  #[fg=#cba6f7 bg=#181825]"

      setw -g pane-border-style "fg=#313244"
      setw -g pane-active-border-style "fg=#b4befe"
      set -g pane-border-indicators both
      set -g pane-border-lines single

      set -g message-style "fg=#1e1e2e bg=#f5c2e7 bold"
      set -g message-command-style "fg=#1e1e2e bg=#89dceb"
      set -g copy-mode-match-style "fg=#1e1e2e bg=#f9e2af"
      set -g copy-mode-current-match-style "fg=#1e1e2e bg=#f38ba8"
      set -g mode-style "fg=#1e1e2e bg=#f5c2e7"
      set -g clock-mode-colour "#cba6f7"
      set -g clock-mode-style 24

      set -g focus-events on

      bind V copy-mode
      bind-key T display-popup -E -w 60% -h 60% "sesh connect \"$(sesh list | fzf --reverse --border-label ' sesh ' --prompt '🯋 ' --bind 'ctrl-s:reload(sesh list --sessions)' --preview 'sesh preview {}')\""

      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"

      bind -r < swap-window -t -1 \; select-window -t -1
      bind -r > swap-window -t +1 \; select-window -t +1

      bind -r j resize-pane -D
      bind -r k resize-pane -U
      bind -r l resize-pane -R
      bind -r h resize-pane -L
      bind -r m resize-pane -Z

      bind H swap-pane -D
      bind L swap-pane -U

      bind x kill-pane
      bind q kill-window
      bind Q kill-session

      bind-key r movew -r\; display-message "Renumbered Windows"

      bind-key C send-keys -R \; clear-history

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel

      bind C-e run-shell "tmux capture-pane -pS -32768 > /tmp/tmux-pane-$$.sh && tmux new-window -n:edit-pane 'nvim /tmp/tmux-pane-$$.sh'"
    '';
  };
}
