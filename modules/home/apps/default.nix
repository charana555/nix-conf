{ lib, ... }:

{
  imports =
    with builtins;
    map (file: ./${file}) (
      filter (file: file != "default.nix" && lib.hasSuffix ".nix" file) (attrNames (readDir ./.))
    );
}
