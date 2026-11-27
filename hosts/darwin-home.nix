{
  flake,
  inputs,
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
  # aarch64-darwin build in nixpkgs (whatsapp-for-mac is the official
  # client) - no brew needed
  apps.whatsapp.enable = true;

  # LocalSend has no darwin build in nixpkgs - install via `brew install --cask localsend`
  # ponytail: revisit if nixpkgs gains a darwin package, then use apps.localsend.enable

  home.packages = with pkgs; [
    cargo
    rustc
    docker
    docker-compose
    colima
    gitleaks
    haskell-language-server
    pinentry_mac
  ];

  # Zen on a Kandji-managed machine: patch the bundle ID to
  # app.zen-browser.zen-oss so the MDM profile (targeting app.zen-browser.zen)
  # stops matching - same dodge as semi710/ndots jp-mbp. Wrapped mode is
  # required: policies/extensions ride inside the bundle via wrapFirefox and
  # survive the bundle ID change; signed mode would keep routing policies
  # through the app.zen-browser.zen defaults domain, which the patched app no
  # longer reads.
  programs.zen-browser = {
    darwin.packageMode = "wrapped";

    # PlistBuddy patch invalidates the upstream signature; the codesign
    # appended to the wrapper's buildCommand below restores an ad-hoc one.
    # The zen-beta symlink exists because wrapFirefox resolves the
    # executable via the beta binary name.
    unwrappedPackage =
      inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.beta-unwrapped.overrideAttrs
        (old: {
          postInstall = (old.postInstall or "") + ''
            /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier app.zen-browser.zen-oss" \
              "$out/Applications/Zen Browser (Beta).app/Contents/Info.plist"
            ln -sf zen "$out/Applications/Zen Browser (Beta).app/Contents/MacOS/zen-beta"
          '';
        });

    # The HM module skips policies when unwrappedPackage is set, so wrap
    # ourselves and pass them through the wrapper. wrapFirefox drives the
    # build via buildCommand (phase hooks never run), so append there:
    # dereference the symlinks it leaves on Info.plist and the main
    # executable (codesign refuses symlinks there), drop the upstream
    # _CodeSignature (symlinks into the read-only store), and re-sign the
    # bundle ad hoc - launchd refuses to spawn it while the seal is broken.
    package =
      (pkgs.wrapFirefox config.programs.zen-browser.unwrappedPackage {
        inherit (config.programs.zen-browser) extraPrefs extraPrefsFiles nativeMessagingHosts;
        extraPolicies = config.programs.zen-browser.policies;
        icon = "zen-browser";
      }).overrideAttrs
        (old: {
          buildCommand = old.buildCommand + ''
            app="$out/Applications/Zen Browser (Beta).app"
            rm -rf "$app/Contents/_CodeSignature"
            chmod -R u+w "$app"
            for f in "$app/Contents/Info.plist" "$app/Contents/MacOS/zen"; do
              if [ -L "$f" ]; then
                cp -L "$f" "$f.real" && rm "$f" && mv "$f.real" "$f"
              fi
            done
            # Sign the wrapper script (codesign treats it as unsigned nested
            # code otherwise), then the outer seal. No --deep: nested code is
            # symlinked into the read-only store and keeps its intact upstream
            # signature; only the outer bundle is rewritten.
            /usr/bin/codesign --force --sign - "$app/Contents/MacOS/zen-beta"
            /usr/bin/codesign --force --sign - "$app"
          '';
        });
  };

  programs.gpg = {
    enable = true;
  };
  services.gpg-agent = {
    enable = true;
    pinentry.package = pkgs.pinentry_mac;
  };

  # Home-manager exposes GUI apps only via ~/Applications/Home Manager Apps,
  # a symlink into the read-only /nix/store. Spotlight does not index through
  # symlinks into /nix, and LaunchServices resolves symlinked bundles to their
  # store path (which it does not scan), so no nix-installed app shows in
  # Spotlight search. Copy the apps as real, dereferenced files into a
  # subfolder of ~/Applications (a standard apps dir LaunchServices scans)
  # so macOS indexes them. A separate folder avoids fighting home-manager's
  # own management of the "Home Manager Apps" symlink. The trailing chmod
  # makes the copies writable so the next activation's rm -rf does not stall
  # on read-only store modes (Finder would otherwise prompt for auth).
  home.activation.exposeGuiApps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    base="$HOME/Applications/Nix Apps"
    $DRY_RUN_CMD chmod -R u+w "$base" 2>/dev/null || true
    $DRY_RUN_CMD rm -rf "$base"
    $DRY_RUN_CMD mkdir -p "$base"
    for app in "$HOME/.nix-profile/Applications"/*.app; do
      [ -e "$app" ] || continue
      $DRY_RUN_CMD cp -RH "$app" "$base/" || echo "warning: could not copy $app" >&2
    done
    $DRY_RUN_CMD chmod -R u+w "$base" 2>/dev/null || true
    # one-time cleanup: a previous revision copied into a hidden dot-dir
    # that Spotlight refused to index
    $DRY_RUN_CMD rm -rf "$HOME/.local/share/nix-apps"
  '';
}
