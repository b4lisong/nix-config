[<img src="https://raw.githubusercontent.com/b4lisong/nix-config/refs/heads/main/_img/cirno_hexley_cosplay_simple_upscaled_nobg.png" width="200px" alt="logo" />](https://github.com/b4lisong/nix-config)

# b4lisong's nix-config

This repository provides a flake based configuration for managing macOS and future NixOS machines with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home‑manager](https://github.com/nix-community/home-manager).

Heavily inspired by:
- [ryan4yin's nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons' nixos-config](https://github.com/dustinlyons/nixos-config)

This repository is under constant development!

## Overview

`flake.nix` declares the inputs for `nixpkgs` (stable), `nixpkgs-unstable`, `nix-darwin`, and `home-manager` and exposes two main outputs:

* **Darwin configurations** – created by `mkDarwinHost` and assembled from a layered set of modules.
* **Development shells** – a set of per-architecture `mkShell` environments containing tools such as `alejandra`, `pre-commit`, `statix`, and `deadnix`.

The configuration supports both stable and bleeding-edge packages through dual nixpkgs inputs, with Home Manager integrated as a Darwin module rather than standalone.

## Layout

```
modules/      – system level modules shared between hosts
home/         – home-manager modules, profiles and roles
hosts/        – per-host system and user configuration
variables/    – shared variables like username, git settings, host info
lib/          – helper library functions
```

### Modules

* `modules/base.nix` defines common packages, fonts and Nix settings for all systems.
* `modules/darwin` extends the base configuration with macOS specific options and a default Homebrew setup.
* `modules/nixos` is currently a stub for future NixOS support.

### Home Manager

Within `home/` there are reusable modules for the shell and editor as well as layered profiles:

* `profiles/base` – base set of CLI tools and programs.
* `profiles/tui` – additional TUI utilities (btop, gping, ncdu, yazi, etc.).
* `profiles/gui` – desktop applications, imports TUI profile as foundation.
* `profiles/darwin` – complete macOS profile with GUI apps and Darwin-specific integrations.

Roles under `home/roles` group packages by purpose:
* `roles/dev` – development tools (neovim, nodejs, claude-code)
* `roles/personal`, `roles/work`, `roles/security`, `roles/docker` – organized by use case

### Hosts

Each host directory contains two files:

* `system.nix` – system level configuration that imports the base modules and can override Homebrew packages or defaults.
* `home.nix` – Home Manager entry point that imports one of the profiles.

Currently three hosts are defined:
* `a2251` – Personal MacBook Pro (Intel, x86_64-darwin) - actively used
* `sksm3` – Work MacBook (Apple Silicon, aarch64-darwin) - defined but inactive
* `rpi4b` – Raspberry Pi 4B (aarch64-linux) - planned NixOS host

## Variables

Global settings are centralised in `variables/default.nix` and include the primary user, git identity, preferred editor and terminal along with host metadata.

## Using the flake

### System Management
A typical rebuild on macOS:

```bash
sudo darwin-rebuild switch --flake .#a2251
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

