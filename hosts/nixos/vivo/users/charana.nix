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

  apps.launcher.enable = true;
  apps.keepassxc.enable = true;
  apps.nextcloud.enable = true;
  apps.localsend.enable = true;
  apps.discord.enable = true;
  apps.whatsapp.enable = true;
  waybar.battery.enable = true;

  programs.git = {
    settings.user = {
      name = me.fullname;
      email = me.email;
    };
  };
}
