{
  lib,
  osConfig,
  ...
}:
{
  wayland.windowManager.hyprland.settings = {
    xwayland.force_zero_scaling = true;
    monitor = [
      # Pinned to the origin so hotplug order can't reshuffle the layout
      "eDP-1,preferred,0x0,1"
    ]
    # dell desk monitor: the panel does 144Hz but its preferred EDID
    # timing is 60, so pin the mode. desc: match survives port renames
    # (HDMI-A-1 etc) across docks and replugs.
    ++ lib.optionals ((osConfig.networking.hostName or "") == "dell") [
      "desc:Acer Technologies SA272U P1 4622020E72X00,2560x1440@144,1920x0,1"
    ]
    # Anything else (projector, hotel TV): preferred mode, auto-placed
    ++ [
      ",preferred,auto,1"
    ];
  };
}
