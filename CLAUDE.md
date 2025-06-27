# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

### System Rebuild
```bash
# Rebuild and switch the current Darwin system configuration
sudo darwin-rebuild switch --flake .#a2251

# For other hosts, use their hostname from variables/default.nix
sudo darwin-rebuild switch --flake .#<hostname>
```

### Development Environment
```bash
# Enter development shell with Nix tools
nix develop

# Format Nix code
alejandra .

# Lint Nix code 
statix check .

# Find unused Nix code
deadnix .

# Visualize Nix store dependencies
nix-tree
```

### Flake Operations
```bash
# Update flake inputs
nix flake update

# Show flake info
nix flake show

# Check flake
nix flake check
```

## Architecture Overview

This is a modular Nix configuration using flakes for macOS (nix-darwin) and future NixOS systems. The architecture follows a layered approach:

### Core Structure
- **flake.nix**: Main entry point defining inputs (nixpkgs, nix-darwin, home-manager) and outputs
- **variables/default.nix**: Centralized configuration values (user info, git settings, host metadata)
- **lib/modules.nix**: Helper functions, notably `scanPaths` for automatic module discovery

### System Layers
1. **Base Layer** (`modules/base.nix`): Common packages, fonts, and Nix settings for all systems
2. **Platform Layer** (`modules/darwin/`, `modules/nixos/`): Platform-specific configurations
3. **Host Layer** (`hosts/<hostname>/`): Per-host system and home configurations

### Home Manager Structure
- **Profiles**: Layered user environments
  - `profiles/base`: Core CLI tools and programs
  - `profiles/tui`: Additional terminal utilities (btop, gping, ncdu, yazi)
  - `profiles/gui`: Desktop applications (currently imports TUI)
  - `profiles/darwin`: macOS-specific profile with GUI apps
- **Modules**: Reusable components (`editors/vim.nix`, `shell/zsh.nix`, `terminal/kitty.nix`)
- **Roles**: Host-specific package groupings (`dev`, `personal`, `work`, `security`, `docker`)

### Key Integration Points
- Home Manager is integrated as a Darwin module, not standalone
- Both stable (`nixpkgs`) and unstable (`nixpkgs-unstable`) package sets are available
- The `mkDarwinHost` function in flake.nix orchestrates system assembly
- Host configurations inherit from base → platform → host-specific overrides

### Variable System
The centralized variables approach allows consistent configuration across:
- User identity and shell preferences
- Git configuration
- Host metadata (system architecture, descriptions)
- Common paths and preferences (editor, terminal, color scheme)

### Module Discovery
The `scanPaths` helper automatically imports .nix files and directories, reducing manual import management in module hierarchies.

## Current Hosts
- **a2251**: Personal MacBook Pro (Intel, x86_64-darwin) - primary development machine
- **sksm3**: Work MacBook (Apple Silicon, aarch64-darwin) - defined but not actively used
- **rpi4b**: Raspberry Pi 4B (aarch64-linux) - planned NixOS host