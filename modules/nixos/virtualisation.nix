{
  config,
  ...
}:
{
  # QEMU/KVM + libvirt + Virt-Manager + SPICE stack. UEFI (incl. Secure Boot)
  # firmware ships with QEMU and is exposed to libvirt automatically, no
  # extra OVMF wiring needed.
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      # Unprivileged QEMU (upstream default); libvirtd chowns guest files to
      # qemu-libvirtd at runtime via dynamic ownership.
      runAsRoot = false;
      # Emulated TPM 2.0, required by Windows 11.
      swtpm.enable = true;
    };
  };

  # GUI; also sets a dconf default so virt-manager autoconnects to
  # qemu:///system without sudo for libvirtd group members.
  programs.virt-manager.enable = true;

  # SPICE USB redirection helper so unprivileged sessions can attach USB
  # devices to VMs (polkit-gated per device, not blanket udev access).
  virtualisation.spiceUSBRedirection.enable = true;

  # libvirtd-config installs the default NAT network XML but nothing marks it
  # autostart, so fresh VMs would fail with "network 'default' is not active".
  # Both calls are idempotent.
  systemd.services.libvirt-default-network = {
    after = [ "libvirtd.service" ];
    wants = [ "libvirtd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    path = [ config.virtualisation.libvirtd.package ];
    script = ''
      virsh --connect qemu:///system net-start default || true
      virsh --connect qemu:///system net-autostart default || true
    '';
  };
}
