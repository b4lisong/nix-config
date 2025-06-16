# Proposed Modular Structure for nix-config

This document outlines how to refactor the current monolithic `flake.nix` into a hierarchical layout inspired by `ryan4yin/nix-config`.

## 1. Directory Layout

```
.
├── flake.nix              # entry point
├── lib/                   # helper functions (e.g. scanPaths)
│   └── modules.nix
├── variables/             # global constants (previous variables.nix)
│   └── default.nix
├── modules/               # system-level modules
│   ├── base.nix           # common to all systems
│   ├── nixos/
│   │   └── default.nix
│   └── darwin/
│       └── default.nix
├── home/
│   ├── profiles/          # user-level inheritance hierarchy
│   │   ├── base/
│   │   │   └── default.nix
│   │   ├── tui/
│   │   │   └── default.nix
│   │   └── gui/
│   │       └── default.nix
│   ├── roles/             # optional feature sets
│   │   ├── security/
│   │   ├── docker/
│   │   ├── dev/
│   │   ├── personal/
│   │   └── work/
│   └── modules/           # per-application configs
│       └── editors/
│           └── vim.nix
├── hosts/                 # host specific modules (system + home)
│   └── <hostname>/
│       ├── system.nix
│       └── home.nix
└── ...
```

## 2. Module Inheritance

 - **`profiles/base`** – core packages such as `git` and `vim`. The actual Home Manager configuration for each program lives under `home/modules/` (e.g. `modules/editors/vim.nix`) and is imported here so that `tui` and individual hosts can extend or override the settings.
- **`profiles/tui`** – imports `base` and adds TUI oriented utilities for development (`lazygit`, `zoxide`, `starship`, etc.)
- **`profiles/gui`** – imports `tui` and adds GUI packages. On NixOS this will include the window manager and graphical applications; on macOS the GUI applications can be installed via Homebrew.
- **`home/modules`** – per-application Home Manager modules shared across profiles. Example: `modules/editors/vim.nix` defines Vim options imported by `profiles/base`.
- **`modules/base.nix`** – configuration shared by all systems.
- **`modules/nixos`** – defaults imported by every NixOS host.
- **`modules/darwin`** – defaults for all macOS hosts.
Host `home.nix` files import the appropriate profile(s) plus any combination of role modules, allowing each host to be configured from a menu of features. Hosts may extend or override modules from `home/modules` to customize specific applications.
Role modules are optional collections of packages/configs that can be mixed into hosts.
Examples:

- **`role/security`** – penetration testing tools (nmap, wireshark, metasploit, etc.).
- **`role/docker`** – docker, docker-compose and related utilities.
- **`role/dev`** – IDEs, runtimes, libraries and debuggers for software development.
- **`role/personal`** – multimedia, gaming or music production tools.
- **`role/work`** – corporate packages or policies used on work machines.

### Avoiding Duplicate Definitions

Profiles and roles may both include the same application module.  Define options
with `lib.mkDefault` and assemble lists with `lib.mkMerge` or `lib.optional` so
multiple imports merge cleanly instead of conflicting.  Hosts can override any
defaults with `lib.mkOverride` in their own modules.  This approach ensures that
adding a role like `dev` or `personal` on top of the TUI profile will not fail
even if they both reference the same application configuration.

These role modules combine with profiles to create per-host configurations. For instance, a personal macOS host might import the TUI profile plus `security`, `docker`, `dev`, `personal` and `work`; a work macOS host might omit the `personal` role.

## 3. Host Composition

Every host composes system modules (`modules/base.nix` along with `modules/nixos` or `modules/darwin`) with user profiles and any desired role modules. This keeps shared configuration centralized while letting each host pick features from a menu. Because application configurations are modular, a host can also override or extend them in its `home.nix`. For example, a macOS workstation could import the TUI profile together with the `dev` and `docker` roles plus a host-specific `home.nix`.

## 4. Updated `flake.nix`

The flake will expose system configurations and development shells similar to the existing monolithic file but pulls modules from `hosts/` and `home/`. A simplified outline:

```nix
{
  inputs = { ... };
  outputs = inputs@{ self, nixpkgs, home-manager, darwin, ... }:
    let
      lib = import ./lib/modules.nix { inherit (nixpkgs) lib; };
      vars = import ./variables { inherit (nixpkgs) lib; };
      mkNixosHost = hostName: system: {
        modules = [
          ./modules/base.nix
          ./modules/nixos
          ./hosts/${hostName}/system.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.users.${vars.user.username} = {
              imports = [ ./hosts/${hostName}/home.nix ];
            };
          }
        ];
      };
      mkDarwinHost = hostName: {
        modules = [
          ./modules/base.nix
          ./modules/darwin
          ./hosts/${hostName}/system.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.users.${vars.user.username}.imports = [
              ./hosts/${hostName}/home.nix
            ];
          }
        ];
      };
    in {
      nixosConfigurations = {
        # Example NixOS host
        myHost = nixpkgs.lib.nixosSystem (mkNixosHost "myHost" "x86_64-linux");
      };
      darwinConfigurations = {
        # Example macOS host
        myMac = darwin.lib.darwinSystem (mkDarwinHost "myMac");
      };
    }
}
```

## 5. Development Environment

The flake defines a cross-platform development shell with common Nix tooling.
`direnv` loads this shell automatically via `.envrc` so simply entering the
repository provides a ready-to-use environment.

```bash
direnv allow   # trust the project once
# subsequent directory changes automatically run `nix develop`
```

The shell exposes formatters and linters like `nixpkgs-fmt`, `statix` and
`deadnix`, making it easy to maintain the configuration on macOS and Linux.

## 6. Migration Steps

1. Create the directory structure from section 1.
2. Move the shared values from `variables.nix` into `variables/default.nix`.
3. Implement the `lib/modules.nix` helper (scanPaths) copied from `ryan4yin/nix-config`.
4. Split current user-level configuration from `flake.nix` into modules under `home/profiles/base`, `tui`, and `gui`.
5. For each host, create `hosts/<hostname>/system.nix` and `home.nix`. Start by copying the existing system configuration into `system.nix` and the Home Manager part into `home.nix`.
6. Add optional modules under `home/roles/` for security auditing, docker hosting, developer tools, personal usage, and import them in the relevant host `home.nix`.
7. Update `flake.nix` to build hosts using the new module layout.

Following this plan yields a modular inheritance-based configuration that matches the base/TUI/GUI separation at the user level while keeping system-level definitions host specific.
