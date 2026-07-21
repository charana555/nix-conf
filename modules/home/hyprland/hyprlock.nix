{ config, ... }:
# ponytail: hardcoded colors, stylix replaces these in Phase 6
let
  base00 = "24273a";
  base0F = "5b6078";
in
{
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        no_fade_in = true;
        no_fade_out = true;
        hide_cursor = false;
        grace = 0;
        disable_loading_bar = true;
      };
      background = [
        {
          path = "screenshot";
          blur_passes = 2;
          contrast = 0.9;
          brightness = 0.5;
          vibrancy = 0.17;
          vibrancy_darkness = 0;
        }
      ];
      input-field = [
        {
          size = "300, 40";
          outline_thickness = 2;
          dots_size = 0.2;
          dots_spacing = 0.2;
          dots_center = true;
          outer_color = "rgba (0, 0, 0, 0)";
          inner_color = "0x80${base0F}";
          font_color = "0xffc8c8c8";
          fade_on_empty = false;
          hide_input = false;
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
      ];
      label = [
        {
          text = ''cmd[update:1000] echo -e "$(date +"%H:%M")"'';
          color = "0xff${base0F}";
          font_size = "120";
          position = "0, 100";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:1000] echo "$(date '+%A, %d %B')"'';
          color = "0xff${base0F}";
          font_size = "24";
          position = "0, 30";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };
}
