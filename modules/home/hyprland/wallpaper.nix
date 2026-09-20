{
  lib,
  pkgs,
  config,
  ...
}:
let
  awww = lib.getExe pkgs.awww;
  awww-daemon = lib.getExe' pkgs.awww "awww-daemon";

  # Repo stock wallpapers - symlinked to ~/.local/share/wallpapers on every
  # machine. Kept unconditional: caelestia's picker reads this dir too
  # (paths.wallpaperDir in apps/caelestia.nix).
  wallpapersDir = ../../../wallpapers;
  stockWallpapers = builtins.attrNames (builtins.readDir wallpapersDir);

  # Per-machine wallpapers - user drops files here
  userWallpaperDir = "${config.home.homeDirectory}/Pictures/Wallpapers";
  defaultWall = "${config.stylix.image}";

  # Start daemon at login, restore last choice, fall back to stylix default
  wallinit = pkgs.writeShellScriptBin "wallinit" ''
    ${awww-daemon} &
    for _ in $(seq 50); do
      ${awww} query >/dev/null 2>&1 && break
      sleep 0.1
    done
    ${awww} restore >/dev/null 2>&1
    ${awww} query 2>/dev/null | grep -q / || ${awww} img "${defaultWall}" --transition-type none
  '';

  # Rofi picker over default + repo stock + per-machine wallpapers
  wallset = pkgs.writeShellScriptBin "wallset" ''
    stock="$HOME/.local/share/wallpapers"
    mine="${userWallpaperDir}"
    mkdir -p "$mine"
    choice=$(
      {
        printf 'default\n'
        ls -1 "$stock" 2>/dev/null
        ls -1 "$mine" 2>/dev/null
      } | sort -u | ${lib.getExe pkgs.rofi} -dmenu -i -p wallpaper
    )
    [ -z "$choice" ] && exit 0
    if [ "$choice" = "default" ]; then
      wall="${defaultWall}"
    elif [ -f "$mine/$choice" ]; then
      wall="$mine/$choice"
    else
      wall="$stock/$choice"
    fi
    ${awww} img "$wall" --transition-type center
  '';
in
{
  # awww stack; disable on hosts where the shell (caelestia) owns the
  # wallpaper - its picker + background layer replace wallinit/wallset
  options.wallpaper.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "awww wallpaper daemon with rofi picker";
  };

  config = {
    # stock wallpapers stay symlinked everywhere; caelestia's picker
    # reads this dir (paths.wallpaperDir in apps/caelestia.nix)
    xdg.dataFile = builtins.listToAttrs (
      map (name: {
        name = "wallpapers/${name}";
        value.source = wallpapersDir + "/${name}";
      }) stockWallpapers
    );

    home.packages = lib.mkIf config.wallpaper.enable [
      pkgs.awww
      wallinit
      wallset
    ];

    xdg.userDirs.extraConfig.WF = lib.mkIf config.wallpaper.enable userWallpaperDir;

    wayland.windowManager.hyprland.settings = lib.mkIf config.wallpaper.enable {
      exec-once = [ (lib.getExe wallinit) ];
      bind = [ "$modSHIFT,w,exec,${lib.getExe wallset}" ];
    };
  };
}
