# AGENTS.md

Instructions for agents working in this Nix configuration repository.

## Contents

1. [Repository Architecture](#repository-architecture)
2. [Development Environment](#development-environment)
3. [Package Management](#package-management)
4. [Nix Coding Standards](#nix-coding-standards)
5. [Module Merging and Package Overrides](#module-merging-and-package-overrides)
6. [Testing and Validation](#testing-and-validation)
7. [Rebuilding Systems](#rebuilding-systems)

---

## Repository Architecture

### Evaluation Flow

```
flake.nix
  -> outputs/default.nix                  (specialArgs, merges all architectures)
  -> outputs/<arch>/default.nix           (haumea auto-discovers src/*.nix)
  -> outputs/<arch>/src/<name>.nix        (one file per host)
  -> mylib.macosSystem / mylib.nixosSystem (lib/)
  -> system modules + Home Manager module
  -> hosts/<platform>-<name>/home.nix -> home/profiles + home/roles
```

Each host is defined by a file in `outputs/<arch>/src/` (architectures: `x86_64-darwin`, `aarch64-darwin`, `x86_64-linux`, `aarch64-linux`). That file sets the configuration name (the `.#<name>` flake target, e.g. `a2251`) and lists its system modules and Home Manager modules. Host directories are prefixed by platform: `hosts/darwin-<name>/`, `hosts/linux-<name>/`.

### Configuration Layers

Applied bottom-to-top:

| # | Layer    | Location                                 | Purpose                                                  |
|---|----------|------------------------------------------|----------------------------------------------------------|
| 1 | Base     | `modules/base.nix`                       | Core packages, fonts, Nix settings                       |
| 2 | Platform | `modules/darwin/`, `modules/nixos/`      | Platform-specific system configuration                   |
| 3 | Host     | `hosts/<platform>-<name>/default.nix`    | Machine-specific system configuration and overrides      |
| 4 | Profile  | `home/profiles/`                         | User environments (base, tui, gui, darwin)               |
| 5 | Role     | `home/roles/`                            | Purpose-based packages (dev, docker, embedded, personal, security, work) |

The host's `home.nix` selects which profiles and roles apply.

### File Organization

| Scope              | Location                                                        |
|--------------------|-----------------------------------------------------------------|
| Host registration  | `outputs/<arch>/src/<name>.nix`                                 |
| System builders    | `lib/macosSystem.nix`, `lib/nixosSystem.nix`                    |
| System-level       | `modules/`, `hosts/<platform>-<name>/default.nix`               |
| User-level         | `home/profiles/`, `home/roles/`, `hosts/<platform>-<name>/home.nix` |
| Variables          | `variables/default.nix` (centralized configuration)             |

### Centralized Variables

Use values from `variables/` instead of hardcoding them.

```nix
# Good - use centralized variables
let
  vars = import ../../variables;
in {
  home.homeDirectory = "/Users/${vars.user.username}";
  programs.git = {
    inherit (vars.git) userName userEmail;
  };
}

# Bad - hardcoded values
home.homeDirectory = "/Users/balisong";
```

### Dual Package System

- **`nixpkgs`**: stable packages for reliability
- **`nixpkgs-unstable`**: bleeding-edge packages for development tools
- Both are available via `specialArgs` throughout the configuration

See [Stable vs Unstable](#stable-vs-unstable) for selection guidance.

---

## Development Environment

Enter the development shell to get the quality tools:

```bash
nix develop
```

| Tool        | Purpose                                  | Required |
|-------------|------------------------------------------|----------|
| `alejandra` | Nix code formatter                       | Yes      |
| `statix`    | Nix linter                               | Yes      |
| `deadnix`   | Dead code detection                      | Yes      |
| `nil`       | Nix language server (editor integration) | No       |

### Pre-commit Hooks

Pre-commit hooks are **mandatory and blocking**. They run automatically on commit for `.nix` files:

```bash
alejandra .        # Format all .nix files
statix check .     # Lint all .nix files
deadnix --fail .   # Check for dead code
```

### File Type to Tool Mapping

Always match tools to the correct file types. **Never apply Nix tools to non-Nix files.**

| File Type | Extensions | Formatter   | Linter   | When to Validate         |
|-----------|------------|-------------|----------|--------------------------|
| Nix       | `*.nix`    | `alejandra` | `statix` | Always                   |
| Markdown  | `*.md`     | (manual)    | (none)   | Never                    |
| All files | `*`        | (none)      | (none)   | Always (generic cleanup) |

```bash
alejandra *.nix          # Correct
alejandra AGENTS.md      # Wrong
statix check README.md   # Wrong
```

---

## Package Management

### Package Verification (Mandatory)

Always verify packages against the **exact** nixpkgs version in use. If a package does not exist, find the correct alternative or a different approach. This is a blocking requirement.

Before adding any package:

1. Run `nix search nixpkgs <package-name>`
2. Verify the package exists in the current nixpkgs version
3. Check compatibility with this setup
4. Proceed only once verified - no assumptions

### Home Manager Option Verification

1. **Check `flake.lock`** to identify the Home Manager commit/version
2. **Use version-specific docs**:
   - https://mynixos.com/home-manager/options/ (latest)
   - https://nix-community.github.io/home-manager/options.html (specific releases)
3. **Search for the exact option name**
4. **Confirm the option exists in this version**
5. **Document the source**: include the documentation URL in a comment if the option is complex

**Forbidden:**

- Using packages without verification
- Assuming packages exist across all versions
- Using documentation from a different version

### Stable vs Unstable

| Use stable (`pkgs`) for                         | Use unstable (`pkgs-unstable`) for              |
|-------------------------------------------------|-------------------------------------------------|
| Core system tools (editors, shells, utilities)  | Rapidly evolving development tools              |
| Well-established development tools              | Latest language versions (Node.js, Python, Go)  |
| Packages where stability is crucial             | Cutting-edge CLI tools                          |
|                                                 | Packages where the newest features matter       |

```nix
home.packages = with pkgs; [
  # Stable - core tools
  git
  vim
  curl
] ++ [
  # Unstable - latest features
  pkgs-unstable.nodejs_latest
  pkgs-unstable.claude-code
];
```

---

## Nix Coding Standards

### Required Patterns

- `lib.mkDefault` for host-overridable defaults
- `lib.mkIf` for conditional configuration
- `lib.mkMerge` for combining attribute sets
- Proper function signatures: `{pkgs, lib, ...}:`
- `inherit` for passing values: `inherit (vars.git) userName;`
- `let ... in` for local variable scoping
- String interpolation: `"${vars.user.username}"`

### Forbidden Patterns

- `lib.mkForce` unless absolutely necessary - try `lib.mkDefault` first
- Hardcoded store paths - use `${pkgs.package}` references
- `fetchTarball` without a hash - use flake inputs instead
- `builtins.fetchurl` - use proper fetchers (`fetchFromGitHub`, etc.)
- `with pkgs;` in large scopes - prefer explicit package references
- Recursive attribute sets (`rec`) without clear necessity
- `import <nixpkgs> {}` in modules - use function arguments
- Mixed tabs and spaces - use 2-space indentation

---

## Module Merging and Package Overrides

Understanding how the module system merges lists versus single values is essential for managing packages across roles and hosts.

**Key insight:** the Nix module system is designed for **composability through merging**, not **replacement through inheritance**.

| Incorrect mental model                                | Correct mental model                                                    |
|-------------------------------------------------------|-------------------------------------------------------------------------|
| Host configurations override imported configurations  | Definitions are merged by type: lists concatenate, values replace       |
| `lib.mkDefault` makes individual packages overridable | `lib.mkDefault`/`lib.mkForce` apply to whole definitions, not list items |
| Adding a package replaces a similar package           | Replacement vs addition requires an explicit strategy                   |

### Merge Semantics

**Lists are always concatenated:**

```nix
# Module 1: home.packages = [A, B]
# Module 2: home.packages = [C]
# Result:   home.packages = [A, B, C]
```

**Single values are replaced by priority:**

```nix
# Module 1: programs.git.userName = "default"
# Module 2: programs.git.userName = "override"
# Result:   programs.git.userName = "override"
```

**Priority with `lib.mkDefault` / `lib.mkForce`** (lower number wins):

```nix
# Module 1: programs.git.userName = lib.mkDefault "default"  # Priority 1000
# Module 2: programs.git.userName = "override"               # Priority 100
# Result:   programs.git.userName = "override"

# Module 1: programs.git.userName = lib.mkDefault "default"  # Priority 1000
# Module 2: programs.git.userName = lib.mkForce "override"   # Priority 50
# Result:   programs.git.userName = "override"               # mkForce always wins
```

### The List Merging Trap

The most common mistake: adding a package to `home.packages` in a host **adds** it; it does **not** replace a package from an imported role.

```nix
# home/roles/dev/default.nix
home.packages = [
  pkgs-unstable.nodejs_latest
  pkgs.gh
];

# hosts/personal/home.nix
home.packages = [
  pkgs.nodejs  # Intended to "override" nodejs_latest
];

# Result: BOTH nodejs packages are installed
```

### Override Patterns

#### Pattern 1: Change Default + Host Addition (Recommended)

Different package versions per host, accepting temporary duplication.

```nix
# Shared role (home/roles/dev/default.nix)
home.packages = [
  nodejs  # Stable as the safe default for all hosts
  pkgs.gh
];

# Host needing bleeding-edge (hosts/personal/home.nix)
home.packages = [
  pkgs-unstable.nodejs_latest
];

# Result:
# - Personal machine: nodejs + nodejs_latest (acceptable temporary duplication)
# - Work machines: nodejs only
```

- **Advantages:** simple, low maintenance, safe defaults
- **Trade-offs:** temporary package duplication on override hosts

Use when:

- A quick workaround for a broken package is needed
- Safe defaults with opt-in bleeding-edge are wanted
- Temporary duplication is acceptable
- Low maintenance overhead is the priority

#### Pattern 2: Complete List Override with `lib.mkForce`

Precise control, at the cost of maintaining full package lists.

```nix
# Shared role
home.packages = lib.mkDefault [
  pkgs-unstable.nodejs_latest
  pkgs.gh
];

# Conservative host
home.packages = lib.mkForce [
  pkgs.nodejs  # Stable version
  pkgs.gh      # Every other package must be duplicated
];

# Result: host gets exactly these packages, no merging
```

- **Advantages:** precise control, no duplication
- **Trade-offs:** complete package lists must be maintained per host

Use when:

- Precise control over exact packages is required
- No package duplication is acceptable
- Maintaining complete package lists is acceptable
- Only a few hosts need overrides

#### Pattern 3: Conditional Package Selection

Centralized logic based on host characteristics.

```nix
# Shared role
home.packages = [
  (if vars.hosts.${hostName}.description == "Work MacBook"
   then pkgs.nodejs
   else pkgs-unstable.nodejs_latest)
  pkgs.gh
];
```

- **Advantages:** centralized logic, no duplication
- **Trade-offs:** requires passing host context, more complex

Use when:

- Complex decision logic is needed
- Many hosts have different requirements
- Centralized package management is wanted
- Host context can be passed to modules

### Worked Example: Unstable nodejs Build Failure

**Problem:** `pkgs-unstable.nodePackages_latest.nodejs` failed to build
([NixOS/nixpkgs#423244](https://github.com/NixOS/nixpkgs/issues/423244)).

**Wrong approach** - adds a second nodejs instead of replacing:

```nix
# hosts/work/home.nix
home.packages = [
  pkgs.nodejs
];
# Result: both nodejs versions installed
```

**Correct approach** - change the default in the role (Pattern 1), opt in per host:

```nix
# home/roles/dev/default.nix
home.packages = [
  # Revert to unstable nodejs once https://github.com/NixOS/nixpkgs/issues/423244 is resolved
  nodejs
];

# hosts/personal/home.nix
home.packages = [
  pkgs-unstable.nodePackages_latest.nodejs
];
# Result: work machines get stable; personal gets both (acceptable temporary state)
```

### Common Mistakes

**Wrapping individual list items in `lib.mkDefault`** - does nothing useful; priorities apply to the whole definition, not items within a list:

```nix
home.packages = [
  (lib.mkDefault pkgs.nodejs)  # No effect
  pkgs.gh
];
```

**Using `lib.mkForce` to change a single package** - forces maintenance of the entire list:

```nix
home.packages = lib.mkForce [
  pkgs.nodejs  # The one package you wanted to change
  pkgs.gh      # Now every other package must be maintained here
  pkgs.curl
  # ...
];
```

---

## Testing and Validation

### Git State

Nix flakes only see files tracked by Git. Before running `nix flake check`, `just check`, or any rebuild command:

- **Stage all changes** with `git add .` - untracked files are invisible to the flake
- **Test after each logical change** - do not batch multiple features
- **Commit with descriptive messages** documenting what is being tested or fixed

### Warnings Are Blocking

All warnings from `nix flake check` are treated as errors and must be fixed immediately.

- Do not ignore warnings or defer them to later cleanup
- Do not commit code that produces warnings
- Fix all warnings before proceeding with other work

| Warning text                     | Action                                      |
|----------------------------------|---------------------------------------------|
| `has been renamed to`            | Update to the new option name               |
| `will be removed in the future`  | Migrate to the new API                      |
| `default values will be removed` | Explicitly configure the values you need    |

Deprecation warnings indicate APIs that will break in future releases; evaluation warnings indicate configuration issues.

### Test Hierarchy

Always test the actual system configuration. Replace `<name>` with the configuration name from `outputs/<arch>/src/<name>.nix` (e.g. `a2251`, `nas`).

| Step | nix-darwin (macOS)                           | NixOS (Linux)                                | Purpose                                              |
|------|----------------------------------------------|----------------------------------------------|------------------------------------------------------|
| 1    | `nix flake check`                            | `nix flake check`                            | Fast flake structure/syntax validation               |
| 2    | `sudo darwin-rebuild check --flake .#<name>` | `nixos-rebuild dry-build --flake .#<name>`   | Full system validation (required for `.nix` changes) |
| 3    | `darwin-rebuild build --flake .#<name>`      | `nixos-rebuild build --flake .#<name>`       | Build without applying (optional)                    |

`nixos-rebuild` has no `check` action; `dry-build` is the closest equivalent.

macOS example:

```bash
# 0. Stage and commit changes
git add .
git commit -m "feat: describe your changes"

# 1. Quick flake validation
nix flake check

# 2. Full system validation
sudo darwin-rebuild check --flake .#a2251

# 3. Build without applying (optional)
darwin-rebuild build --flake .#a2251

# If the build fails, commit the fix and re-test
git commit -m "fix: correct nix file references"
```

---

## Rebuilding Systems

Home Manager is used **as a module** (nix-darwin or NixOS), not standalone. **Never suggest `home-manager switch`.**

### nix-darwin (macOS)

```bash
sudo darwin-rebuild switch --flake .#<name>   # Apply
darwin-rebuild build --flake .#<name>         # Build without switching
sudo darwin-rebuild --rollback                # Roll back to the previous generation
```

### NixOS (Linux)

```bash
sudo nixos-rebuild switch --flake .#<name>    # Apply
nixos-rebuild build --flake .#<name>          # Build without switching
sudo nixos-rebuild switch --rollback          # Roll back to the previous generation
```

`rollback` is not a subcommand of either tool; it is the `--rollback` flag.
