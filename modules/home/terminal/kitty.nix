{ lib, ... }:

let
  baseBindings = {
    "space" = "no_op";
    "f" = "send_text all \\x01";
    "s" = "send_text all \\x01/";
    "t" = "new_tab_with_cwd";
    "w" = "close_tab";
    "n" = "next_tab";
    "m" = "previous_tab";
    "." = "move_tab_forward";
    "," = "move_tab_backward";
    "enter" = "new_window_with_cwd";
    "d" = "close_window";
    "]" = "next_window";
    "[" = "previous_window";
    "r" = "start_resizing_window";
    "l" = "next_layout";
    "equal" = "change_font_size all +1.0";
    "minus" = "change_font_size all -1.0";
    "backspace" = "change_font_size all 0";
    "a" = "set_background_opacity -0.05";
    "b" = "set_background_opacity +0.05";
    "h" = "show_scrollback";
    "g" = "show_last_command_output";
    "c" = "copy_to_clipboard";
    "v" = "paste_from_clipboard";
  };

  shiftBindings = {
    "t" = "set_tab_title";
    "f" = "move_window_forward";
  };

  mkBindings =
    prefix:
    lib.mapAttrs' (k: v: {
      name = "${prefix}+${k}";
      value = v;
    }) baseBindings;

  mkShiftBindings =
    prefix:
    lib.mapAttrs' (k: v: {
      name = "${prefix}+shift+${k}";
      value = v;
    }) shiftBindings;
in
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

    keybindings =
      mkBindings "cmd" // mkBindings "alt" // mkShiftBindings "cmd" // mkShiftBindings "alt";
  };
}
