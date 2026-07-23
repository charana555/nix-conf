{ ... }:

{
  home.file."kitty-tab-bar" = {
    source = ./tab_bar.py;
    target = ".config/kitty/tab_bar.py";
  };

  programs.kitty = {
    enable = true;

    environment.FZF_PREVIEW_IMAGE_HANDLER = "kitty";

    extraConfig = # conf
      ''
        map shift+enter send_text all \x1b[13;2u
      '';

    settings = {
      shell_integration = "enabled no-cursor";

      adjust_line_height = "120%";
      adjust_column_width = "100%";
      adjust_baseline = 0;

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
      hide_window_decorations = "titlebar-only";
      confirm_os_window_close = 0;
      resize_in_steps = "no";
      background_blur = 64;
      dynamic_background_opacity = "yes";
      macos_traditional_fullscreen = "yes";
      macos_option_as_alt = "yes";

      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "yes";

      tab_bar_style = "custom";
      tab_fade = "0 0 0 0";
      tab_bar_edge = "top";
      tab_bar_margin_width = 0;
      tab_bar_margin_height = 0;
      tab_bar_align = "center";
      tab_bar_min_tabs = 2;
      tab_title_template = "{title}";
      active_tab_title_template = "{title}";
      tab_activity_symbol = "none";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      tab_bar_background = "none";

      enabled_layouts = "tall, stack, splits, grid";

      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";

      shell = ".";
      editor = ".";
      close_on_child_death = "no";
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";
      clipboard_control = "write-primary write-clipboard no-append";
    };

    keybindings = {
      "cmd+space" = "no_op";

      "cmd+f" = "send_text all \\x01";
      "cmd+s" = "send_text all \\x01/";
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
    };
  };
}
