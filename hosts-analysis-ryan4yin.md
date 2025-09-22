# Host Configuration Analysis: Ryan4yin's Composable Architecture

This document analyzes ryan4yin's composable host configuration approach and provides a migration plan for our nix-config to adopt similar patterns for easier host management.

## Executive Summary

Ryan4yin's configuration uses a sophisticated architecture that separates host definitions by system architecture and leverages the [haumea](https://github.com/nix-community/haumea) flake for automatic module discovery. This approach scales well with many hosts (he manages 20+ machines) and provides a clean separation of concerns.

**Key Benefits:**
- **Automatic host discovery** - No need to manually add each host to `flake.nix`
- **Architecture-based organization** - Clear separation by system type
- **Scalable structure** - Easy to add new hosts without touching core files
- **Testing integration** - Built-in eval tests and NixOS tests
- **Composable modules** - Flexible module combinations per host

## Current vs. Target Architecture Comparison

### Current Architecture (Our nix-config)

```
flake.nix                           # Manual host definitions
├── darwinConfigurations.a2251      # Manually listed in flake
├── darwinConfigurations.sksm3      # Manually listed in flake
├── nixosConfigurations.rpi4b       # Manually listed in flake
├── nixosConfigurations.x1c4g       # Manually listed in flake
└── nixosConfigurations.nixvm       # Manually listed in flake

hosts/                              # Individual host directories
├── a2251/
│   ├── system.nix                  # Host system config
│   └── home.nix                    # Host home manager config
├── sksm3/
├── rpi4b/
├── x1c4g/
└── nixvm/

variables/default.nix               # Centralized host metadata
└── hosts = {
    a2251 = { hostname = "a2251"; system = "x86_64-darwin"; };
    sksm3 = { hostname = "sksm3"; system = "aarch64-darwin"; };
    # ... etc
}

lib/modules.nix                     # Simple helper functions
```

**Problems with Current Approach:**
1. **Manual flake maintenance** - Each new host requires editing `flake.nix`
2. **Centralized host definitions** - All hosts listed in one place
3. **No architecture separation** - Mixed system types in same namespace
4. **Limited helper functions** - Basic library support
5. **No testing framework** - No eval tests or automated validation

### Target Architecture (Ryan4yin's approach)

```
flake.nix                           # References outputs/default.nix
└── outputs = inputs: import ./outputs inputs;

outputs/                            # Architecture-based organization
├── default.nix                     # Merges all architectures
├── x86_64-linux/
│   ├── default.nix                 # Auto-discovers src/ hosts
│   ├── src/                        # Individual host files
│   │   ├── host1.nix               # Single host definition
│   │   ├── host2.nix               # Single host definition
│   │   └── ...
│   └── tests/                      # Eval tests for this arch
├── aarch64-linux/
│   ├── default.nix
│   ├── src/
│   └── tests/
└── aarch64-darwin/
    ├── default.nix
    ├── src/
    └── tests/

hosts/                              # Individual host directories
├── darwin-hostname1/               # Prefixed by platform
│   ├── default.nix                 # System config
│   └── home.nix                    # Home manager config
├── linux-hostname1/
└── ...

lib/                                # Rich helper functions
├── default.nix                     # Entry point
├── macosSystem.nix                 # Darwin system builder
├── nixosSystem.nix                 # NixOS system builder
└── ...
```

**Benefits of Target Approach:**
1. **Auto-discovery** - Adding a host = creating a single `.nix` file
2. **Architecture separation** - Clear boundaries between system types
3. **Scalable testing** - Per-architecture eval tests
4. **Rich helpers** - Comprehensive system builders
5. **No central registry** - No need to edit `flake.nix` for new hosts

## Detailed Code Analysis

### Ryan4yin's Core Components

#### 1. Main Outputs Controller (`outputs/default.nix`)

```nix
{
  self,
  nixpkgs,
  pre-commit-hooks,
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../vars { inherit lib; };

  # Helper to generate specialArgs per system
  genSpecialArgs = system: inputs // {
    inherit mylib myvars;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
    pkgs-stable = import inputs.nixpkgs-stable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Architecture-based system modules
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
  };
  darwinSystems = {
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
  };
```

**Key Features:**
- **Architecture separation** - Each system type has its own module
- **Shared arguments** - Common args passed to all architectures
- **Multiple nixpkgs** - Stable, unstable, and patched versions available
- **Composition pattern** - All systems merged into final outputs

#### 2. Architecture-Specific Discovery (`outputs/aarch64-darwin/default.nix`)

```nix
{
  lib,
  inputs,
  ...
}@args:
let
  inherit (inputs) haumea;

  # Auto-discover all host files in src/
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  dataWithoutPaths = builtins.attrValues data;

  # Merge all discovered hosts
  outputs = {
    darwinConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.darwinConfigurations or { }) dataWithoutPaths
    );
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths);
  };
```

**Key Features:**
- **Haumea integration** - Automatic file discovery and loading
- **No manual imports** - Files in `src/` are automatically processed
- **Flexible structure** - Each file can export different output types
- **Composable results** - All outputs merged into architecture-level results

#### 3. Individual Host Definition (`outputs/aarch64-darwin/src/fern.nix`)

```nix
{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "fern";

  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "secrets/darwin.nix"
      "modules/darwin"
      "hosts/darwin-${name}"  # Platform-prefixed host dir
    ]) ++ [
      {
        modules.desktop.fonts.enable = true;
      }
    ];

    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
      "home/darwin"
    ];
  };

  systemArgs = modules // args;
in
{
  # Export configuration for this host
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
```

**Key Features:**
- **Single-host focus** - Each file defines one host
- **Platform prefixing** - Host directories prefixed with platform type
- **Helper functions** - Uses `mylib.macosSystem` for consistency
- **Module composition** - Flexible combination of system and home modules

#### 4. Rich Helper Functions (`lib/macosSystem.nix`)

```nix
{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [ ],
  myvars,
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}:
let
  inherit (inputs) nixpkgs-darwin home-manager nix-darwin;
in
nix-darwin.lib.darwinSystem {
  inherit system specialArgs;
  modules = darwin-modules ++ [
    ({ lib, ... }: {
      nixpkgs.pkgs = import nixpkgs-darwin {
        inherit system;
        config.allowUnfree = true;
      };
    })
  ] ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
    home-manager.darwinModules.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "home-manager.backup";
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users."${myvars.username}".imports = home-modules;
    }
  ]);
}
```

**Key Features:**
- **Consistent system building** - Standardized approach across all hosts
- **Optional home manager** - Can be included or excluded per host
- **Flexible specialArgs** - Custom arguments passed to all modules
- **Platform-specific nixpkgs** - Uses appropriate package set per platform

### Current Architecture Analysis

#### Our Current `flake.nix` Host Definitions

```nix
# Current approach - manual host listings
darwinConfigurations.${vars.hosts.a2251.hostname} =
  nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.a2251.hostname);

darwinConfigurations.${vars.hosts.sksm3.hostname} =
  nix-darwin.lib.darwinSystem (mkDarwinHost vars.hosts.sksm3.hostname);

nixosConfigurations.${vars.hosts.rpi4b.hostname} =
  nixpkgs.lib.nixosSystem (mkNixOSHost vars.hosts.rpi4b.hostname);

# Must manually add each new host here...
```

#### Our Current Helper Functions (`lib/modules.nix`)

```nix
{lib, ...}: {
  # Simple path scanning function
  scanPaths = path:
    builtins.map
    (f: (path + "/${f}"))
    (builtins.attrNames (
      lib.attrsets.filterAttrs
      (path: _type:
        (_type == "directory")
        || (path != "default.nix" && lib.strings.hasSuffix ".nix" path))
      (builtins.readDir path)
    ));
}
```

#### Our Current Host Structure (`hosts/a2251/system.nix`)

```nix
_: let
  vars = import ../../variables;
in {
  imports = [
    ../../modules/base.nix
    ../../modules/darwin
  ];

  nixpkgs.hostPlatform = vars.hosts.a2251.system;

  system = {
    primaryUser = vars.user.username;
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
  # ... host-specific configuration
}
```

## Critical Prerequisites and Validation

### Pre-Migration Checklist

Before starting the migration, ensure:

1. **Backup Current Configuration**
   ```bash
   git add .
   git commit -m "backup: pre-migration configuration"
   git tag pre-migration-backup
   ```

2. **Verify Current System Works**
   ```bash
   # Test current configuration builds
   nix flake check
   just check
   ```

3. **Understand Directory Naming**
   - Host directories will be renamed: `a2251` → `darwin-a2251`
   - This affects all references in configuration files
   - Git history will be preserved with `git mv`

### Key Differences from Ryan4yin's Setup

Our migration needs to account for several differences:

1. **Variables System**: We use `variables/default.nix`, ryan4yin uses `vars/default.nix`
2. **Username**: Ryan4yin uses single username `ryan`, we use `vars.user.username`
3. **Host Metadata**: We store more metadata per host (description, etc.)
4. **Module Organization**: Our `modules/` structure differs slightly
5. **No Colmena/K3s**: We don't need remote deployment features initially

## Migration Plan

### Phase 1: Dependencies and Infrastructure

#### Step 1.1: Add Haumea Input

**File: `flake.nix`**
```nix
inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
  home-manager.url = "github:nix-community/home-manager/release-25.05";

  # Add haumea for automatic module discovery
  haumea.url = "github:nix-community/haumea/v0.2.2";
  haumea.inputs.nixpkgs.follows = "nixpkgs";
};
```

#### Step 1.2: Enhanced Library Functions

**Critical Note**: We match ryan4yin's library structure exactly for consistency with the proven architecture. The `relativeToRoot` function is essential for the entire system to work.

**File: `lib/default.nix`** (new - matches ryan4yin's structure)
```nix
{ lib, ... }:
{
  # System builders for creating configurations
  macosSystem = import ./macosSystem.nix;
  nixosSystem = import ./nixosSystem.nix;

  # Attribute manipulation utilities
  attrs = import ./attrs.nix { inherit lib; };

  # Use path relative to the root of the project (ryan4yin's implementation)
  relativeToRoot = lib.path.append ../.;

  # Path scanning utility (matches our existing implementation)
  scanPaths = path:
    builtins.map (f: (path + "/${f}")) (
      builtins.attrNames (
        lib.attrsets.filterAttrs (
          path: _type:
          (_type == "directory")
          || ((path != "default.nix") && (lib.strings.hasSuffix ".nix" path))
        ) (builtins.readDir path)
      )
    );
}
```

**File: `lib/attrs.nix`** (new - required for mergeAttrsList)
```nix
# Attribute set manipulation utilities used throughout the configuration
{ lib, ... }:
{
  # These are used by outputs/default.nix to merge host configurations
  inherit (lib.attrsets) mapAttrs mapAttrs' mergeAttrsList foldlAttrs;

  # Additional helper for list to attrs conversion
  listToAttrs = lib.genAttrs;
}

**File: `lib/macosSystem.nix`** (new - idiomatic Nix style)
```nix
{
  lib,
  inputs,
  darwin-modules,
  home-modules ? [],
  myvars,  # Our variables, not ryan4yin's
  system,
  genSpecialArgs,
  specialArgs ? (genSpecialArgs system),
  ...
}: let
  inherit (inputs) nixpkgs home-manager nix-darwin;
in
  nix-darwin.lib.darwinSystem {
    inherit system specialArgs;
    modules =
      darwin-modules
      ++ [
        (_: {
          nixpkgs.pkgs = import nixpkgs {
            inherit system;
            # Enable unfree packages
            config.allowUnfree = true;
          };
        })
      ]
      # Check if we have any home modules;
      # if true: include the modules
      # if false: include nothing
      # Home Manager only activated if we actually have
      # home configuration
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            # Use system nixpkgs
            useGlobalPkgs = true;
            # Install to user profile
            useUserPackages = true;
            # Backup conflicts
            backupFileExtension = "home-manager.backup";
            # Pass our variables to HM
            extraSpecialArgs = specialArgs;
            # User config
            users."${myvars.user.username}".imports = home-modules;
          };
        }
      ]);
  }
```

**File: `lib/nixosSystem.nix`** (new - idiomatic Nix style)
```nix
{
  inputs,
  lib,
  system,
  genSpecialArgs,
  nixos-modules,
  home-modules ? [],
  specialArgs ? (genSpecialArgs system),
  myvars,
  ...
}: let
  inherit (inputs) nixpkgs home-manager;
in
  nixpkgs.lib.nixosSystem {
    inherit system specialArgs;
    modules =
      nixos-modules
      ++ [
        (_: {
          nixpkgs.pkgs = import nixpkgs {
            inherit system;
            # Enable unfree packages
            config.allowUnfree = true;
          };
        })
      ]
      # Check if we have any home modules;
      # if true: include the modules
      # if false: include nothing
      # Home Manager only activated if we actually have
      # home configuration
      ++ (lib.optionals ((lib.lists.length home-modules) > 0) [
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            # Use system nixpkgs
            useGlobalPkgs = true;
            # Install to user profile
            useUserPackages = true;
            # Backup conflicts
            backupFileExtension = "home-manager.backup";
            # Pass our variables to HM
            extraSpecialArgs = specialArgs;
            # User config
            users."${myvars.user.username}".imports = home-modules;
          };
        }
      ]);
  }
```

#### Step 1.3: Create Outputs Directory Structure

```bash
mkdir -p outputs/x86_64-darwin/src
mkdir -p outputs/x86_64-darwin/tests
mkdir -p outputs/aarch64-darwin/src
mkdir -p outputs/aarch64-darwin/tests
mkdir -p outputs/x86_64-linux/src
mkdir -p outputs/x86_64-linux/tests
mkdir -p outputs/aarch64-linux/src
mkdir -p outputs/aarch64-linux/tests
```

### Phase 2: Core Infrastructure

#### Step 2.1: Main Outputs Controller

**CRITICAL**: This file is the heart of the new architecture. It must correctly import our `variables` (not `vars`) and pass them through the system.

**File: `outputs/default.nix`** (new)
```nix
{
  self,
  nixpkgs,
  nixpkgs-unstable,
  nix-darwin,
  home-manager,
  haumea,  # Don't forget to add haumea to inputs
  ...
}@inputs:
let
  inherit (inputs.nixpkgs) lib;
  mylib = import ../lib { inherit lib; };
  myvars = import ../variables;  # OUR variables, not ../vars

  # Generate specialArgs for each system
  genSpecialArgs = system: inputs // {
    inherit mylib myvars;
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };

  # Common args for all architectures
  args = {
    inherit inputs lib mylib myvars genSpecialArgs;
  };

  # Architecture-specific modules
  nixosSystems = {
    x86_64-linux = import ./x86_64-linux (args // { system = "x86_64-linux"; });
    aarch64-linux = import ./aarch64-linux (args // { system = "aarch64-linux"; });
  };
  darwinSystems = {
    x86_64-darwin = import ./x86_64-darwin (args // { system = "x86_64-darwin"; });
    aarch64-darwin = import ./aarch64-darwin (args // { system = "aarch64-darwin"; });
  };

  allSystems = nixosSystems // darwinSystems;
  allSystemNames = builtins.attrNames allSystems;
  nixosSystemValues = builtins.attrValues nixosSystems;
  darwinSystemValues = builtins.attrValues darwinSystems;
  allSystemValues = nixosSystemValues ++ darwinSystemValues;

  # Helper for generating attributes across all systems
  forAllSystems = func: (nixpkgs.lib.genAttrs allSystemNames func);
in
{
  # NixOS Configurations
  nixosConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.nixosConfigurations or { }) nixosSystemValues
  );

  # macOS Configurations
  darwinConfigurations = lib.attrsets.mergeAttrsList (
    map (it: it.darwinConfigurations or { }) darwinSystemValues
  );

  # Packages
  packages = forAllSystems (system: allSystems.${system}.packages or { });

  # Development Shells
  devShells = forAllSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          alejandra
          pre-commit
          statix
          deadnix
          nix-tree
          manix
          nil
          jq
          git
          lua-language-server
          stylua
          selene
        ];
      };
    });

  # Formatter
  formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
}
```

#### Step 2.2: Architecture-Specific Controllers

**IMPORTANT**: These controllers use haumea to auto-discover host files. The `haumea.lib.load` function automatically imports all `.nix` files in the `src/` directory and passes the `args` to each file.

**File: `outputs/aarch64-darwin/default.nix`** (new)
```nix
{
  lib,
  inputs,
  ...
}@args:
let
  inherit (inputs) haumea;

  # Auto-discover all host files in src/
  # Each file in src/ will be imported and passed 'args'
  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  # Remove the file paths, keeping only the values
  dataWithoutPaths = builtins.attrValues data;

  # Merge all discovered hosts into a single attrset
  outputs = {
    darwinConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.darwinConfigurations or { }) dataWithoutPaths
    );
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths);
  };
in
outputs // {
  inherit data; # for debugging - allows inspecting what haumea loaded

  # Add eval tests support (optional, can be added later)
  evalTests = haumea.lib.loadEvalTests {
    src = ./tests;
    inputs = args // { inherit outputs; };
  };
}
```

**File: `outputs/x86_64-darwin/default.nix`** (new)
```nix
# Same as aarch64-darwin/default.nix
```

**File: `outputs/x86_64-linux/default.nix`** (new)
```nix
{
  lib,
  inputs,
  ...
}@args:
let
  inherit (inputs) haumea;

  data = haumea.lib.load {
    src = ./src;
    inputs = args;
  };
  dataWithoutPaths = builtins.attrValues data;

  outputs = {
    nixosConfigurations = lib.attrsets.mergeAttrsList (
      map (it: it.nixosConfigurations or { }) dataWithoutPaths
    );
    packages = lib.attrsets.mergeAttrsList (map (it: it.packages or { }) dataWithoutPaths);
  };
in
outputs // {
  inherit data;
}
```

**File: `outputs/aarch64-linux/default.nix`** (new)
```nix
# Same as x86_64-linux/default.nix
```

### Phase 3: Host Migration

#### Step 3.1: Rename Host Directories

**WARNING**: This step breaks the current configuration temporarily. Do this only after Phase 1 and 2 are complete.

```bash
# Add platform prefixes to existing host directories
# This preserves git history
git mv hosts/a2251 hosts/darwin-a2251
git mv hosts/sksm3 hosts/darwin-sksm3
git mv hosts/rpi4b hosts/linux-rpi4b
git mv hosts/x1c4g hosts/linux-x1c4g
git mv hosts/nixvm hosts/linux-nixvm

# Also rename system.nix to default.nix in each host directory
mv hosts/darwin-a2251/system.nix hosts/darwin-a2251/default.nix
mv hosts/darwin-sksm3/system.nix hosts/darwin-sksm3/default.nix
mv hosts/linux-rpi4b/system.nix hosts/linux-rpi4b/default.nix
mv hosts/linux-x1c4g/system.nix hosts/linux-x1c4g/default.nix
mv hosts/linux-nixvm/system.nix hosts/linux-nixvm/default.nix
```

#### Step 3.2: Create Host Definition Files

**File: `outputs/x86_64-darwin/src/a2251.nix`** (new)
```nix
{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "a2251";

  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/darwin"
      "hosts/darwin-${name}"
    ]) ++ [
      {
        # Host-specific system module config can go here
        nixpkgs.hostPlatform = system;
        system.primaryUser = myvars.user.username;
      }
    ];

    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
```

**File: `outputs/aarch64-darwin/src/sksm3.nix`** (new)
```nix
{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "sksm3";

  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/darwin"
      "hosts/darwin-${name}"
    ]) ++ [
      {
        nixpkgs.hostPlatform = system;
        system.primaryUser = myvars.user.username;
      }
    ];

    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  darwinConfigurations.${name} = mylib.macosSystem systemArgs;
}
```

**File: `outputs/aarch64-linux/src/rpi4b.nix`** (new)
```nix
{
  inputs,
  lib,
  mylib,
  myvars,
  system,
  genSpecialArgs,
  ...
}@args:
let
  name = "rpi4b";

  modules = {
    nixos-modules = (map mylib.relativeToRoot [
      "modules/base.nix"
      "modules/nixos"
      "hosts/linux-${name}"
    ]) ++ [
      {
        nixpkgs.hostPlatform = system;
      }
    ];

    home-modules = map mylib.relativeToRoot [
      "hosts/linux-${name}/home.nix"
    ];
  };

  systemArgs = modules // args;
in
{
  nixosConfigurations.${name} = mylib.nixosSystem systemArgs;
}
```

#### Step 3.3: Update Host Directory Structure

**File: `hosts/darwin-a2251/default.nix`** (modified from current system.nix)
```nix
# IMPORTANT: This file no longer needs to import base.nix or modules/darwin
# Those are handled in the outputs/ host definition
# Also no longer needs to import variables - passed as myvars
{myvars, ...}: {
  # Host-specific system configuration
  # No need to set nixpkgs.hostPlatform here - handled in outputs/
  # No need to set system.primaryUser here - handled in outputs/

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };

  # Environment and host-specific settings
  environment.variables = {
    EDITOR = myvars.preferences.editor;
  };

  # User configuration - same as before
  users.users.${myvars.user.username} = {
    home = "/Users/${myvars.user.username}";
    shell = pkgs.${myvars.user.shell};
  };

  # Homebrew packages specific to this host
  homebrew.casks = [
    "steam"
    # ... other host-specific apps
  ];
}
```

### Phase 4: Flake Integration

#### Step 4.1: Update Main Flake

**File: `flake.nix`** (simplified)
```nix
{
  description = "Modular nix{-darwin,OS} config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    haumea.url = "github:nix-community/haumea/v0.2.2";
    haumea.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: import ./outputs inputs;
}
```

### Phase 5: Testing and Validation

#### Step 5.1: Basic Eval Tests

**File: `outputs/x86_64-darwin/tests/hostnames/expr.nix`** (new)
```nix
{ outputs, ... }:
let
  hostnames = builtins.attrNames outputs.darwinConfigurations;
in
{
  a2251-exists = builtins.elem "a2251" hostnames;
}
```

**File: `outputs/x86_64-darwin/tests/hostnames/expected.nix`** (new)
```nix
{
  a2251-exists = true;
}
```

## Validation Steps

### Phase-by-Phase Validation

After each phase, validate the configuration still works:

#### After Phase 1 (Dependencies):
```bash
# Check flake still evaluates
nix flake metadata
nix flake check --no-build
```

#### After Phase 2 (Infrastructure):
```bash
# Test the new outputs structure
nix eval .#debugAttrs --show-trace
```

#### After Phase 3 (Host Migration):
```bash
# Test specific host configurations
nix eval .#darwinConfigurations.a2251.config.system.build.toplevel --show-trace
nix eval .#nixosConfigurations.rpi4b.config.system.build.toplevel --show-trace
```

#### After Phase 4 (Integration):
```bash
# Full system test
nix flake check
just check

# Try building without switching
just build

# If all passes, switch
just rebuild
```

### Common Issues and Fixes

1. **"attribute 'mergeAttrsList' missing"**
   - Ensure you're using nixpkgs 23.11 or later
   - Or implement fallback in lib/attrs.nix

2. **"cannot find flake 'flake:haumea'"**
   - Ensure haumea is properly added to inputs
   - Check `haumea.inputs.nixpkgs.follows = "nixpkgs"`

3. **"undefined variable 'myvars'"**
   - Check outputs/default.nix imports ../variables correctly
   - Verify genSpecialArgs includes myvars

4. **"file not found" errors**
   - Remember all files must be git-added for flakes
   - Run `git add .` before testing

5. **"infinite recursion" errors**
   - Usually caused by circular imports
   - Check that host default.nix doesn't import itself

## Benefits After Migration

### 1. Simplified Host Addition

**Before: Adding a new Darwin host required:**
1. Create `hosts/newhost/` directory with `system.nix` and `home.nix`
2. Add host metadata to `variables/default.nix`
3. Add host configuration to `flake.nix`

**After: Adding a new Darwin host requires:**
1. Create `hosts/darwin-newhost/` directory with `default.nix` and `home.nix`
2. Create `outputs/aarch64-darwin/src/newhost.nix` (or appropriate architecture)

### 2. Better Organization

- **Architecture separation**: Clear boundaries between system types
- **Auto-discovery**: No need to manually maintain host lists
- **Scalable testing**: Per-architecture eval tests
- **Rich helpers**: Comprehensive system builders

### 3. Improved Maintainability

- **Consistent patterns**: All hosts follow same structure
- **Less duplication**: Shared helper functions
- **Better debugging**: Haumea provides good error messages
- **Future-proof**: Easy to add new architectures or host types

## Implementation Notes

### Compatibility Considerations

1. **Existing commands work unchanged**: `just rebuild`, etc. will continue to work
2. **Host names unchanged**: All existing hostnames remain the same
3. **Configuration preserved**: All existing settings migrated intact
4. **Variables system**: Can be preserved or gradually migrated

### Testing Strategy

1. **One architecture at a time**: Migrate Darwin hosts first, then NixOS
2. **Parallel development**: Keep old structure until new one is validated
3. **Gradual migration**: Move hosts one by one to minimize risk
4. **Validation tests**: Add eval tests to catch configuration errors

### Future Enhancements

1. **Additional test types**: NixOS tests for full system validation
2. **Host templates**: Standard patterns for common host types
3. **Specialized generators**: Like ryan4yin's K3s and KubeVirt helpers
4. **Configuration sharing**: Common module patterns across hosts

## Step-by-Step Migration Example

### Complete Example: Migrating the a2251 Host

Let's walk through migrating a2251 completely:

1. **Current Structure:**
```
hosts/a2251/
├── system.nix (140 lines with imports, homebrew config, etc.)
└── home.nix (imports profiles and roles)
```

2. **After Migration Structure:**
```
hosts/darwin-a2251/
├── default.nix (60 lines, just host-specific config)
└── home.nix (unchanged)

outputs/x86_64-darwin/src/
└── a2251.nix (30 lines, wires everything together)
```

3. **The New Host Definition (`outputs/x86_64-darwin/src/a2251.nix`):**
```nix
{inputs, lib, mylib, myvars, system, genSpecialArgs, ...}@args:
let
  name = "a2251";
  modules = {
    darwin-modules = (map mylib.relativeToRoot [
      "modules/base.nix"      # System packages
      "modules/darwin"        # macOS configuration
      "hosts/darwin-${name}"  # Host-specific config
    ]) ++ [{
      # Inline module for things that were in system.nix
      nixpkgs.hostPlatform = system;
      system.primaryUser = myvars.user.username;
    }];

    home-modules = map mylib.relativeToRoot [
      "hosts/darwin-${name}/home.nix"
    ];
  };
in {
  darwinConfigurations.${name} = mylib.macosSystem (modules // args);
}
```

## Testing the Migration

### Incremental Testing Script

Create `test-migration.sh`:
```bash
#!/usr/bin/env bash
set -e

echo "=== Phase 1: Testing current configuration ==="
nix flake check || exit 1

echo "=== Phase 2: Testing with haumea added ==="
# After adding haumea to inputs
nix flake metadata || exit 1

echo "=== Phase 3: Testing outputs structure ==="
# After creating outputs/
nix eval .#debugAttrs 2>/dev/null && echo "✓ Outputs structure valid"

echo "=== Phase 4: Testing host discovery ==="
# After adding first host to outputs/*/src/
nix eval .#darwinConfigurations --apply 'builtins.attrNames' || exit 1

echo "=== Phase 5: Full validation ==="
nix flake check || exit 1

echo "✅ All tests passed!"
```

## Conclusion

This migration will significantly improve the scalability and maintainability of our nix-config while preserving all existing functionality. The ryan4yin approach has been proven to work well at scale (20+ hosts) and provides a clear path for future growth.

The key insight is using haumea for automatic discovery combined with architecture-based organization to eliminate manual maintenance of host lists while providing clean separation of concerns.

### Key Success Factors

1. **Preserve Working State**: Keep old structure until new one is proven
2. **Test Incrementally**: Validate after each step
3. **Git Add Everything**: Flakes only see tracked files
4. **Understand the Flow**: Data flows from `outputs/*/src/*.nix` → `outputs/*/default.nix` → `outputs/default.nix` → `flake.nix`
5. **Variable Consistency**: Always use our `myvars` structure, not ryan4yin's

### Next Steps After Migration

1. Add eval tests for validation
2. Consider adding NixOS tests for Linux hosts
3. Explore colmena for remote deployment (optional)
4. Document the new host addition process