# Nix-Conf Migration Tracker

**Last updated**: 2026-05-23  
**Build command**: `home-manager build --flake .#itachi@popos`  
**Stage all before build**: `git add -A` (Nix flakes only see git-tracked files)

---

## Current Module Structure

```
config.nix                  # User details (name, email, username per host)
home/modules/
├── default.nix           # Auto-imports subdirectories
├── shell/
│   ├── default.nix       # Auto-imports .nix files in shell/
│   ├── git.nix           # git + gh + lazygit (identity from host configs)
│   ├── zsh.nix           # zsh + vi-mode + fzf-tab + OSC52
│   ├── starship.nix      # Full Nix-native starship config
│   ├── tmux.nix          # Full Nix-native tmux with plugins
│   ├── fzf.nix           # fzf with fd integration + zsh integration
│   ├── bat.nix           # bat with Catppuccin Mocha theme
│   ├── eza.nix           # eza with icons, git, zsh integration
│   ├── zoxide.nix        # zoxide with zsh integration
│   ├── direnv.nix        # direnv + nix-direnv
│   └── packages.nix      # All home.packages (core, CLI, dev, languages, etc.)
├── editor/
│   ├── default.nix       # Auto-imports .nix files in editor/
│   └── nvim.nix          # nixvim (full config)
└── terminal/
    ├── default.nix       # Auto-imports .nix files in terminal/
    └── kitty.nix         # Full Nix-native kitty config (Catppuccin Mocha)

home/common.nix           # Imports only: modules, stateVersion, home-manager, xdg opencode links
```

---

## COMPLETED Migrations

| Module | Original | Status |
|--------|----------|--------|
| git.nix | Inline in common.nix | Done - identity moved to host configs via config.nix |
| zsh.nix | Inline in common.nix | Done - vi-mode, fzf-tab, OSC52, initContent API |
| starship.nix | External starship.toml + xdg link | Done - full Nix-native, toml kept as reference |
| tmux.nix | External tmux.conf + xdg link + tpm | Done - Nix plugins, hand-crafted Catppuccin status bar |
| Auto-import pattern | Manual imports in common.nix | Done - default.nix in modules/, shell/, editor/, terminal/ |
| nixvim | External nvim/init.lua | Done - full nixvim config, keymaps use options.desc, web-devicons enabled |
| config.nix | Hardcoded in git.nix | Done - user details extracted, hosts use let/in bindings |
| kitty.nix | External kitty.conf + xdg link | Done - full Nix-native with Catppuccin Mocha colors, keybinds |
| fzf.nix | `programs.fzf.enable` only | Done - fd integration, defaultCommand, defaultOptions, zsh integration |
| bat.nix | Package only | Done - Catppuccin Mocha theme, style config |
| eza.nix | Package only | Done - icons, git, zsh integration, directory-first |
| zoxide.nix | Package only | Done - zsh integration (z command) |
| direnv.nix | Not managed | Done - direnv + nix-direnv with zsh integration |
| packages.nix | Inline in common.nix | Done - extracted to dedicated module with categories |

---

## Build Notes

### nixvim Keymaps
- `desc` must be under `options.desc`, not top-level: `{ key = "..."; action = "..."; options.desc = "..."; }`
- `mode` can be a string or list of strings at top level
- `action.__raw` works for Lua functions

### nixvim Warnings Fixed
- `web-devicons` must be explicitly enabled (auto-enabled was deprecated)

### catppuccin/bat Theme
- Repo rev must be current; old revs may 404
- Theme name with spaces must be quoted: `"Catppuccin Mocha"`

---

## Architecture Notes

### Auto-Import Pattern
```nix
# For directories containing .nix files (like shell/):
{ imports = with builtins;
    map (file: ./${file})
    (filter (file: file != "default.nix")
    (attrNames (readDir ./.)));
}

# For directories containing subdirectories (like modules/):
{ imports = with builtins;
    map (dir: ./${dir})
    (filter (name: name != "default.nix" && (readDir ./.).${name} == "directory")
    (attrNames (readDir ./.)));
}
```

### config.nix Host Binding Pattern
```nix
let
  cfg = import ../../config.nix;
  me = cfg.me // cfg.personal;  # or cfg.work
in
{ ... }:
{
  home.username = me.username;
  programs.git.settings.user = { name = me.fullname; email = me.email; };
}
```

### Nix String Escaping Quick Reference
| Context | Literal `${var}` | Example |
|---------|-------------------|---------|
| Multi-line `'' ... ''` | `''${var}` | `''⇡''${count}''` |
| Double-quoted `"..."` | `\${var}` | `"⇡\${count}"` |

### Home-Manager Module Merging
- Multiple modules setting `programs.git.includes` → lists are merged
- Multiple modules setting `home.packages` → lists are merged
- Multiple modules setting `programs.zsh.initContent` → must use `lib.mkMerge` / `lib.mkOrder`
- Later imports override earlier ones for scalar values (strings, booleans)

### Key Deprecation Warnings Fixed
- `programs.git.userName` / `userEmail` → `programs.git.settings.user.name` / `settings.user.email`
- `programs.zsh.initExtraFirst` / `initExtra` → `programs.zsh.initContent` with `lib.mkOrder`
- `nixvim.homeManagerModules` → `nixvim.homeModules`
- nixvim keymaps `desc` → `options.desc`
- nixvim `plugins.web-devicons` auto-enable → explicit `plugins.web-devicons.enable = true`

---

## Files Kept as Reference (Not Deleted)
- `starship/starship.toml` — original TOML config
- `tmux/tmux.conf` — original tmux config
- `kitty/kitty.conf` — original kitty config (now Nix-native)
- `nvim/init.lua` — original neovim config (1104 lines, to be deleted after nixvim is verified)

---

## Future Improvements (Optional)
- SSH module with public keys (when NixOS module is created)
- Catppuccin theme module (unify colors across kitty, bat, etc.)
- Test nvim OSC52 clipboard over SSH/tmux
- Test conform-nvim format_on_save with `__raw` wrapper
- Verify which-key `spec` `__unkeyed-1` pattern works at runtime
- Consider removing `mason-lspconfig` since `ts_ls` and `lua_ls` are managed by nixvim lsp directly
