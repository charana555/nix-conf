{
  inputs,
  pkgs,
  lib,
  ...
}:

let
  firefox-addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  # nixpkgs firefox is linux-only; darwin keeps using zen
  config = lib.mkIf pkgs.stdenv.isLinux {
    stylix.targets.firefox.profileNames = [ "default" ];

    # Secondary browser for DRM content (Crunchyroll, Netflix): zen can't
    # play Widevine-protected streams. Stock firefox downloads the Widevine
    # CDM into the profile at first playback; the prebuilt blob runs because
    # nix-ld is enabled system-wide (modules/nixos/default.nix). Zen stays
    # the default browser (xdg/mime defaults live in zen.nix).
    programs.firefox = {
      enable = true;

      profiles.default = {
        # Same extension set as zen (rycee where possible)
        extensions.force = true;
        extensions.packages = with firefox-addons; [
          ublock-origin
          darkreader
          simple-translate
          firenvim
          auto-tab-discard
          duckduckgo-privacy-essentials
          vimium
          zen-internet
          refined-github
          bitwarden
        ];

        extensions.settings = {
          "addon@darkreader.org".settings = {
            syncSettings = true;
            previewNewDesign = true;
          };
        };
      };

      policies = {
        AutofillAddressEnabled = true;
        AutofillCreditCardEnabled = false;
        DisableAppUpdate = true;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableTelemetry = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OfferToSaveLogins = false;
        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
        };
        # Extensions not in rycee — installed via AMO policies (same set as zen)
        ExtensionSettings = {
          # iCloud Passwords
          "password-manager-firefox-extension@apple.com" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/icloud-passwords/latest.xpi";
            installation_mode = "normal_installed";
          };
          # Material Icons for GitHub
          "{eac6e624-97fa-4f28-9d24-c06c9b8aa713}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/material-icons-for-github/latest.xpi";
            installation_mode = "normal_installed";
          };
          # GitOwl
          "gitowl@gitowl.dev" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/gitowl/latest.xpi";
            installation_mode = "normal_installed";
          };
          # Nixpkgs PR Tracker
          "nixpkgs-pr-tracker@tahayassine.me" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/nixpkgs-pr-tracker/latest.xpi";
            installation_mode = "normal_installed";
          };
          # LanguageTool (unfree license — not in rycee)
          "languagetool-webextension@languagetool.org" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/languagetool-grammar-checker/latest.xpi";
            installation_mode = "normal_installed";
          };
          # Wide GitHub
          "{72742915-c83b-4485-9023-b55dc5a1e730}" = {
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/widegithub/latest.xpi";
            installation_mode = "normal_installed";
          };
        };
      };
    };
  };
}
