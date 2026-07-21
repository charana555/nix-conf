{ ... }:

{
  imports =
    with builtins;
    map (file: ./${file}) (
      filter (file: file != "default.nix" && file != "tab_bar.py") (attrNames (readDir ./.))
    );
}
