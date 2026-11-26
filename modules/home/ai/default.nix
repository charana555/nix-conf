# AI agents via the s-ai flake: skills, prompts, MCP servers and provider
# renders live there (s-ai closes over its own agent inputs, so no
# specialArgs are needed). This file supplies only what s-ai does not ship:
# the Juspay grid, the omniroute local gateway, the OMO role routing, the
# github MCP server, the OpenAgentsControl subagent registry, and the
# repo-local skill sets.
{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  # OpenAgentsControl registry: the subagent roster (TaskManager,
  # CodeReviewer, ContextScout, ...) plus its command/context tree,
  # resolved from the registry's developer profile
  opencodeRegistryFiles = import ../../../opencode/registry.nix {
    inherit inputs lib;
  };
in
{
  imports = [ inputs.s-ai.homeModules.s-ai ];

  s-ai = {
    # opencode only for now; omp and pi are available from the same layer
    # when wanted (omp compiles from source via bun2nix)
    agents.omp.enable = false;
    agents.pi.enable = false;

    providers.litellm = {
      baseUrl = "https://grid.ai.juspay.net";
      apiKeyEnv = "JUSPAY_API_KEY";
      # windows/maxTokens as the grid advertises on `GET /v1/models`; if the
      # grid's routing changes, re-check that endpoint
      models = [
        {
          id = "claude-opus-4-5";
          contextWindow = 1000000;
          maxTokens = 128000;
        }
        {
          id = "claude-opus-4-6";
          contextWindow = 1000000;
          maxTokens = 128000;
        }
        {
          id = "claude-sonnet-4-5";
          contextWindow = 200000;
          maxTokens = 64000;
        }
        {
          id = "claude-sonnet-4-6";
          contextWindow = 200000;
          maxTokens = 64000;
        }
        {
          id = "claude-haiku-4-5-20251001";
          contextWindow = 200000;
          maxTokens = 64000;
        }
        {
          id = "gemini-3-flash-preview";
          contextWindow = 1048576;
          maxTokens = 65535;
        }
        {
          id = "gemini-3-pro-preview";
          contextWindow = 1048576;
          maxTokens = 65535;
        }
        {
          id = "gemini-3.1-pro";
          contextWindow = 1048576;
          maxTokens = 65536;
        }
        {
          id = "glm-flash-experimental";
          contextWindow = 128000;
          maxTokens = 128000;
        }
        {
          id = "glm-latest";
          contextWindow = 400000;
          maxTokens = 400000;
        }
        {
          id = "kimi-latest";
          contextWindow = 256000;
          maxTokens = 32000;
        }
        {
          id = "kimi-k3";
          contextWindow = 256000;
          maxTokens = 32000;
        }
        {
          id = "minimaxai/minimax-m2";
          contextWindow = 256000;
          maxTokens = 256000;
        }
        {
          id = "open-fast";
          contextWindow = 256000;
          maxTokens = 256000;
        }
        {
          id = "open-large";
          contextWindow = 256000;
          maxTokens = 32000;
        }
      ];
      defaultModel = "glm-latest";
    };

    # opencode-only local gateway
    providers.omniroute = {
      baseUrl = "http://localhost:20128/v1";
      apiKeyEnv = "OMNIROUTE_API_KEY";
      models = [
        "lightx-ai"
        "auto"
      ];
      defaultModel = "lightx-ai";
    };
    defaultProvider = "litellm";

    # OMO role routing: every role inherits glm-latest except the explore
    # lane, which keeps the open-fast model agent.explore ran on before
    agents.opencode.models.explorer = "litellm/open-fast";

    # worktree/tmux workflow skills (off by default in s-ai); the binary
    # itself is installed by shell/tmux.nix from the same input rev
    plugins.workmux.enable = true;

    mcp.servers.github = {
      command = lib.getExe pkgs.github-mcp-server;
      args = [ "stdio" ];
      env.GITHUB_PERSONAL_ACCESS_TOKEN = "{env:GITHUB_TOKEN}";
    };

    # s-ai's canonical set includes codegraph, which the pinned nixpkgs does
    # not ship yet. Disable it with a stub command (never spawned) until the
    # pin catches up; the override self-removes once pkgs gains codegraph.
    mcp.servers.codegraph =
      if pkgs ? codegraph then
        { }
      else
        {
          command = lib.mkForce "true";
          args = lib.mkForce [ ];
          enabled = false;
        };

    # s-ai runs the mcp-nixos binary directly, but pkgs.mcp-nixos does not
    # evaluate on aarch64-darwin with the current nixpkgs pin (it forces a
    # luajit-source build whose meta.platforms excludes arm64 darwin), so
    # keep the nix run form both hosts used before the s-ai move. mkForce
    # discards s-ai's command definition without evaluating it; drop this
    # override once the pin can build the binary everywhere.
    mcp.servers.nixos = {
      command = lib.mkForce (lib.getExe pkgs.nix);
      args = lib.mkForce [
        "run"
        "github:utensils/mcp-nixos"
        "--"
      ];
    };
  };

  # opencode's TUI rewrites cli.json in place (settings dialog), replacing
  # the store symlink with a regular file; force keeps the next deploy from
  # wedging on the backup collision
  home.file.".config/opencode/cli.json".force = true;

  # v2 reads cli.json (rendered by the s-ai module); home-manager's pin
  # still renders the v1-named tui.json, which v2 ignore-warns on and
  # which would collide with the live unmanaged tui.json on switch.
  # The theme rides in cli.json via themes.stylix instead.
  programs.opencode.tui = lib.mkForce { };

  xdg.configFile = opencodeRegistryFiles // {
    # vendored skills s-ai's plugin model cannot express: archify ships a
    # full package at <input>/archify with no skill-parent directory, and
    # taste-skill's skills/ dir holds 14 skills of which we want one
    "opencode/skills/archify".source = "${inputs.archify}/archify";
    "opencode/skills/design-taste-frontend/SKILL.md".source =
      "${inputs.taste-skill}/skills/taste-skill/SKILL.md";
    "opencode/skills/shadcn".source = ../../../opencode/skills/shadcn;
  };
}
