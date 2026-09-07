{
  pkgs,
  inputs,
  ...
}:

let
  workmux = inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default;

  edit-pane =
    pkgs.writeShellScript "edit-pane" # sh
      ''
        buf=$(mktemp).sh
        # -32768 is the length of the buffer
        # Why -32768? Coz everyone using this
        tmux capture-pane -pS -32768 > "$buf"
        tmux new-window -n:edit-pane "$EDITOR $buf"
      '';

  workmux-sidebar =
    pkgs.writeShellScript "workmux-sidebar" # sh
      ''
        set +e
        sidebar=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep ' workmux$' | awk '{print $1}' | head -1)
        active=$(tmux display -p '#{pane_id}' 2>/dev/null)
        if [ -z "$sidebar" ]; then
          # Not open → open and focus
          workmux sidebar --session 2>/dev/null
          for i in 1 2 3 4 5 6 7 8 9 10; do
            sidebar=$(tmux list-panes -F '#{pane_id} #{pane_current_command}' 2>/dev/null | grep ' workmux$' | awk '{print $1}' | head -1)
            [ -n "$sidebar" ] && break
            sleep 0.1
          done
          [ -n "$sidebar" ] && tmux select-pane -t "$sidebar" 2>/dev/null
        elif [ "$sidebar" = "$active" ]; then
          # Focused → close
          tmux kill-pane -t "$sidebar" 2>/dev/null
        else
          # Open but not focused → focus
          tmux select-pane -t "$sidebar" 2>/dev/null
        fi
        exit 0
      '';

  workmux-dashboard =
    pkgs.writeShellScript "workmux-dashboard" # sh
      ''
        tab="''${1:-}"
        h=$(tmux display -p '#{window_height}')
        w=$(tmux display -p '#{window_width}')
        h=$((h * 9 / 10))
        w=$((w * 9 / 10))
        if [ -n "$tab" ]; then
          tmux display-popup -h "$h" -w "$w" -E "workmux dashboard --tab $tab"
        else
          tmux display-popup -h "$h" -w "$w" -E "workmux dashboard"
        fi
      '';
in
{
  home.packages = [ workmux ];

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
      {
        plugin = minimal-tmux-status;
        extraConfig = ''
          set -g @minimal-tmux-bg "#2d241d"
          set -g @minimal-tmux-fg "#e0a458"
          set -g @minimal-tmux-justify "left"
          set -g @minimal-tmux-use-arrow true
          set -g @minimal-tmux-right-arrow ""
          set -g @minimal-tmux-left-arrow ""
          set -g @minimal-tmux-indicator-str ""
        '';
      }
      {
        plugin = vim-tmux-navigator;
        extraConfig = ''
          # vim-tmux-navigator: Only treat actual vim instances as vim
          # Exclude lazygit and other TUIs by using a strict pattern
          # Matches: vim, nvim, view, fzf (but NOT lazygit)
          set -g @vim_navigator_pattern '(\S+/)?\.?(g?(view|n?vim?x?)(diff)?|fzf)(-wrapped)?$'
        '';
      }
      better-mouse-mode
      open
      fzf-tmux-url
      {
        plugin = tmux-which-key;
        extraConfig = ''
          set -g @tmux-which-key-xdg-enable true
          set -g @tmux-which-key-disable-autobuild true
        '';
      }
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
      set -g allow-passthrough all
      set -g default-command "''${SHELL}"
      bind-key -n S-Enter send-keys -l "\e[13;2u"

      set -g default-terminal "tmux-256color"
      set -as terminal-overrides ",*:Tc"

      # Undercurl
      set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'
      set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

      # Check if we are in WSL
      if-shell 'test -n "$WSL_DISTRO_NAME"' {
        set -as terminal-overrides ',*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
      }

      set-environment -g COLORTERM "truecolor"

      set-option -ga update-environment "UPTERM_ADMIN_SOCKET"
      set-option -ga update-environment "SSH_AUTH_SOCK"

      set -g set-clipboard on
      set-option -g automatic-rename on
      set -g prefix C-a

      set -g renumber-windows on
      set -g set-titles on
      set -g set-titles-string "#T"
      set -g detach-on-destroy off

      set -g focus-events on

      bind N new-session
      bind n new-window

      bind V copy-mode
      bind-key / copy-mode \; send-keys "/"
      bind-key T display-popup -E -w 60% -h 60% "sesh connect \"$(sesh list | fzf --reverse --border-label ' sesh ' --prompt '🯋 ' --bind 'ctrl-s:reload(sesh list --sessions)' --preview 'sesh preview {}')\""

      bind v split-window -h -c "#{pane_current_path}"
      bind s split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      bind -r < swap-window -t -1 \; select-window -t -1
      bind -r > swap-window -t +1 \; select-window -t +1

      bind -r j resize-pane -D
      bind -r k resize-pane -U
      bind -r l resize-pane -R
      bind -r h resize-pane -L
      bind -r m resize-pane -Z

      bind H swap-pane -D
      bind L swap-pane -U

      bind -r C-h previous-window
      bind -r C-l next-window

      bind x kill-pane
      bind q kill-window
      bind Q kill-session

      bind-key r movew -r\; display-message "Renumbered Windows"

      bind-key C send-keys -R \; clear-history

      bind C-e run-shell "${edit-pane}"

      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection-and-cancel
      bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe

      bind b set-option status

      bind S choose-session

      # workmux: toggle agent sidebar, focus on open (replaces send-prefix)
      bind C-a run-shell "${workmux-sidebar}"
      # workmux: dashboard popup (C-s is taken by resurrect save)
      bind C-d run-shell "${workmux-dashboard}"
      # workmux: dashboard on worktrees tab
      bind C-w run-shell "${workmux-dashboard} worktrees"
    '';
  };
}
