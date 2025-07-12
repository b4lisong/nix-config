# NIX CONFIGURATION DEVELOPMENT STANDARDS

## Architecture Overview

This is a **Nix flake-based configuration** managing macOS systems with nix-darwin and Home Manager integration.

### System Architecture:
```
flake.nix → mkDarwinHost() → system modules → Home Manager → user profiles/roles
```

**Configuration Layers (applied bottom-to-top):**
1. **Base Layer** (`modules/base.nix`): Core packages, fonts, Nix settings
2. **Platform Layer** (`modules/darwin/`): macOS-specific system configuration  
3. **Host Layer** (`hosts/<hostname>/system.nix`): Machine-specific overrides
4. **Profile Layer** (`home/profiles/`): User environments (base, tui, gui, darwin)
5. **Role Layer** (`home/roles/`): Purpose-based packages (dev, personal, work, security)

### Dual Package System:
- **nixpkgs**: Stable packages for reliability
- **nixpkgs-unstable**: Bleeding-edge packages for development tools
- Both available via `specialArgs` throughout the configuration

## MANDATORY PACKAGE VERIFICATION

**CRITICAL**: Always verify packages against the EXACT version you're using.

### Before Adding ANY Package:
1. **Run verification command**: `nix search nixpkgs <package-name>`
2. **Verify package exists** in current nixpkgs version
3. **Check compatibility** with your setup
4. **Only proceed if verified** - no assumptions

**BLOCKING REQUIREMENT**: If package doesn't exist, find correct alternative or different approach.

### Home Manager Option Verification:
1. **Check flake.lock**: Identify Home Manager commit/version
2. **Use version-specific docs**: 
   - https://mynixos.com/home-manager/options/ (latest)
   - https://nix-community.github.io/home-manager/options.html (specific releases)
3. **Search for exact option**: Use browser search for option name
4. **Version compatibility check**: Verify option exists in YOUR version
5. **Document source**: Include documentation URL in comments if complex

**FORBIDDEN**: 
- Using packages without verification
- Assuming packages exist across all versions
- Using documentation from different versions

## Development Environment Setup

```bash
nix develop  # Enter development shell with quality tools
```

**Available Tools in Dev Shell:**
- `alejandra` - Nix code formatter (MANDATORY)
- `statix` - Nix linter (MANDATORY) 
- `deadnix` - Dead code detection (MANDATORY)
- `nil` - Nix language server (for editor integration)

## Quality Enforcement Pipeline

**Pre-commit hooks are MANDATORY and BLOCKING:**

```bash
# These run automatically on commit for .nix files:
alejandra .          # Format all .nix files
statix check .       # Lint all .nix files  
deadnix --fail .     # Check for dead code
```

## File Type → Tool Mapping

**CRITICAL**: Always match tools to correct file types.

| File Type | Extensions | Formatter | Linter | When to Validate |
|-----------|------------|-----------|---------|------------------|
| **Nix** | `*.nix` | `alejandra` | `statix` | **Always** |
| **Markdown** | `*.md` | *(manual)* | *(none)* | **Never** |
| **All Files** | `*` | *(none)* | *(none)* | **Always** (generic cleanup) |

**Never apply Nix tools to non-Nix files:**
- ❌ `alejandra CLAUDE.md` 
- ❌ `statix check README.md`
- ✅ `alejandra *.nix`

## Nix Testing Requirements (CRITICAL)

**BEFORE running `darwin-rebuild check --flake .#<SYSTEM>`:**

### Mandatory Git State Requirements:
1. **COMMIT ALL CHANGES** - Nix requires committed state for local file references
2. **Test after each logical change** - Don't batch multiple features  
3. **Use descriptive commit messages** - Document what you're testing/fixing

### Required Workflow:
```bash
# Make changes to .nix files
git add .
git commit -m "feat: add catppuccin theme plugin"
# THEN test (will fail without commit)
sudo darwin-rebuild check --flake .#<SYSTEM>
# If build fails, commit the fix
git commit -m "fix: correct nix file references"
```

**Why This Matters**: Nix flakes operate on **committed git state** for reproducibility.

## System-Specific Testing Requirements

**CRITICAL**: Always test the actual system configuration.

**IMPORTANT**: Replace `<SYSTEM>` with actual system name (currently: `a2251`)

### Testing Command Hierarchy:
1. **Flake structure validation**: `nix flake check` (fast, validates flake syntax)
2. **System configuration test**: `sudo darwin-rebuild check --flake .#a2251` (comprehensive)
3. **Build verification**: `sudo darwin-rebuild build --flake .#a2251` (creates but doesn't apply)

### Testing Protocol:
```bash
# 0. PREREQUISITE: Commit all changes
git add .
git commit -m "feat: describe your changes"

# 1. Quick flake validation (structure only)
nix flake check

# 2. Full system validation (REQUIRED for .nix changes)
sudo darwin-rebuild check --flake .#a2251

# 3. Build test without applying (optional verification)
sudo darwin-rebuild build --flake .#a2251
```

## System Rebuild Process

```bash
# Standard rebuild for active development
sudo darwin-rebuild switch --flake .#a2251

# Safe rebuild (build without switching)
sudo darwin-rebuild build --flake .#a2251

# Rollback if issues occur
sudo darwin-rebuild rollback
```

## Nix-Specific Quality Rules

### FORBIDDEN PATTERNS IN NIX:

- **NO** `lib.mkForce` unless absolutely necessary - use `lib.mkDefault` first
- **NO** hardcoded store paths - use `${pkgs.package}` references
- **NO** `fetchTarball` without hash - use flake inputs instead
- **NO** `builtins.fetchurl` - use proper fetchers (fetchFromGitHub, etc.)
- **NO** `with pkgs;` in large scopes - prefer explicit package references
- **NO** recursive attribute sets without clear necessity
- **NO** `import <nixpkgs> {}` in modules - use function arguments
- **NO** mixing tabs and spaces - use consistent indentation (2 spaces)

### REQUIRED PATTERNS:

- **USE** `lib.mkDefault` for host-overridable defaults
- **USE** `lib.mkIf` for conditional configuration
- **USE** `lib.mkMerge` for combining attribute sets
- **USE** proper function signatures: `{pkgs, lib, ...}:`
- **USE** `inherit` for variable passing: `inherit (vars.git) userName;`
- **USE** `let ... in` for local variable scoping
- **USE** string interpolation: `"${vars.user.username}"`

## Package Selection Strategy

**Use Stable Packages For:**
- Core system tools (editors, shells, essential utilities)
- Well-established development tools
- Packages where stability is crucial

**Use Unstable Packages For:**
- Rapidly evolving development tools
- Latest language versions (Node.js, Python, Go)
- Cutting-edge CLI tools
- Packages where newest features matter

**Example:**
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

## File Organization Patterns

### Configuration Location Rules:
- **System-level**: `modules/` and `hosts/<hostname>/system.nix`
- **User-level**: `home/profiles/` and `home/roles/`
- **Variables**: `variables/default.nix` (centralized configuration)
- **Host-specific**: `hosts/<hostname>/` (both system and user config)

### Variable Usage:
```nix
# Good - use centralized variables
let
  vars = import ../../variables;
in {
  home.homeDirectory = "/Users/${vars.user.username}";
  programs.git.inherit (vars.git) userName userEmail;
}

# Bad - hardcoded values
home.homeDirectory = "/Users/balisong";
```