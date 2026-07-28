{
  flake,
  config,
  ...
}:
let
  me = (import (flake + "/config.nix")).users.me;
in
{
  imports = [
    flake.homeModules.terminal
    flake.homeModules.browser
    flake.homeModules.editor
    flake.homeModules.apps
    # hyprland is added via nixosModules.hyprland home-imports (sharedModules)
  ];

  apps.keepassxc.enable = true;
  apps.nextcloud.enable = true;

  programs.git = {
    settings.user = {
      name = me.fullname;
      email = me.email;
    };
  };
}
