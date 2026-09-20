# Notification daemon. grimblast --notify (and anything else using
# notify-send) shows nothing without one running. Disable on hosts where
# the shell (caelestia) provides its own notification server.
{
  lib,
  config,
  ...
}:
{
  options.mako.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "mako notification daemon";
  };

  config = lib.mkIf config.mako.enable {
    services.mako.enable = true;
  };
}
