{
  lib,
  pkgs,
  config,
  ...
}:
let
  awww = lib.getExe pkgs.awww;
  awww-daemon = lib.getExe' pkgs.awww "awww-daemon";

  # Repo stock wallpapers - symlinked to ~/.local/share/wallpapers on every machine
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
  home.packages = [
    pkgs.awww
    wallinit
    wallset
  ];

  xdg.dataFile = builtins.listToAttrs (
    map (name: {
      name = "wallpapers/${name}";
      value.source = wallpapersDir + "/${name}";
    }) stockWallpapers
  );

  xdg.userDirs.extraConfig.WF = userWallpaperDir;

  wayland.windowManager.hyprland.settings = {
    exec-once = [ (lib.getExe wallinit) ];
    bind = [ "$modSHIFT,w,exec,${lib.getExe wallset}" ];
  };
}
