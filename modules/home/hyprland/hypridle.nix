{
  lib,
  config,
  pkgs,
  ...
}:
let
  # caelestia hosts lock through the shell's IPC; others use hyprlock
  cael = config.apps.caelestia.enable;
  caelestia-shell = "${config.programs.caelestia.package}/bin/caelestia-shell";
in
{
  services.hypridle = {
    enable = true;
    settings =
      let
        timeout = 300;
        loginctl = "${lib.getExe' pkgs.systemd "loginctl"}";
      in
      {
        general = {
          lock_cmd =
            if cael then
              "${caelestia-shell} ipc call lock lock"
            else
              "${lib.getExe config.programs.hyprlock.package}";
          unlock_cmd =
            if cael then
              "${caelestia-shell} ipc call lock unlock"
            else
              "${lib.getExe pkgs.killall} -q -s SIGUSR1 hyprlock";
          before_sleep_cmd = "${loginctl} lock-session";
          ignore_dbus_inhibit = false;
        };
        listener = [
          {
            timeout = timeout - 10;
            on-timeout = "${loginctl} lock-session";
          }
          {
            inherit timeout;
            on-timeout = "hyprctl dispatch dpms off";
            on-resume = "hyprctl dispatch dpms on";
          }
          {
            timeout = timeout + 60;
            on-timeout = "${lib.getExe' pkgs.systemd "systemctl"} suspend";
          }
        ];
      };
  };
  systemd.user.services.hypridle.Unit.After = lib.mkForce "graphical-session.target";
}
