{
  inputs,
  pkgs,
  lib,
  config,
  ...
}:
let
  contrib = inputs.hyprland-contrib.packages.${pkgs.stdenv.hostPlatform.system};
  wpctl = "${lib.getExe' pkgs.wireplumber "wpctl"}";
  brightnessctl = lib.getExe pkgs.brightnessctl;
  avizo-client = lib.getExe' pkgs.avizo "avizo-client";

  # Volume/brightness change + OSD popup, one command per keybind.
  # Keeps the wpctl backend (incl. the -l 1.5 boost cap) instead of
  # avizo's volumectl, which would switch to pamixer and cap at 100%.
  osd = pkgs.writeShellScriptBin "osd" ''
    VOL=${wpctl}
    BRI=${brightnessctl}
    AVI=${avizo-client}

    vol_show() {
      set -- $($VOL get-volume @DEFAULT_AUDIO_SINK@ | awk '{
        v = $2; if (v > 1) v = 1
        i = "volume_high"
        if ($0 ~ /MUTED/) i = "volume_muted"
        else if (v <= 0.33) i = "volume_low"
        else if (v <= 0.66) i = "volume_medium"
        printf "%s %.2f", i, v
      }')
      $AVI --image-resource=$1 --progress=$2
    }

    bright_show() {
      set -- $(awk -v c=$($BRI g) -v m=$($BRI m) 'BEGIN {
        p = c / m
        i = "brightness_high"
        if (p <= 0.33) i = "brightness_low"
        else if (p <= 0.66) i = "brightness_medium"
        printf "%s %.2f", i, p
      }')
      $AVI --image-resource=$1 --progress=$2
    }

    case "$1" in
      vol-up) $VOL set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+; vol_show ;;
      vol-down) $VOL set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-; vol_show ;;
      mute) $VOL set-mute @DEFAULT_AUDIO_SINK@ toggle; vol_show ;;
      mic-mute)
        $VOL set-mute @DEFAULT_AUDIO_SOURCE@ toggle
        if $VOL get-volume @DEFAULT_AUDIO_SOURCE@ | grep -q MUTED; then
          $AVI --image-resource=mic_muted
        else
          $AVI --image-resource=mic_unmuted
        fi
        ;;
      bright-up) $BRI set 5%+; bright_show ;;
      bright-down) $BRI set 5%-; bright_show ;;
    esac
  '';

  workspace = [
    "$mod,mouse_up,workspace,e+1"
    "$mod,mouse_down,workspace,e-1"
    "$mod,1,focusworkspaceoncurrentmonitor,1"
    "$mod,2,focusworkspaceoncurrentmonitor,2"
    "$mod,3,focusworkspaceoncurrentmonitor,3"
    "$mod,4,focusworkspaceoncurrentmonitor,4"
    "$mod,5,focusworkspaceoncurrentmonitor,5"
    "$mod,6,focusworkspaceoncurrentmonitor,6"
    "$mod,7,focusworkspaceoncurrentmonitor,7"
    "$mod,8,focusworkspaceoncurrentmonitor,8"
    "$mod,9,focusworkspaceoncurrentmonitor,9"
    "$mod,0,focusworkspaceoncurrentmonitor,10"
    "$modSHIFT,1,movetoworkspace,1"
    "$modSHIFT,2,movetoworkspace,2"
    "$modSHIFT,3,movetoworkspace,3"
    "$modSHIFT,4,movetoworkspace,4"
    "$modSHIFT,5,movetoworkspace,5"
    "$modSHIFT,6,movetoworkspace,6"
    "$modSHIFT,7,movetoworkspace,7"
    "$modSHIFT,8,movetoworkspace,8"
    "$modSHIFT,9,movetoworkspace,9"
    "$modSHIFT,0,movetoworkspace,10"
    "$mod,p,workspace,e-1"
    "$mod,n,workspace,e+1"
    "$modSHIFT,p,movetoworkspace,-1"
    "$modSHIFT,n,movetoworkspace,+1"
  ];
in
{
  home.packages = with contrib; [ grimblast ];

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      extraConfig.SS = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      "$notify" = "notify-send -a 'Hyprland'";
      "$sspath" = ''~/Pictures/Screenshots/"$(date +%d-%b-%H-%M-%S)".png'';

      bind = workspace ++ [
        "$mod,q,killactive"
        "$mod,h,movefocus,l"
        "$mod,l,movefocus,r"
        "$mod,k,movefocus,u"
        "$mod,j,movefocus,d"
        "$modSHIFT,h,movewindow,l"
        "$modSHIFT,l,movewindow,r"
        "$modSHIFT,j,movewindow,d"
        "$modSHIFT,k,movewindow,u"
        "$mod,return,exec,kitty"
        "$mod,space,exec,rofi -show drun"
        "$modSHIFT,space,exec,rofi -show window"
        "$modSHIFT,backspace,exec,power-menu"
        "$mod,f,togglefloating,"
        "$modCTRL,f,fullscreenstate,0 2"
        "$mod,m,fullscreen,0"
        "$modSHIFT,x,exec,hyprctl kill"
        "$mod,r,exec,hyprctl reload"
        ",Print,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave output $sspath"
        "$modSHIFT,Print,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave area $sspath"
        "$mod,Print,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave active $sspath"
        # no Print key on the Aula F75, mirror the binds on Super+s
        "$mod,s,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave output $sspath"
        "$modSHIFT,s,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave area $sspath"
        "$modCTRL,s,exec,${lib.getExe contrib.grimblast} --notify --cursor copysave active $sspath"
        ",F9,exec,loginctl lock-session"
        ",Scroll_Lock,exec,loginctl lock-session"
      ];
      bindm = [
        "$mod,mouse:272,movewindow"
        "$mod,mouse:273,resizewindow 2"
      ];
      binde = [
        "$modCTRL,h,resizeactive,-50 0"
        "$modCTRL,l,resizeactive,50 0"
        "$modCTRL,j,resizeactive,0 50"
        "$modCTRL,k,resizeactive,0 -50"
        ",XF86AudioRaiseVolume,exec,${lib.getExe osd} vol-up"
        ",XF86AudioLowerVolume,exec,${lib.getExe osd} vol-down"
        ",XF86MonBrightnessUp,exec,${lib.getExe osd} bright-up"
        ",XF86MonBrightnessDown,exec,${lib.getExe osd} bright-down"
        # Super + volume knob on the Aula F75 = brightness
        "$mod,XF86AudioRaiseVolume,exec,${lib.getExe osd} bright-up"
        "$mod,XF86AudioLowerVolume,exec,${lib.getExe osd} bright-down"
      ];
      bindl = [
        ",XF86AudioMute,exec,${lib.getExe osd} mute"
        ",XF86AudioMicMute,exec,${lib.getExe osd} mic-mute"
        ",switch:on:Lid Switch,exec,loginctl lock-session"
      ];
    };
  };
}
