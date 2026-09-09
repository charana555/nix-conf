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

  ohMyOpencode = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.oh-my-opencode;
  opencodeVim = inputs.opencode-vim.packages.${pkgs.stdenv.hostPlatform.system}.default;

  defaultModel = "litellm/glm-latest";

  omoConfig = builtins.toJSON {
    default_run_agent = "sisyphus";
    team_mode = {
      enabled = true;
      tmux_visualization = true;
    };
    agents = {
      sisyphus = {
        model = defaultModel;
      };
      metis = {
        model = defaultModel;
      };
      prometheus = {
        model = defaultModel;
      };
      atlas = {
        model = defaultModel;
      };
      hephaestus = {
        model = defaultModel;
        allow_non_gpt_model = true;
      };
      oracle = {
        model = defaultModel;
      };
      momus = {
        model = defaultModel;
      };
      explore = {
        model = defaultModel;
      };
      librarian = {
        model = defaultModel;
      };
      multimodal-looker = {
        model = defaultModel;
      };
      sisyphus-junior = {
        model = defaultModel;
      };
    };
  };

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

  workmuxSkillNames = [
    "coordinator"
    "merge"
    "open-pr"
    "rebase"
    "workmux"
    "worktree"
  ];

  workmuxSkillFiles = builtins.listToAttrs (
    map (name: {
      name = "opencode/skills/${name}/SKILL.md";
      value.source = "${inputs.workmux}/skills/${name}/SKILL.md";
    }) workmuxSkillNames
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

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    opencodeVim
    ohMyOpencode
  ];

  xdg.configFile =
    opencodeRegistryFiles
    // ponytailSkillFiles
    // ponytailCommandFiles
    // workmuxSkillFiles
    // {
      "opencode/opencode.json".text = builtins.toJSON (
        opencodeConfig
        // {
          plugin = (opencodeConfig.plugin or [ ]) ++ [
            "${inputs.ponytail}/.opencode/plugins/ponytail.mjs"
            "oh-my-openagent"
          ];
          mcp = (opencodeConfig.mcp or { }) // opencodeMcp;
        }
      );

      # opencode/tui.json is deliberately NOT managed here: opencode
      # rewrites it at runtime (plugin registration, TUI setting
      # changes), and a nix-managed symlink plus a stale .backup made
      # every switch fail with "would be clobbered". The live file
      # already carries the settings below - re-apply them manually on
      # a fresh machine via the TUI settings screen.
      #   vim_system_clipboard_register, vim_escape_sequence "jk",
      #   vim_enter_submit, vim_insert_after_submit, scroll_acceleration

      "opencode/oh-my-openagent.jsonc".text = omoConfig;

      "opencode/node_modules/oh-my-openagent".source = "${ohMyOpencode}/lib/oh-my-opencode";

      "opencode/AGENTS.md".source = ../../opencode/AGENTS.md;
      "opencode/skills/frontend-design/SKILL.md".source = ../../opencode/skills/frontend-design/SKILL.md;
      "opencode/skills/git-wisdom/SKILL.md".source = ../../opencode/skills/git-wisdom/SKILL.md;
      "opencode/skills/think-deeper/SKILL.md".source = ../../opencode/skills/think-deeper/SKILL.md;
    };
}
