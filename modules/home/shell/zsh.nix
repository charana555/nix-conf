{ pkgs, lib, ... }:

let
  copyScript = pkgs.writeText "copy-script" ''
    #!/usr/bin/env bash
    text=$(cat)
    if [ -n "''${TMUX:-}" ]; then
      encoded=$(printf '%s' "$text" | ${pkgs.coreutils}/bin/base64 | tr -d '\n')
      printf '\ePtmux;\e\033]52;c;%s\a\e\\' "$encoded"
    else
      encoded=$(printf '%s' "$text" | ${pkgs.coreutils}/bin/base64 | tr -d '\n')
      printf '\033]52;c;%s\007' "$encoded"
    fi
  '';

  copy = pkgs.runCommand "copy" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
    mkdir -p $out/bin
    cp ${copyScript} $out/bin/copy
    chmod +x $out/bin/copy
    patchShebangs $out/bin/copy
  '';

in
{
  home.packages = [ copy ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      append = true;
      expireDuplicatesFirst = true;
    };

    shellAliases = {
      oc = "npx opencode-ai";
      to = "tmux a -t";
      to-dsd = "ssh -o MACs=hmac-sha2-512-etm@openssh.com charana.c@100.77.128.13  -i ~/.ssh/id_ed25519_server";
      to-cvps = "ssh -i ~/.ssh/id_ed25519 ubuntu@80.225.224.42";
      to-pvps = "ssh -i ~/.ssh/id_ed25519 ubuntu@140.245.225.52";
      to-server = "ssh -o MACs=hmac-sha2-512-etm@openssh.com charana.c@100.112.214.101 -i ~/.ssh/id_ed25519_server";
      to-lightx = "ssh -i ~/.ssh/id_ed25519_server itachi@pop-os.local";
      to-oracle = "ssh -i ~/.ssh/ssh-key-2026-02-24.key ubuntu@80.225.224.42";
    };

    sessionVariables = {
      ZVM_SYSTEM_CLIPBOARD_ENABLED = "true";
      ZVM_CLIPBOARD_COPY_CMD = "${copy}/bin/copy";
      PSQL_PAGER = "cat";
    };

    localVariables = {
      ZVM_VI_INSERT_ESCAPE_BINDKEY = "jk";
    };

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkOrder 500 ''
        if [ -e /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
          . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        fi
        if [ -f ~/.config/secrets/env ]; then
          source ~/.config/secrets/env
        fi
      '')
      (lib.mkOrder 1000 ''
        to() {
          local session="$1"
          if [ -z "$session" ]; then
            echo "Usage: to <session-name>"
            return 1
          fi
          if [ -n "$TMUX" ]; then
            if tmux has-session -t "$session" 2>/dev/null; then
              tmux switch-client -t "$session"
            else
              tmux new-session -d -s "$session"
              tmux switch-client -t "$session"
            fi
          else
            tmux new-session -A -s "$session"
          fi
        }
        export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
      '')
      (lib.mkOrder 1500 ''
        _osc52_copy() {
          local text="$1"
          local encoded=$(printf '%s' "$text" | base64 | tr -d '\n')
          if [[ -n "$TMUX" ]]; then
            printf '\ePtmux;\e\033]52;c;%s\a\e\\' "$encoded"
          else
            printf '\033]52;c;%s\007' "$encoded"
          fi
        }

        _yank_line_with_osc52() {
          zle vi-yank-whole-line
          _osc52_copy "$CUTBUFFER"
        }

        _normal_yank_with_osc52() {
          zle vi-yank
          _osc52_copy "$CUTBUFFER"
        }

        _visual_yank_with_osc52() {
          zle copy-region-as-kill
          _osc52_copy "$CUTBUFFER"
          REGION_ACTIVE=0
          if (( $+functions[zvm_exit_visual_mode] )); then
            zvm_exit_visual_mode
          fi
          if (( $+ZVM_REGION_HIGHLIGHT )); then
            ZVM_REGION_HIGHLIGHT=()
          fi
          region_highlight=()
          zle -U ' '
          zle backward-delete-char
          zle -R
        }

        zle -N _yank_line_with_osc52
        zle -N _normal_yank_with_osc52
        zle -N _visual_yank_with_osc52

        bindkey -M vicmd 'yy' _yank_line_with_osc52
        bindkey -M vicmd 'y' _normal_yank_with_osc52
        bindkey -M visual 'y' _visual_yank_with_osc52

        function zvm_after_lazy_keybindings() {
          bindkey -M visual 'y' _visual_yank_with_osc52
        }
      '')
    ];
  };
}
