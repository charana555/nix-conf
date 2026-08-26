{
  lib,
  config,
  ...
}:

let
  c = config.lib.stylix.colors;
in
{
  programs.starship = {
    enable = true;

    settings = {
      format = lib.concatStrings [
        "$os"
        "$username"
        "$directory"
        "$git_branch$git_status"
        "$nodejs$python$golang$rust$nix_shell"
        "$time"
        "$fill"
        "$line_break"
        "$character"
      ];

      right_format = "";

      add_newline = true;

      # All colors derived from stylix base16 (catppuccin-mocha)
      palettes.stylix = {
        base = "#${c.base00}";
        mantle = "#${c.base01}";
        surface0 = "#${c.base02}";
        surface1 = "#${c.base03}";
        surface2 = "#${c.base04}";
        text = "#${c.base05}";
        subtext1 = "#${c.base06}";
        subtext0 = "#${c.base07}";
        red = "#${c.base08}";
        peach = "#${c.base09}";
        yellow = "#${c.base0A}";
        green = "#${c.base0B}";
        teal = "#${c.base0C}";
        blue = "#${c.base0D}";
        lavender = "#${c.base0E}";
        pink = "#${c.base0F}";
      };

      palette = lib.mkForce "stylix";

      os = {
        disabled = false;
        style = "bg:base fg:blue bold";
        format = "[](base)[$symbol]($style)";
        symbols = {
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = "󰣇 ";
          CentOS = " ";
          Debian = " ";
          Fedora = " ";
          Gentoo = " ";
          Linux = " ";
          Macos = " ";
          Manjaro = " ";
          Mint = "󰣭 ";
          NixOS = " ";
          Pop = " ";
          Ubuntu = " ";
          Windows = "󰍲 ";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:base fg:lavender bold";
        style_root = "bg:red fg:base bold";
        format = "[ $user ]($style)";
      };

      directory = {
        truncate_to_repo = true;
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
        home_symbol = "~";
        read_only = " 󰌾";
        style = "bg:base fg:blue bold";
        read_only_style = "bg:base fg:red";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
      };

      fill.symbol = " ";

      git_branch = {
        symbol = "";
        style = "bg:base fg:teal bold";
        format = "[$symbol $branch]($style)";
      };

      git_status = {
        style = "bg:base fg:teal";
        format = "[$all_status$ahead_behind ]($style)";
        conflicted = "✗";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?";
        stashed = "$";
        modified = "!";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      nodejs = {
        symbol = " ";
        style = "bg:base fg:green bold";
        format = "[ $symbol($version )]($style)";
        detect_files = [
          "package.json"
          ".node-version"
        ];
        detect_folders = [ "node_modules" ];
      };

      python = {
        symbol = " ";
        style = "bg:base fg:yellow bold";
        python_binary = "python3";
        format = "[ $symbol($version )( $virtualenv )]($style)";
        detect_files = [
          "requirements.txt"
          "pyproject.toml"
          "setup.py"
          "Pipfile"
        ];
        detect_folders = [
          ".venv"
          "venv"
          "__pycache__"
        ];
      };

      rust = {
        symbol = " ";
        style = "bg:base fg:peach bold";
        format = "[ $symbol($version )]($style)";
        detect_files = [
          "Cargo.toml"
          "Cargo.lock"
        ];
        detect_folders = [ "target" ];
      };

      golang = {
        symbol = " ";
        style = "bg:base fg:sky bold";
        format = "[ $symbol ($version )]($style)";
        detect_files = [
          "go.mod"
          "go.sum"
        ];
        detect_folders = [ "vendor" ];
      };

      nix_shell = {
        symbol = " ";
        style = "bg:base fg:lavender bold";
        format = "[ $symbol$state( $name)]($style)";
      };

      cmd_duration = {
        min_time = 0;
        format = "[ $duration ](bg:base fg:lavender)[](base)";
        show_milliseconds = false;
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "bg:surface1 fg:text";
        format = "(base)[  $time ](bg:base fg:lavender)[](base)";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold lavender)";
      };

      aws.disabled = true;
      docker_context.disabled = true;
      package.disabled = true;
      java.disabled = true;
      kubernetes.disabled = true;
      terraform.disabled = true;
      helm.disabled = true;
      dotnet.disabled = true;
      php.disabled = true;
      lua.disabled = true;
      perl.disabled = true;
      ruby.disabled = true;
    };
  };
}
