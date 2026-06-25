{  ... }:

let
  fontFeatureString = name: # conf
    ''
      font_features Monaspace${name}Var-Bold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-BoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-ExtraBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-ExtraBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-ExtraLightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-Italic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-Light +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-LightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-Medium +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-MediumItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideExtraBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideExtraBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideExtraLight +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideExtraLightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideLight +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideLightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideMedium +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideMediumItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideRegular +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideSemiBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-SemiWideSemiBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideExtraBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideExtraBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideExtraLight +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideExtraLightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideLight +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideLightItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideMedium +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideMediumItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideRegular +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideSemiBold +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
      font_features Monaspace${name}Var-WideSemiBoldItalic +dlig +ss01 +ss02 +ss03 +ss04 +ss05 +ss06 +ss07 +ss08
    '';
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
        # Enable ligatures in monaspace font
        # picked from: <https://github.com/kovidgoyal/kitty/issues/7251#issuecomment-2016430720>
        ${fontFeatureString "Radon"}
        ${fontFeatureString "Krypton"}
        ${fontFeatureString "Argon"}
        ${fontFeatureString "Neon"}
      '';

    settings = {
      shell_integration = "enabled no-cursor";

      font_family = "Monaspace Neon";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = "13.0";

      adjust_line_height = "110%";
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
      os_window_state = "maximized";
      background_opacity = "0.90";
      background_blur = 64;
      dynamic_background_opacity = "yes";
      macos_traditional_fullscreen = "yes";
      macos_option_as_alt = "yes";

      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      window_alert_on_bell = "yes";

      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      url_color = "#89b4fa";

      tab_bar_style = "custom";
      tab_separator = "";
      tab_fade = "0 0 0 0";
      tab_bar_edge = "top";
      tab_bar_margin_width = "0.0";
      tab_bar_margin_height = "0.0";
      tab_bar_align = "center";
      tab_bar_min_tabs = 2;
      tab_title_template = "{title}";
      active_tab_title_template = "{title}";
      tab_activity_symbol = "none";
      active_tab_font_style = "bold";
      inactive_tab_font_style = "normal";

      tab_bar_background = "none";
      active_tab_foreground = "#1e1e2e";
      active_tab_background = "#fab387";
      inactive_tab_foreground = "#6c7086";
      inactive_tab_background = "#181825";

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
      clipboard_control = "write-primary write-clipboard no-append";
    };

    font.name = "Monaspace Neon";
    font.size = 13;

    keybindings = {
      "cmd+space" = "no_op";

      "cmd+f" = "send_text all \\x01";
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
