# Just commands for nix-darwin operations
#
# This justfile provides convenient commands for managing nix-darwin configurations
# with automatic system detection based on hostname.

# Get current hostname and map to flake configuration
# Extract base hostname by removing all domain/subdomain suffixes
default_system := `hostname | cut -d. -f1`

# Default recipe - show available commands
default:
    @just --list

# Rebuild darwin system for current host
rebuild:
    sudo darwin-rebuild switch --flake .#{{default_system}}

# Build darwin system without switching (useful for testing)
build:
    darwin-rebuild build --flake .#{{default_system}}

# Check flake and build without switching
check:
    sudo darwin-rebuild check --flake .#{{default_system}}

# Rollback to previous generation
rollback:
    sudo darwin-rebuild rollback

# Show current system that would be used
show-system:
    @echo "Current system: {{default_system}}"

# Show system generations
generations:
    sudo darwin-rebuild --list-generations

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
