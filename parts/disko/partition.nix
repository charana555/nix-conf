# This is the partition file schema used by the nixos system
{
  device ? "/dev/vda",
  encrypted ? false,
  impermanence ? false,
  ssd ? true,
  ssdOptions ? [ ],
  lib ? import <nixpkgs/lib>,
  ...
}:
with lib;
let
  mountOptions = [ "compress=zstd" ] ++ optionals ssd ssdOptions;
  subvolumes = mkMerge [
    {
      "/root" = {
        mountpoint = "/";
        inherit mountOptions;
      };
      "/nix" = {
        mountOptions = mountOptions ++ [
          "noatime"
          "noacl"
        ];
        mountpoint = "/nix";
      };
    }
    (mkIf impermanence {
      "/persistent" = {
        inherit mountOptions;
        mountpoint = "/persistent";
      };
    })
  ];

in
{
  disko.devices.disk.primary = {
    type = "disk";
    device = device;
    content = {
      type = "gpt";
      partitions = mkMerge [
        {
          ESP = {
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [
                "defaults"
                "umask=0077"
              ];
            };
          };
        }
        (mkIf (!encrypted) {
          root = {
            size = "100%";
            type = "8300";
            content = {
              type = "btrfs";
              inherit subvolumes;
            };
          };
        })

        (mkIf encrypted {
          root = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              settings.allowDiscards = true;
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ];
                inherit subvolumes;
              };
            };
          };
        })
      ];
    };
  };
}
