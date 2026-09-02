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

  workspace = [
    "$mod,mouse_up,workspace,e+1"
    "$mod,mouse_down,workspace,e-1"
    "$mod,1,workspace,1"
    "$mod,2,workspace,2"
    "$mod,3,workspace,3"
    "$mod,4,workspace,4"
    "$mod,5,workspace,5"
    "$mod,6,workspace,6"
    "$mod,7,workspace,7"
    "$mod,8,workspace,8"
    "$mod,9,workspace,9"
    "$mod,0,workspace,10"
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
        ",XF86AudioRaiseVolume,exec,${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume,exec,${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86MonBrightnessUp,exec,${brightnessctl} set 5%+"
        ",XF86MonBrightnessDown,exec,${brightnessctl} set 5%-"
      ];
      bindl = [
        ",XF86AudioMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute,exec,${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",switch:on:Lid Switch,exec,loginctl lock-session"
      ];
    };
  };
}
