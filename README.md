[<img src="https://raw.githubusercontent.com/b4lisong/nix-config/refs/heads/main/_img/cirno_hexley_cosplay_simple_upscaled_nobg.png" width="200px" alt="logo" />](https://github.com/b4lisong/nix-config)

# b4lisong's nix-config

This repository provides a flake based configuration for managing macOS and future NixOS machines with [nix-darwin](https://github.com/nix-darwin/nix-darwin) and [home‑manager](https://github.com/nix-community/home-manager).

Heavily inspired by:
- [ryan4yin's nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons' nixos-config](https://github.com/dustinlyons/nixos-config)

This repository is under constant development!

## Overview

`flake.nix` declares the inputs for `nixpkgs`, `nix-darwin`, and `home-manager` and exposes two main outputs:

* **Darwin configurations** – created by `mkDarwinHost` and assembled from a set of modules.
* **Development shells** – a set of per-architecture `mkShell` environments containing tools such as `alejandra`, `pre-commit`, `statix`, and `deadnix`.

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
* `profiles/gui` – placeholder that currently imports the TUI profile.

Roles under `home/roles` are empty and can be used to group host specific packages later.

### Hosts

Each host directory contains two files:

* `system.nix` – system level configuration that imports the base modules and can override Homebrew packages or defaults.
* `home.nix` – Home Manager entry point that imports one of the profiles.

Currently only the `a2251` host is defined.

## Variables

Global settings are centralised in `variables/default.nix` and include the primary user, git identity, preferred editor and terminal along with host metadata.

## Using the flake

A typical rebuild on macOS looks like:

```bash
sudo darwin-rebuild switch --flake .#a2251
```

For editing or testing the configuration, a development shell can be started with:

```bash
nix develop
```

More manual setup notes live in `notes.md`.

