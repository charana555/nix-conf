set positional-arguments

# Deploy - current host (auto-detects NixOS vs Darwin)
deploy host="":
    @if [ -z "{{host}}" ]; then \
        if [ "$(uname -s)" = "Darwin" ]; then \
            nh darwin switch . -H darwin; \
        else \
            nh os switch .; \
        fi; \
    else \
        nh os switch .#{{host}} --target-host charana.c@{{host}} --elevation-strategy passwordless; \
    fi

# Home-manager only (standalone, for non-NixOS machines)
home user="itachi@popos":
    nh home switch .#{{user}}

# Dry build (eval only, no compilation)
build host:
    nh os build .#{{host}} --dry

# Format nix files
fmt:
    treefmt

# Update flake lock
update:
    nix flake update

# Check flake (eval all configs)
check:
    nix flake check

# Garbage collect - all profiles (needs sudo)
gc:
    sudo nh clean all
