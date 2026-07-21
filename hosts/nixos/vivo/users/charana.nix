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
    # hyprland is added via nixosModules.hyprland home-imports (sharedModules)
  ];

  programs.git = {
    settings.user = {
      name = me.fullname;
      email = me.email;
    };
  };
}
