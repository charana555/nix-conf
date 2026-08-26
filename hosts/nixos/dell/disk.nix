{
  flake,
  lib,
  ...
}:
{
  imports = [
    (flake.disko.partition {
      inherit lib;
      device = "/dev/nvme0n1";
      encrypted = true;
      ssd = true;
      impermanence = true;
      ssdOptions = [
        "ssd"
        "discard=async"
        "space_cache=v2"
      ];
    })
  ];
}
