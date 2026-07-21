{ flake, lib, ... }:
{
  imports = [
    flake.inputs.stylix.nixosModules.stylix
    (flake + /modules/home/stylix/config.nix)
  ];

  options.services.kmscon.config = lib.mkOption {
    type = lib.types.attrs;
    default = { };
    visible = false;
    description = "Dummy option for stylix kmscon target compatibility";
  };

  config = {
    home-manager.sharedModules = [
      { stylix.enableReleaseChecks = false; }
      (
        { lib, ... }:
        {
          # stylix hyprland target checks this attribute which doesn't exist in current home-manager
          options.wayland.windowManager.hyprland.configType = lib.mkOption {
            type = lib.types.str;
            default = "hyprlang";
            readOnly = true;
            visible = false;
          };
        }
      )
    ];

    stylix.targets.kmscon.enable = false;
  };
}
