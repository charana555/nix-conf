set positional-arguments

# Deploy - current host (auto-detects NixOS vs Darwin; Mac is standalone home-manager)
deploy host="":
    @if [ -z "{{host}}" ]; then \
        if [ "$(uname -s)" = "Darwin" ]; then \
            nh home switch . -c charana.c@darwin; \
        else \
            nh os switch . && { hyprctl reload 2>/dev/null || true; }; \
        fi; \
    else \
        nh os switch .#{{host}} --target-host charana.c@{{host}} --elevation-strategy passwordless; \
    fi

# Home-manager only (standalone, for non-NixOS machines)
# -c required: nh cannot express dotted config names (charana.c@...) as .#attrpaths
home user="itachi@popos":
    nh home switch . -c {{user}}

# Dry build (eval only, no compilation)
build host:
    nh os build .#{{host}} --dry

# Format nix files (config lives in the flake, so go through nix fmt)
fmt:
    nix fmt

# Update flake lock
update:
    nix flake update

# Check flake (eval all configs)
check:
    nix flake check

# Garbage collect - all profiles (needs sudo)
gc:
    sudo nh clean all
