# Just commands for multi-platform Nix operations
#
# This justfile provides convenient commands for managing both nix-darwin (macOS)
# and NixOS (Linux) configurations with automatic platform and hostname detection.

# Get current hostname and map to flake configuration
# Extract base hostname by removing all domain/subdomain suffixes
default_system := `hostname | cut -d. -f1`

# Detect current operating system for platform-specific commands
os_type := `uname -s`

# Default recipe - show available commands
default:
    @just --list

# Rebuild system for current host (auto-detects Darwin vs NixOS)
rebuild:
    #!/usr/bin/env bash
    if [ "{{os_type}}" = "Darwin" ]; then
        sudo darwin-rebuild switch --flake .#{{default_system}}
    else
        sudo nixos-rebuild switch --flake .#{{default_system}}
    fi

# Build system without switching (auto-detects Darwin vs NixOS)
build:
    #!/usr/bin/env bash
    if [ "{{os_type}}" = "Darwin" ]; then
        darwin-rebuild build --flake .#{{default_system}}
    else
        nixos-rebuild build --flake .#{{default_system}}
    fi

# Check flake and build without switching (auto-detects Darwin vs NixOS)
check:
    #!/usr/bin/env bash
    if [ "{{os_type}}" = "Darwin" ]; then
        sudo darwin-rebuild check --flake .#{{default_system}}
    else
        sudo nixos-rebuild dry-build --flake .#{{default_system}}
    fi

# Rollback to previous generation (auto-detects Darwin vs NixOS)
rollback:
    #!/usr/bin/env bash
    if [ "{{os_type}}" = "Darwin" ]; then
        sudo darwin-rebuild rollback
    else
        sudo nixos-rebuild switch --rollback
    fi

# Show current system that would be used
show-system:
    @echo "Current system: {{default_system}}"

# Show detected platform and hostname information
show-platform:
    @echo "Platform: {{os_type}}"
    @echo "Hostname: {{default_system}}" 
    @echo "Full hostname: `hostname`"
    @if [ "{{os_type}}" = "Darwin" ]; then echo "Using: darwin-rebuild commands"; else echo "Using: nixos-rebuild commands"; fi

# Show system generations (auto-detects Darwin vs NixOS)
generations:
    #!/usr/bin/env bash
    if [ "{{os_type}}" = "Darwin" ]; then
        sudo darwin-rebuild --list-generations
    else
        sudo nixos-rebuild list-generations
    fi

# Collect garbage (clean up old generations)
gc:
    sudo nix-collect-garbage -d

# Update flake inputs and rebuild
update:
    nix flake update
    just rebuild

# Format nix files
fmt:
    alejandra .

# Check nix files for issues
lint:
    statix check .
    deadnix .

# Format disks with disko
format DISKS_FILE:
    sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount {{DISKS_FILE}}
