{
  disko.devices.disk.primary = {
    device = "/dev/vda";
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
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
        root = {
          size = "100%";
          type = "8300";
          content = {
            type = "btrfs";
            subvolumes = {
              "/root" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/";
              };
              "/persistent" = {
                mountOptions = [ "compress=zstd" ];
                mountpoint = "/persistent";
              };
              "/nix" = {
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                  "noacl"
                ];
                mountpoint = "/nix";
              };
            };
          };
        };
      };
    };
  };
}
