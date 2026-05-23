{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      shell_integration = "enabled no-cursor";

      font_family = "JetBrainsMono Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = "13.0";

      adjust_line_height = "110%";
      adjust_column_width = "100%";
      adjust_baseline = 0;

      symbol_map = "U+E0A0-U+E0D8,U+E700-U+E864 JetBrainsMono Nerd Font";

      cursor_shape = "block";
      cursor_beam_thickness = "7.5";
      cursor_blink_interval = "0.5";
      cursor_stop_blinking_after = "15.0";
      cursor_trail = 3;
      cursor_trail_decay = "0.1 0.4";
      cursor_trail_start_threshold = 2;

      scrollback_lines = 10000000;
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";
      wheel_scroll_multiplier = "5.0";
      touch_scroll_multiplier = "1.0";

      mouse_hide_wait = "3.0";
      url_style = "curly";
      open_url_with = "default";
      copy_on_select = "no";
      focus_follows_mouse = "no";

      window_padding_width = "0 0 0 0";
      window_margin_width = "0 0 0 0";
      placement_strategy = "center";
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;
      resize_in_steps = "no";
      os_window_state = "maximized";
      background_opacity = "0.90";
      background_blur = 64;
      dynamic_background_opacity = "yes";

      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "yes";

      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#89b4fa";

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_edge = "bottom";
      tab_bar_margin_width = "0.0";
      tab_bar_min_tabs = 2;
      tab_title_template = "\"{index}: {title}\"";
      active_tab_title_template = "none";

      tab_bar_background = "#181825";
      active_tab_foreground = "#1e1e2e";
      active_tab_background = "#cba6f7";
      inactive_tab_foreground = "#6c7086";
      inactive_tab_background = "#181825";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      enabled_layouts = "tall, stack, splits, grid";

      background = "#1e1e2e";
      foreground = "#cdd6f4";
      selection_background = "#f5e0dc";
      selection_foreground = "#1e1e2e";

      color0 = "#45475a";
      color8 = "#585b70";
      color1 = "#f38ba8";
      color9 = "#f38ba8";
      color2 = "#a6e3a1";
      color10 = "#a6e3a1";
      color3 = "#f9e2af";
      color11 = "#f9e2af";
      color4 = "#89b4fa";
      color12 = "#89b4fa";
      color5 = "#cba6f7";
      color13 = "#cba6f7";
      color6 = "#89dceb";
      color14 = "#89dceb";
      color7 = "#bac2de";
      color15 = "#a6adc8";

      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      shell = ".";
      editor = ".";
      close_on_child_death = "no";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
    };

    font.name = "JetBrainsMono Nerd Font";
    font.size = 13;

    keybindings = {
      "cmd+space" = "no_op";

      "cmd+t" = "new_tab_with_cwd";
      "cmd+w" = "close_tab";
      "cmd+n" = "next_tab";
      "cmd+m" = "previous_tab";
      "cmd+." = "move_tab_forward";
      "cmd+," = "move_tab_backward";
      "cmd+shift+t" = "set_tab_title";

      "cmd+enter" = "new_window_with_cwd";
      "cmd+d" = "close_window";
      "cmd+]" = "next_window";
      "cmd+[" = "previous_window";
      "cmd+shift+f" = "move_window_forward";
      "cmd+r" = "start_resizing_window";

      "cmd+l" = "next_layout";

      "cmd+equal" = "change_font_size all +1.0";
      "cmd+minus" = "change_font_size all -1.0";
      "cmd+backspace" = "change_font_size all 0";

      "cmd+a" = "set_background_opacity -0.05";
      "cmd+b" = "set_background_opacity +0.05";

      "cmd+h" = "show_scrollback";
      "cmd+g" = "show_last_command_output";

      "cmd+c" = "copy_to_clipboard";
      "cmd+v" = "paste_from_clipboard";
      "cmd+s" = "paste_from_selection";
    };
  };
}
