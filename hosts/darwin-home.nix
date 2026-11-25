{
  flake,
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = import (flake + "/config.nix");
in
{
  home.username = cfg.users.work.username;
  home.homeDirectory = "/Users/${cfg.users.work.username}";

  imports = [
    flake.homeModules.default
    flake.homeModules.stylix
  ];

  sops.secrets."private-keys/ssh" = {
    path = "${config.home.homeDirectory}/.ssh/id_ed25519";
    mode = "0600";
  };

  programs.git = {
    settings.user = {
      name = cfg.users.work.fullname;
      email = cfg.users.work.email;
    };

    includes = [
      {
        condition = "gitdir:~/personal/";
        contents = {
          user = {
            name = cfg.users.me.fullname;
            email = cfg.users.me.email;
          };
        };
      }
    ];
  };

  apps.maccy.enable = true;
  # Both have aarch64-darwin builds in nixpkgs (discord with Vencord/OpenASAR,
  # whatsapp-for-mac is the official client) - no brew needed
  apps.whatsapp.enable = true;
  apps.discord.enable = true;

  # LocalSend has no darwin build in nixpkgs - install via `brew install --cask localsend`
  # ponytail: revisit if nixpkgs gains a darwin package, then use apps.localsend.enable

  home.packages = with pkgs; [
    cargo
    rustc
    docker
    docker-compose
    colima
    tailscale
    gitleaks
    haskell-language-server
    pinentry_mac
  ];

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  # Home-manager exposes GUI apps only via ~/Applications/Home Manager Apps,
  # a symlink into the read-only /nix/store. LaunchServices and Spotlight
  # never index that, so no nix-installed app shows in Launchpad or
  # Spotlight. Copy the apps as real files into ~/Applications/Nix Apps so
  # macOS can index them. Copies (not links) are required: Spotlight does
  # not follow links into /nix, and lsregister resolves symlinked bundles
  # to their store path. A separate folder avoids fighting home-manager's
  # own management of the "Home Manager Apps" symlink.
  home.activation.exposeGuiApps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    base="$HOME/Applications/Nix Apps"
    # copies inherit the store's read-only mode, so make them deletable first
    $DRY_RUN_CMD chmod -R u+w "$base" 2>/dev/null || true
    $DRY_RUN_CMD rm -rf "$base"
    $DRY_RUN_CMD mkdir -p "$base"
    for app in "$HOME/.nix-profile/Applications"/*.app; do
      $DRY_RUN_CMD cp -RH "$app" "$base/" || echo "warning: could not copy $app" >&2
    done
  '';
}
