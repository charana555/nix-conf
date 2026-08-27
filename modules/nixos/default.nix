{
  flake,
  pkgs,
  ...
}:
{
  home-manager.sharedModules = [
    flake.homeModules.default
  ];

  # Backup conflicting home files instead of failing activation
  home-manager.backupFileExtension = "backup";

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  # Enable SSH server
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
    };
  };

  environment.systemPackages = with pkgs; [
    bash
    coreutils
    curl
    wget
    git
    gnutar
    gzip
    xz
    xdg-utils
    openssh
  ];
}
