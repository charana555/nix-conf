# Notification daemon. grimblast --notify (and anything else using
# notify-send) shows nothing without one running.
{ ... }:
{
  services.mako = {
    enable = true;
  };
}
