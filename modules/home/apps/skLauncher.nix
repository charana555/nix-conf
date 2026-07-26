{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  system = pkgs.stdenv.hostPlatform.system;
  sklauncher = inputs.ndots.packages.${system}.sklauncher;
  nixgl = inputs.nixgl.packages.${system};
in
{
  options.apps.skLauncher.enable = lib.mkEnableOption "SKLauncher";

  config = lib.mkIf config.apps.skLauncher.enable {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "sklauncher";
        paths = [
          (pkgs.writeShellScriptBin "skLauncher" ''
            exec ${nixgl.nixGLIntel}/bin/nixGLIntel ${sklauncher}/bin/sklauncher "$@"
          '')
          sklauncher
        ];
      })
    ];

    xdg.desktopEntries.sklauncher = {
      name = "SKLauncher";
      comment = "Minecraft Launcher";
      exec = "skLauncher";
      icon = "sklauncher";
      categories = [ "Game" ];
      terminal = false;
    };
  };
}
