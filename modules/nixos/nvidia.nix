{
  config,
  lib,
  pkgs,
  ...
}:
{
  # NVIDIA Optimus hybrid graphics
  # Intel iGPU: 0000:00:02.0 -> PCI:0:2:0 (primary, battery-friendly)
  # NVIDIA dGPU: 0000:01:00.0 -> PCI:1:0:0 (on-demand via prime offload)
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
