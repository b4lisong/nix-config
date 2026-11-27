# AGENTS.md

Instructions for agents working in this Nix configuration repository (nix-darwin and NixOS hosts, Home Manager as a module).

## Repository Layout

```
flake.nix
  -> outputs/default.nix                   (specialArgs, merges all architectures)
  -> outputs/<arch>/default.nix            (haumea auto-discovers src/*.nix)
  -> outputs/<arch>/src/<name>.nix         (one file per host)
  -> mylib.macosSystem / mylib.nixosSystem (lib/)
  -> system modules + Home Manager module
  -> hosts/<platform>-<name>/home.nix -> home/profiles + home/roles
```

Each host is registered by a file in `outputs/<arch>/src/`. That file sets the configuration name (the `.#<name>` flake target, e.g. `a2251`, `nas`) and lists the host's system and Home Manager modules. Host directories are prefixed by platform: `hosts/darwin-<name>/`, `hosts/linux-<name>/`.

| Layer    | Location                                | Purpose                                            |
|----------|-----------------------------------------|----------------------------------------------------|
| Base     | `modules/base.nix`                      | Core packages, fonts, Nix settings                 |
| Platform | `modules/darwin/`, `modules/nixos/`     | Platform-specific system configuration             |
| Host     | `hosts/<platform>-<name>/default.nix`   | Machine-specific system configuration              |
| Profile  | `home/profiles/`                        | User environments (base, tui, gui, darwin)         |
| Role     | `home/roles/`                           | Purpose-based packages (dev, docker, embedded, personal, security, work) |
| Host HM  | `hosts/<platform>-<name>/home.nix`      | Selects profiles and roles; host-specific user overrides |

User, git, and host metadata live in `variables/default.nix` (available as `myvars` via `specialArgs`). Use those values instead of hardcoding usernames, home directories, or hostnames.

## Packages

Two package sets are available in every module via `specialArgs`:

- `pkgs` - stable nixpkgs. Default choice, and required for core system tools.
- `pkgs-unstable` - nixpkgs-unstable. Use for fast-moving development tools and when the newest version matters.

On `x86_64-darwin` (host `a2251`), `pkgs-unstable` is sourced from stable nixpkgs because unstable dropped the platform. See [docs/x86_64-darwin-eol.md](docs/x86_64-darwin-eol.md).

**Verify before use.** Package names and module options differ between nixpkgs and Home Manager versions, so do not rely on memory or on documentation for a different release:

- Packages: confirm with `nix search nixpkgs <name>` that the package exists in the pinned version.
- Home Manager / NixOS / nix-darwin options: confirm the option exists for the version pinned in `flake.lock`.

If a package or option does not exist, find the correct alternative rather than guessing.

## Nix Conventions

- Prefer `lib.mkDefault` for values hosts may override; reach for `lib.mkForce` only as a last resort.
- Use flake inputs or hashed fetchers (`fetchFromGitHub`, etc.); no `builtins.fetchurl` or `fetchTarball` without a hash.
- Use module function arguments (`{pkgs, lib, ...}:`); no `import <nixpkgs> {}` in modules.
- Reference store paths through packages (`${pkgs.foo}`), never as literal `/nix/store/...` paths.
- Keep `with pkgs;` to small scopes such as a single package list.

## Module Merging and Package Overrides

The module system merges definitions; a host does not simply override what it imports.

- **Lists concatenate.** `home.packages` defined in a role and again in a host yields both sets of packages.
- **Single values resolve by priority** (lower wins): `lib.mkForce` (50) beats a plain definition (100), which beats `lib.mkDefault` (1000). Two definitions at the same priority with different values are an error.
- **Priorities apply to a whole definition, not to items in a list.** `(lib.mkDefault pkgs.nodejs)` inside a list has no effect.

### The List Merging Trap

Adding a package in a host does **not** replace a similar package from a role:

```nix
# home/roles/dev/default.nix
home.packages = [pkgs-unstable.nodejs_latest pkgs.gh];

# hosts/<platform>-<name>/home.nix
home.packages = [pkgs.nodejs];  # Intended as an override

# Result: BOTH nodejs packages are installed
```

### Changing a Package for Some Hosts

**Preferred: change the default in the role, opt in per host.** Put the conservative choice in the shared role and add the alternative only in the hosts that want it. Simple and low maintenance; the opt-in hosts carry both packages.

```nix
# home/roles/dev/default.nix
home.packages = [pkgs.nodejs pkgs.gh];

# Host that wants the newer version
home.packages = [pkgs-unstable.nodejs_latest];
```

**Alternative: replace the whole list.** Only when duplication is unacceptable. The host must then maintain the complete list, so do not use this to change a single package.

```nix
# Shared role
home.packages = lib.mkDefault [pkgs-unstable.nodejs_latest pkgs.gh];

# Host
home.packages = lib.mkForce [pkgs.nodejs pkgs.gh];
```

## Testing and Validation

**Flakes only see files tracked by Git.** Run `git add` on new files before any `nix` or rebuild command, or they will be invisible to evaluation. Staging is enough; a commit is not required.

**`nix flake check` must pass before every commit that touches `.nix` files or `flake.lock`, and warnings are blocking.** Commits that change only docs or other non-Nix files do not need it. Treat every warning as an error and fix it before committing: renamed options, deprecated APIs, and defaults slated for removal should be migrated immediately. The one standing exception is the `x86_64-darwin` end-of-life warning documented in [docs/x86_64-darwin-eol.md](docs/x86_64-darwin-eol.md).

Validate `.nix` changes against the actual system configuration, not just the flake:

| Step | nix-darwin (macOS)                           | NixOS (Linux)                              | Purpose                        |
|------|----------------------------------------------|--------------------------------------------|--------------------------------|
| 1    | `nix flake check`                            | `nix flake check`                          | Fast flake-wide evaluation     |
| 2    | `sudo darwin-rebuild check --flake .#<name>` | `nixos-rebuild dry-build --flake .#<name>` | Full system validation         |
| 3    | `darwin-rebuild build --flake .#<name>`      | `nixos-rebuild build --flake .#<name>`     | Build without applying (optional) |

`nixos-rebuild` has no `check` action; `dry-build` is the closest equivalent. `nix flake check` only evaluates the current platform unless `--all-systems` is passed.

Formatting and linting (`alejandra`, `statix`, `deadnix`) run as pre-commit hooks on `.nix` files and are available in `nix develop`. Do not run them on non-Nix files.

## Committing

Commit and push directly to `main` unless asked to use a branch. No CI runs on pull requests; `promote-deploy.yml` validates each push to `main` before advancing the `deploy` branch that `oci-nixos` and `nas` pull, so a broken push blocks deployment to both hosts until fixed.

## Rebuilding

Home Manager runs as a nix-darwin/NixOS module. **Never use or suggest `home-manager switch`.**

```bash
# macOS
sudo darwin-rebuild switch --flake .#<name>
sudo darwin-rebuild --rollback

# NixOS
sudo nixos-rebuild switch --flake .#<name>
sudo nixos-rebuild switch --rollback
```

`rollback` is not a subcommand of either tool; it is the `--rollback` flag. The `justfile` wraps these for the current host: `just check`, `just build`, `just rebuild`, `just rollback`.
