{
  config,
  lib,
  ...
}:
let
  inherit (config.lib.stylix) colors;
  border_active = "0xff${colors.base06}";
  border_inactive = "0x00${colors.base06}";
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      binds = {
        allow_workspace_cycles = true;
        focus_preferred_method = 1;
        workspace_center_on = 1;
      };

      ecosystem.no_update_news = true;

      dwindle = {
        preserve_split = true;
        use_active_for_splits = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
        float_switch_override_focus = 1;
        mouse_refocus = true;
        repeat_rate = 50;
        repeat_delay = 300;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          clickfinger_behavior = true;
        };
        sensitivity = 0.6;
      };

      group = {
        group_on_movetoworkspace = true;
        "col.border_active" = lib.mkForce border_active;
        "col.border_inactive" = lib.mkForce border_inactive;
        groupbar = {
          gradients = false;
          render_titles = false;
          height = 5;
          "col.active" = lib.mkForce border_active;
          "col.inactive" = lib.mkForce border_inactive;
          text_color = lib.mkForce "0xff${colors.base0F}";
        };
      };

      general = {
        gaps_in = 2;
        gaps_out = 4;
        border_size = 2;
        layout = "dwindle";
        resize_on_border = true;
        "col.active_border" = lib.mkForce border_active;
        "col.inactive_border" = lib.mkForce border_inactive;
      };

      decoration = {
        rounding = 10;
        active_opacity = 1;
        inactive_opacity = 0.95;
        blur = {
          enabled = true;
          size = 6;
          passes = 3;
          new_optimizations = true;
          ignore_opacity = true;
          xray = false;
          popups = true;
        };
        shadow = {
          enabled = false;
          range = 10;
          render_power = 1;
          scale = 6;
          offset = "2 6";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "wind, 0.05, 0.9, 0.1, 1.05"
          "winIn, 0.1, 1.1, 0.1, 1.1"
          "winOut, 0.3, -0.3, 0, 1"
          "linear, 1, 1, 1, 1"
        ];
        animation = [
          "windows, 1, 6, wind, slide"
          "windowsIn, 1, 6, winIn, popin"
          "windowsOut, 1, 5, winOut, slide"
          "windowsMove, 1, 5, wind, slide"
          "fade, 1, 10, default"
          "workspaces, 1, 5, wind"
        ];
      };

      gestures = {
        workspace_swipe_forever = false;
      };

      gesture = [
        "3,horizontal, workspace"
      ];

      misc = {
        disable_splash_rendering = true;
        disable_hyprland_logo = true;
        animate_manual_resizes = true;
        animate_mouse_windowdragging = true;
        disable_autoreload = true;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = true;
        focus_on_activate = true;
        allow_session_lock_restore = true;
        enable_swallow = true;
      };
    };
  };
}
