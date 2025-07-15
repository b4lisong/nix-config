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

## Package Override Patterns and Common Mistakes

**CRITICAL**: Understanding how Nix handles package lists vs individual values is essential for proper configuration management.

### The List Merging Trap (MOST COMMON MISTAKE)

**Wrong Mental Model**: "Host configurations override imported module configurations"

**Reality**: Lists are ALWAYS concatenated (merged), never replaced by default.

#### Example of the Problem:

```nix
# In home/roles/dev/default.nix
home.packages = [
  pkgs-unstable.nodejs_latest  # Package A
  pkgs.gh
];

# In hosts/personal/home.nix  
home.packages = [
  pkgs.nodejs  # Trying to "override" Package A
];

# RESULT: Both nodejs packages are installed (A + override)
# NOT: nodejs replaces nodejs_latest
```

**The mistake**: Adding to `home.packages` in a host ADDS packages, it does NOT replace packages from imported modules.

### How Nix Module System Actually Works

#### Lists: Always Concatenated
```nix
# Module 1: home.packages = [A, B]
# Module 2: home.packages = [C]  
# Result:   home.packages = [A, B, C]  # Concatenation
```

#### Values: Priority-Based Replacement
```nix
# Module 1: programs.git.userName = "default"
# Module 2: programs.git.userName = "override"
# Result:   programs.git.userName = "override"  # Replacement
```

#### Priority System with lib.mkDefault/mkForce
```nix
# Module 1: programs.git.userName = lib.mkDefault "default"  # Priority 1000
# Module 2: programs.git.userName = "override"               # Priority 1000
# Result:   programs.git.userName = "override"  # Last definition wins

# Module 1: programs.git.userName = lib.mkDefault "default"  # Priority 1000  
# Module 2: programs.git.userName = lib.mkForce "override"   # Priority 50
# Result:   programs.git.userName = "override"  # mkForce always wins
```

### Safe Package Override Patterns

#### Pattern 1: Change Default + Host Addition (Recommended)
**Use Case**: Want different package versions per host, accept temporary duplication

```nix
# In shared role (e.g., home/roles/dev/default.nix)
home.packages = [
  # Use stable version as safe default for all hosts
  nodejs  # Changed from pkgs-unstable.nodejs_latest to stable default
  pkgs.gh
];

# In hosts needing bleeding-edge (e.g., hosts/personal/home.nix)
home.packages = [
  # Add unstable version for this specific host
  pkgs-unstable.nodejs_latest  # Personal machine gets latest features
];

# RESULT: 
# - Personal machine: both nodejs + nodejs_latest (temporary acceptable duplication)
# - Work machines: only nodejs (stable, reliable)
```

**Advantages**: Simple, low maintenance, safe defaults
**Trade-offs**: Temporary package duplication on override hosts

#### Pattern 2: Complete List Override with lib.mkForce
**Use Case**: Need precise control, willing to maintain full package lists

```nix
# In shared role
home.packages = lib.mkDefault [
  pkgs-unstable.nodejs_latest
  pkgs.gh
];

# In conservative host
home.packages = lib.mkForce [
  pkgs.nodejs  # Stable version
  pkgs.gh      # Must duplicate all other packages
];

# RESULT: Host gets exactly the specified packages, no merging
```

**Advantages**: Precise control, no package duplication
**Trade-offs**: Must maintain complete package lists, high maintenance

#### Pattern 3: Conditional Package Selection
**Use Case**: Complex logic based on host characteristics

```nix
# In shared role
home.packages = [
  # Conditional based on host information
  (if vars.hosts.${hostName}.description == "Work MacBook" 
   then pkgs.nodejs 
   else pkgs-unstable.nodejs_latest)
  pkgs.gh
];
```

**Advantages**: Centralized logic, no duplication
**Trade-offs**: Requires passing host context, more complex

### Real-World Example: nodejs Unstable Build Failure

**Problem**: `pkgs-unstable.nodePackages_latest.nodejs` failing to build
**Issue**: https://github.com/NixOS/nixpkgs/issues/423244

**Wrong Approach** (what was initially suggested):
```nix
# This ADDS packages, doesn't replace
# In hosts/work/home.nix
home.packages = [
  pkgs.nodejs  # This adds to the unstable nodejs, doesn't replace it
];
# Result: Both nodejs versions installed
```

**Correct Approach** (what we implemented):
```nix
# Change default in shared role
# In home/roles/dev/default.nix  
home.packages = [
  # TODO: Revert to unstable nodejs once packaging issue is resolved
  # Issue: https://github.com/NixOS/nixpkgs/issues/423244
  nodejs  # Changed from pkgs-unstable.nodePackages_latest.nodejs
];

# Add override for hosts that want bleeding-edge
# In hosts/personal/home.nix
home.packages = [
  pkgs-unstable.nodePackages_latest.nodejs  # Personal machine gets latest
];
# Result: Work machines get stable, personal gets both (acceptable temporary state)
```

### When to Use Each Pattern

#### Use Pattern 1 (Change Default + Addition) When:
- ✅ Need quick workaround for broken packages
- ✅ Want safe defaults with opt-in bleeding-edge
- ✅ Can accept temporary package duplication
- ✅ Low maintenance overhead is priority

#### Use Pattern 2 (lib.mkForce Override) When:
- ✅ Need precise control over exact packages
- ✅ Cannot accept any package duplication
- ✅ Willing to maintain complete package lists
- ✅ Have few hosts with overrides

#### Use Pattern 3 (Conditional Logic) When:
- ✅ Complex decision logic needed
- ✅ Many hosts with different requirements  
- ✅ Want centralized package management
- ✅ Can pass host context to modules

### Common Mistakes to Avoid

#### ❌ WRONG: Assuming lib.mkDefault Works with Individual Package Items
```nix
home.packages = [
  (lib.mkDefault pkgs.nodejs)  # This does NOTHING useful
  pkgs.gh
];
```
**Problem**: `lib.mkDefault` only affects entire list replacement, not individual items within lists.

#### ❌ WRONG: Thinking Host Packages Replace Role Packages  
```nix
# In role
home.packages = [pkgs-unstable.nodejs_latest];

# In host  
home.packages = [pkgs.nodejs];  # Thinking this replaces the role package

# ACTUAL RESULT: Both packages installed
```

#### ❌ WRONG: Using lib.mkForce for Single Package Override
```nix
# Don't do this just to change one package
home.packages = lib.mkForce [
  pkgs.nodejs   # The one package you want to change
  pkgs.gh       # Now you must maintain ALL the other packages too
  pkgs.curl     # This becomes a maintenance burden
  # ... 20 more packages you must now manually maintain
];
```

### Mental Model Correction

**Old (Wrong) Mental Model:**
- "Host configurations override imported configurations"
- "lib.mkDefault makes individual packages overridable"
- "Adding a package replaces a similar package"

**New (Correct) Mental Model:**
- "Configurations are merged according to type (lists concatenate, values replace)"
- "lib.mkDefault/mkForce work on entire option definitions, not individual list items"  
- "Package management requires explicit strategies for replacement vs addition"

**Key Insight**: The Nix module system is designed for **composability through merging**, not **replacement through inheritance**.

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