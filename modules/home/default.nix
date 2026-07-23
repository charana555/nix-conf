{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  opencodeConfig = builtins.fromJSON (builtins.readFile ../../opencode/opencode.json);
  opencodeRegistryFiles = import ../../opencode/registry.nix { inherit inputs lib; };
  opencodeMcp = import ../../opencode/mcp.nix { inherit lib pkgs; };

  ponytailSkillNames = [
    "ponytail"
    "ponytail-review"
    "ponytail-audit"
    "ponytail-debt"
    "ponytail-gain"
    "ponytail-help"
  ];

  ponytailSkillFiles = builtins.listToAttrs (
    map (name: {
      name = "opencode/skills/${name}/SKILL.md";
      value.source = "${inputs.ponytail}/skills/${name}/SKILL.md";
    }) ponytailSkillNames
  );

  ponytailCommandFiles = builtins.listToAttrs (
    map (name: {
      name = "opencode/command/${name}.md";
      value.source = "${inputs.ponytail}/.opencode/command/${name}.md";
    }) ponytailSkillNames
  );
in
{
  imports =
    inputs.nix-wire.lib.autoImportExcept ./. [
      "stylix"
      "hyprland"
    ]
    ++ [ inputs.sops-nix.homeManagerModules.sops ];

  home.stateVersion = "25.05";
  fonts.fontconfig.enable = true;

  sops = {
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/keys.yaml;
  };

  nix.package = lib.mkDefault pkgs.nix;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  programs.home-manager.enable = true;

  xdg.configFile =
    opencodeRegistryFiles
    // ponytailSkillFiles
    // ponytailCommandFiles
    // {
      "opencode/opencode.json".text = builtins.toJSON (
        opencodeConfig
        // {
          plugin = (opencodeConfig.plugin or [ ]) ++ [ "${inputs.ponytail}/.opencode/plugins/ponytail.mjs" ];
          mcp = (opencodeConfig.mcp or { }) // opencodeMcp;
        }
      );

      "opencode/AGENTS.md".source = ../../opencode/AGENTS.md;
      "opencode/skills/frontend-design/SKILL.md".source =
        ../../opencode/skills/frontend-design/SKILL.md;
      "opencode/skills/git-wisdom/SKILL.md".source =
        ../../opencode/skills/git-wisdom/SKILL.md;
      "opencode/skills/think-deeper/SKILL.md".source =
        ../../opencode/skills/think-deeper/SKILL.md;
    };
}
