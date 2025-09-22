[<img src="https://raw.githubusercontent.com/b4lisong/nix-config/refs/heads/main/_img/cirno_hexley_cosplay_simple_upscaled_nobg.png" width="200px" alt="logo" />](https://github.com/b4lisong/nix-config)

# b4lisong's nix-config

This repository provides a flake based configuration for managing macOS and NixOS machines with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home‑manager](https://github.com/nix-community/home-manager). Includes specialized support for Raspberry Pi and embedded development.

Heavily inspired by:
- [ryan4yin's nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons' nixos-config](https://github.com/dustinlyons/nixos-config)

This repository is under constant development!

## Overview

`flake.nix` uses a composable architecture with automatic host discovery via [haumea](https://github.com/nix-community/haumea) and exposes three main outputs:

* **Darwin configurations** – automatically discovered from `outputs/{arch}/src/*.nix` and assembled from a layered set of modules for macOS systems.
* **NixOS configurations** – automatically discovered from `outputs/{arch}/src/*.nix` and assembled from a layered set of modules for Linux systems.
* **Development shells** – a set of per-architecture `mkShell` environments containing tools such as `alejandra`, `pre-commit`, `statix`, and `deadnix`.

The configuration supports both stable and bleeding-edge packages through dual nixpkgs inputs, with Home Manager integrated as a system module (Darwin or NixOS) rather than standalone. Hosts are organized by architecture and discovered automatically - no manual flake.nix editing required when adding new machines.

## Layout

```
outputs/      – architecture-based host auto-discovery
├── aarch64-darwin/src/    – Apple Silicon macOS hosts
├── x86_64-darwin/src/     – Intel macOS hosts
├── aarch64-linux/src/     – ARM64 Linux hosts
└── x86_64-linux/src/      – x86_64 Linux hosts
modules/      – system level modules shared between hosts
home/         – home-manager modules, profiles and roles
hosts/        – per-host system and user configuration
├── darwin-*/             – macOS host configurations
└── linux-*/              – Linux host configurations
variables/    – shared variables like username, git settings, host info
lib/          – helper library functions and system builders
```

### Modules

* `modules/base.nix` defines common packages, fonts and Nix settings for all systems.
* `modules/darwin` extends the base configuration with macOS specific options and a default Homebrew setup.
* `modules/nixos` provides comprehensive NixOS system configuration with security hardening, optimization, and platform-specific services.

### Home Manager

Within `home/` there are reusable modules for the shell and editor as well as layered profiles:

* `profiles/base` – base set of CLI tools and programs.
* `profiles/tui` – additional TUI utilities (btop, gping, ncdu, yazi, etc.).
* `profiles/gui` – desktop applications, imports TUI profile as foundation.
* `profiles/darwin` – complete macOS profile with GUI apps and Darwin-specific integrations.

Roles under `home/roles` group packages by purpose:
* `roles/dev` – development tools (neovim, nodejs, claude-code)
* `roles/embedded` – hardware development tools (serial communication, I2C utilities, embedded monitoring)
* `roles/personal`, `roles/work`, `roles/security`, `roles/docker` – organized by use case

### Hosts

Hosts are automatically discovered from `outputs/{architecture}/src/*.nix` files. Each host directory in `hosts/` contains:

* `default.nix` – system level configuration (formerly `system.nix`)
* `home.nix` – Home Manager entry point that imports one of the profiles
* Additional files as needed (`hardware-configuration.nix`, `disks.nix`, etc.)

Currently five hosts are defined:

**macOS (Darwin):**
* `darwin-a2251` (x86_64-darwin) – Personal MacBook Pro (Intel) - actively used
* `darwin-sksm3` (aarch64-darwin) – Work MacBook (Apple Silicon) - actively used

**Linux (NixOS):**
* `linux-rpi4b` (aarch64-linux) – Raspberry Pi 4B with embedded development environment
* `linux-x1c4g` (x86_64-linux) – ThinkPad X1 Carbon 4th Gen development machine
* `linux-nixvm` (aarch64-linux) – NixOS VM for testing and development

See [hosts/README.md](hosts/README.md) for detailed instructions on adding new hosts.

## Variables

Global settings are centralised in `variables/default.nix` and include the primary user, git identity, preferred editor and terminal along with host metadata.

## Using the flake

### System Management

#### Multi-Platform Just Commands (Recommended)
This configuration includes Just commands that automatically detect your platform and use the appropriate rebuild tool:

```bash
just rebuild          # Auto-detects platform (darwin-rebuild or nixos-rebuild)
just build            # Build without switching  
just check            # Validate configuration
just rollback         # Revert to previous generation
just show-platform    # Show detected platform and hostname
```

#### Direct Commands

**macOS (Darwin):**
```bash
sudo darwin-rebuild switch --flake .#darwin-a2251
sudo darwin-rebuild switch --flake .#darwin-sksm3
```

**NixOS (Linux):**
```bash
sudo nixos-rebuild switch --flake .#linux-rpi4b
sudo nixos-rebuild switch --flake .#linux-x1c4g
sudo nixos-rebuild switch --flake .#linux-nixvm
```

**List Available Hosts:**
```bash
nix eval .#darwinConfigurations --apply 'builtins.attrNames'  # macOS hosts
nix eval .#nixosConfigurations --apply 'builtins.attrNames'   # Linux hosts
```

#### Raspberry Pi Setup
For initial deployment to a Raspberry Pi 4B:

```bash
# Build SD card image (cross-compile from macOS)
nix build .#nixosConfigurations.linux-rpi4b.config.system.build.sdImage

# Flash image to SD card and boot Pi
# SSH to Pi (ensure SSH key is configured in hosts/linux-rpi4b/default.nix)
ssh pi@rpi4b.local

# On Pi: Deploy configuration
sudo nixos-rebuild switch --flake github:b4lisong/nix-config#linux-rpi4b
```

### Development Workflow
Enter development shell with Nix tools:

```bash
nix develop
```

Format, lint, and check code:

```bash
alejandra .          # Format Nix code
statix check .       # Lint Nix code
deadnix .            # Find unused code
nix flake check      # Validate flake
```

Update dependencies:

```bash
nix flake update     # Update all inputs
```

More manual setup notes live in `notes.md`.

