{  lib, ... }:

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
        "$cmd_duration"
        "$fill"
        "$line_break"
        "$character"
      ];

      right_format = "";

      add_newline = true;

      palette = "catppuccin";

      palettes.catppuccin = {
        rosewater = "#f5e0dc";
        flamingo = "#f2cdcd";
        pink = "#f5c2e7";
        mauve = "#cba6f7";
        red = "#f38ba8";
        maroon = "#eba0ac";
        peach = "#fab387";
        yellow = "#f9e2af";
        green = "#a6e3a1";
        teal = "#94e2d5";
        sky = "#89dceb";
        sapphire = "#74c7ec";
        blue = "#89b4fa";
        lavender = "#b4befe";
        text = "#cdd6f4";
        subtext1 = "#bac2de";
        subtext0 = "#a6adc8";
        overlay2 = "#9399b2";
        overlay1 = "#7f849c";
        overlay0 = "#6c7086";
        surface2 = "#585b70";
        surface1 = "#45475a";
        surface0 = "#313244";
        base = "#1e1e2e";
        mantle = "#181825";
        crust = "#11111b";
      };

      os = {
        disabled = false;
        style = "bg:surface0 fg:blue bold";
        format = "[](surface0)[$symbol]($style)";
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
        style_user = "bg:surface0 fg:lavender bold";
        style_root = "bg:red fg:base bold";
        format = "[ $user ]($style)";
      };

      directory = {
        truncate_to_repo = true;
        truncation_length = 3;
        fish_style_pwd_dir_length = 1;
        home_symbol = "~";
        read_only = " 󰌾";
        style = "bg:surface0 fg:blue bold";
        read_only_style = "bg:surface0 fg:red";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
      };

      fill.symbol = " ";

      git_branch = {
        symbol = " ";
        style = "bg:surface0 fg:teal bold";
        format = "[ $symbol$branch ]($style)";
      };

      git_status = {
        style = "bg:surface0 fg:teal";
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
        style = "bg:surface0 fg:green bold";
        format = "[ $symbol($version )]($style)";
        detect_files = [ "package.json" ".node-version" ];
        detect_folders = [ "node_modules" ];
      };

      python = {
        symbol = " ";
        style = "bg:surface0 fg:yellow bold";
        python_binary = "python3";
        format = "[ $symbol($version )( $virtualenv )]($style)";
        detect_files = [ "requirements.txt" "pyproject.toml" "setup.py" "Pipfile" ];
        detect_folders = [ ".venv" "venv" "__pycache__" ];
      };

      rust = {
        symbol =  " ";
        style = "bg:surface0 fg:peach bold";
        format = "[ $symbol($version )]($style)";
        detect_files = [ "Cargo.toml" "Cargo.lock" ];
        detect_folders = [ "target" ];
      };

      golang = {
        symbol = " ";
        style = "bg:surface0 fg:sky bold";
        format = "[ $symbol ($version )]($style)";
        detect_files = [ "go.mod" "go.sum" ];
        detect_folders = [ "vendor" ];
      };

      nix_shell = {
        symbol = " ";
        style = "bg:surface0 fg:lavender bold";
        format = "[ $symbol$state( $name)]($style)";
      };

      cmd_duration = {
        min_time = 0;
        format = "[ $duration ](bg:surface0 fg:lavender)[](surface0)";
        show_milliseconds = false;
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "bg:surface1 fg:text";
        format = "[](surface1)[ $time ]($style)[](surface1)";
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
