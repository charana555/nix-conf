{ ... }:

{
  imports = with builtins;
    map (dir: ./${dir})
    (filter (name: name != "default.nix" && (readDir ./.).${name} == "directory")
    (attrNames (readDir ./.)));
}
