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
      ssdOptions = [
        "ssd"
        "discard=async"
        "space_cache=v2"
      ];
    })
  ];

  # 1TB SATA HDD - not managed by disko, just mounted
  # nofail prevents boot failure if drive is disconnected
  fileSystems."/mnt/hdd" = {
    device = "/dev/disk/by-label/HDD";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };
}
