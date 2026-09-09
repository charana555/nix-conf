# Shared "card" palette - single source of truth for rofi's card theme
# (launcher/theme.nix) and waybar's module chips (hyprland/waybar.nix).
# catppuccin-mocha, matching the hand-tuned values the card theme shipped
# with. Keys mirror the rasi variable names in theme.nix.
{
  bg = "#1e1e2e";
  bg-input = "#292c3c";
  fg = "#cdd6f4";
  fg-dim = "#7f849c";
  accent = "#f5c2e7";
  border-c = "#313244";
  # State colors for waybar chips - mocha yellow/red, palette-consistent
  # companions for battery warning/critical (rofi has no urgent state).
  warn = "#f9e2af";
  critical = "#f38ba8";

  font = {
    family = "JetBrainsMono Nerd Font";
    # weight variant shipped by nerd-fonts.jetbrains-mono, parsed by pango
    weight = "SemiBold";
    size = 11;
  };
}
