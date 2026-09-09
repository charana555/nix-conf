# Rofi "card" theme.
#
# The rasi lives here as a writeText string because home-manager's
# attrset theme serializer quotes every value - `background-color: "@bg"`
# becomes an inert string instead of a variable reference, and rofi
# falls back to white. The exact hand-tuned rasi is installed verbatim
# via xdg.dataFile and referenced as a named theme.
#
# Runtime settings (icon-theme, show-icons) live in default.nix
# extraConfig - a configuration block must not be part of a theme.
{
  pkgs,
  ...
}:
let
  palette = import ./palette.nix;
  card-theme = pkgs.writeText "card.rasi" ''
    /**
     * "card" - a small rounded card centered on screen,
     * a thin accent border and generous internal spacing.
     * The most "designed" of the three, still restrained.
     */

    * {
        bg:        ${palette.bg};
        bg-input:  ${palette.bg-input};
        fg:        ${palette.fg};
        fg-dim:    ${palette.fg-dim};
        accent:    ${palette.accent};
        border-c:  ${palette.border-c};

        font: "${palette.font.family} ${palette.font.weight} ${toString palette.font.size}";
    }

    window {
        transparency: "real";
        background-color: @bg;
        text-color: @fg;
        border: 1px;
        border-color: @border-c;
        border-radius: 16px;
        width: 520px;
        location: center;
        anchor: center;
        padding: 20px;
    }

    mainbox {
        background-color: transparent;
        children: [ inputbar, listview ];
        spacing: 14px;
    }

    inputbar {
        background-color: @bg-input;
        text-color: @fg;
        border-radius: 10px;
        padding: 10px 14px;
        children: [ prompt, entry ];
        spacing: 8px;
    }

    prompt {
        background-color: transparent;
        text-color: @accent;
        enabled: true;
    }

    entry {
        background-color: transparent;
        text-color: @fg;
        placeholder: "type to search…";
        placeholder-color: @fg-dim;
        cursor: text;
    }

    listview {
        background-color: transparent;
        lines: 8;
        spacing: 4px;
        cycle: true;
        dynamic: true;
        scrollbar: false;
    }

    element {
        background-color: transparent;
        text-color: @fg-dim;
        padding: 8px 10px;
        border-radius: 8px;
    }

    element selected {
        background-color: @bg-input;
        text-color: @accent;
    }

    element-text {
        background-color: transparent;
        text-color: inherit;
        vertical-align: 0.5;
    }

    /* background-color MUST be set: rofi's default for element-icon is
       an opaque white tile (rofi issue #1397) */
    element-icon {
        background-color: transparent;
        size: 24px;
        padding: 0px 8px 0px 0px;
    }
  '';
in
{
  xdg.dataFile."rofi/themes/card.rasi".source = card-theme;
  programs.rofi.theme = "card";

  # theme carries its own colors and font; stylix's rofi target would
  # fight this for programs.rofi.theme.
  stylix.targets.rofi.enable = false;
}
