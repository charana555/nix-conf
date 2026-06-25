{ config, pkgs, inputs, ... }:

{
  imports = [
    ./modules
    inputs.sops-nix.homeManagerModules.sops
  ];

  home.stateVersion = "25.05";

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../secrets/keys.yaml;
  };

  nix.package = pkgs.nix;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  programs.home-manager.enable = true;

  xdg.configFile."opencode/opencode.json".text = builtins.toJSON (
    (builtins.fromJSON (builtins.readFile ../opencode/opencode.json))
    // { plugin = [ "${inputs.ponytail}/.opencode/plugins/ponytail.mjs" ]; }
  );

  xdg.configFile."opencode/skills/frontend-design/SKILL.md".source = ../opencode/skills/frontend-design/SKILL.md;
  xdg.configFile."opencode/skills/ponytail/SKILL.md".source = "${inputs.ponytail}/skills/ponytail/SKILL.md";
  xdg.configFile."opencode/skills/ponytail-review/SKILL.md".source = "${inputs.ponytail}/skills/ponytail-review/SKILL.md";
  xdg.configFile."opencode/skills/ponytail-audit/SKILL.md".source = "${inputs.ponytail}/skills/ponytail-audit/SKILL.md";
  xdg.configFile."opencode/skills/ponytail-debt/SKILL.md".source = "${inputs.ponytail}/skills/ponytail-debt/SKILL.md";
  xdg.configFile."opencode/skills/ponytail-gain/SKILL.md".source = "${inputs.ponytail}/skills/ponytail-gain/SKILL.md";
  xdg.configFile."opencode/skills/ponytail-help/SKILL.md".source = "${inputs.ponytail}/skills/ponytail-help/SKILL.md";

  xdg.configFile."opencode/command/ponytail.md".source = "${inputs.ponytail}/.opencode/command/ponytail.md";
  xdg.configFile."opencode/command/ponytail-review.md".source = "${inputs.ponytail}/.opencode/command/ponytail-review.md";
  xdg.configFile."opencode/command/ponytail-audit.md".source = "${inputs.ponytail}/.opencode/command/ponytail-audit.md";
  xdg.configFile."opencode/command/ponytail-debt.md".source = "${inputs.ponytail}/.opencode/command/ponytail-debt.md";
  xdg.configFile."opencode/command/ponytail-gain.md".source = "${inputs.ponytail}/.opencode/command/ponytail-gain.md";
  xdg.configFile."opencode/command/ponytail-help.md".source = "${inputs.ponytail}/.opencode/command/ponytail-help.md";
}
