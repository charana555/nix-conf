# Placeholder - regenerate after booting NixOS installer:
#   sudo nixos-generate-config --show-hardware-config --root /mnt > ./hosts/nixos/dell/hardware.nix
{
  flake,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "xhci_pci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "aes_x86_64"
      "cryptd"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  hardware.enableRedistributableFirmware = lib.mkDefault true;

  services.fstrim.enable = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
