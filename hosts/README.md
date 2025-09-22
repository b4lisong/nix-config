# Host Management Guide

This guide explains the composable host architecture and provides step-by-step instructions for adding new hosts to the nix-config.

## Architecture Overview

This configuration uses a modern composable architecture inspired by [ryan4yin's nix-config](https://github.com/ryan4yin/nix-config) that provides automatic host discovery and better scalability than traditional approaches.

### Key Features

- **Automatic Discovery**: Hosts are discovered automatically via [haumea](https://github.com/nix-community/haumea) - no manual flake.nix editing required
- **Architecture-Based Organization**: Hosts are organized by system architecture for clear separation
- **Scalable Structure**: Adding new hosts is as simple as dropping a file in the right directory
- **Composable Modules**: Clean separation between system and user configuration

### Directory Structure

```
outputs/                           # Auto-discovery system
├── default.nix                    # Main controller
├── aarch64-darwin/                 # Apple Silicon macOS
│   ├── default.nix               # Architecture controller
│   └── src/
│       └── sksm3.nix             # Auto-discovered hosts
├── x86_64-darwin/                 # Intel macOS
│   └── src/
│       └── a2251.nix             # Auto-discovered hosts
├── aarch64-linux/                 # ARM64 Linux
│   └── src/
│       ├── rpi4b.nix             # Auto-discovered hosts
│       └── nixvm.nix
└── x86_64-linux/                  # x86_64 Linux
    └── src/
        └── x1c4g.nix             # Auto-discovered hosts

hosts/                             # Host configurations
├── darwin-a2251/                  # macOS host configs
│   ├── default.nix               # System configuration
│   └── home.nix                  # Home Manager configuration
├── darwin-sksm3/
├── linux-rpi4b/                  # Linux host configs
│   ├── default.nix               # System configuration
│   └── home.nix                  # Home Manager configuration
├── linux-x1c4g/
└── linux-nixvm/
```

### How Auto-Discovery Works

1. **Haumea Scanning**: The `haumea.lib.load` function scans `outputs/{arch}/src/` directories
2. **File Processing**: Each `.nix` file in `src/` is evaluated and its outputs collected
3. **Configuration Merging**: All `darwinConfigurations` and `nixosConfigurations` are merged
4. **Flake Outputs**: The merged configurations become available as flake outputs

Example: When you create `outputs/aarch64-darwin/src/newhost.nix`, it automatically becomes available as `darwinConfigurations.newhost` without editing `flake.nix`.

## Host Organization

### Naming Conventions

- **macOS hosts**: `darwin-{hostname}` (e.g., `darwin-macbook`, `darwin-imac`)
- **Linux hosts**: `linux-{hostname}` (e.g., `linux-server`, `linux-laptop`)

### Architecture Mapping

| System | Architecture | Directory |
|--------|-------------|-----------|
| Intel Mac | x86_64-darwin | `outputs/x86_64-darwin/src/` |
| Apple Silicon Mac | aarch64-darwin | `outputs/aarch64-darwin/src/` |
| Intel/AMD Linux | x86_64-linux | `outputs/x86_64-linux/src/` |
| ARM64 Linux | aarch64-linux | `outputs/aarch64-linux/src/` |

## Adding a New Host

### Step 1: Determine Architecture

First, identify your target system architecture:

```bash
# On the target system, run:
nix eval --expr 'builtins.currentSystem'

# Or check manually:
# macOS: System Information → Hardware → Processor
# Linux: uname -m
```

### Step 2: Choose Architecture-Specific Instructions

#### Adding a macOS Host (Darwin)

##### For Apple Silicon Macs (aarch64-darwin):

1. **Create host configuration directory:**
   ```bash
   mkdir -p hosts/darwin-{hostname}
   ```

2. **Create the system configuration** (`hosts/darwin-{hostname}/default.nix`):
   ```nix
   {myvars, pkgs, ...}: {
     # NOTE: imports are handled by the outputs system
     # base.nix and modules/darwin are imported automatically
     # Variables are passed as myvars parameter

     # Host-specific system configuration
     system = {
       primaryUser = myvars.user.username;
       keyboard = {
         enableKeyMapping = true;
         remapCapsLockToEscape = true;
       };
     };

     # User account configuration
     users.users.${myvars.user.username} = {
       name = myvars.user.username;
       home = "/Users/${myvars.user.username}";
     };

     # Host-specific Homebrew packages (optional)
     homebrew = {
       casks = [
         "example-app"
       ];
       brews = [
         "example-tool"
       ];
     };
   }
   ```

3. **Create the home configuration** (`hosts/darwin-{hostname}/home.nix`):
   ```nix
   {lib, pkgs, ...}: {
     imports = [
       # Complete macOS desktop profile
       ../../home/profiles/darwin

       # Role-based package sets
       ../../home/roles/dev      # Development tools
       ../../home/roles/personal # Personal apps (optional)
     ];

     # Host-specific Home Manager customizations
     programs.kitty = {
       # Example: host-specific terminal settings
       # font.size = lib.mkForce 16;
     };
   }
   ```

4. **Create the outputs file** (`outputs/aarch64-darwin/src/{hostname}.nix`):
   ```nix
   {
     inputs, lib, mylib, myvars, system, genSpecialArgs, ...
   }@args:
   let
     name = "{hostname}";
     modules = {
       darwin-modules = (map mylib.relativeToRoot [
         "modules/base.nix"
         "modules/darwin"
         "hosts/darwin-${name}"
       ]) ++ [{
         nixpkgs.hostPlatform = system;
         system.primaryUser = myvars.user.username;
       }];
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

##### For Intel Macs (x86_64-darwin):

Follow the same steps as Apple Silicon, but create the outputs file in `outputs/x86_64-darwin/src/{hostname}.nix`.

#### Adding a Linux Host (NixOS)

##### For x86_64 Linux Systems:

1. **Create host configuration directory:**
   ```bash
   mkdir -p hosts/linux-{hostname}
   ```

2. **Generate hardware configuration:**
   ```bash
   # On the target system:
   sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix
   # Copy this file to hosts/linux-{hostname}/hardware-configuration.nix
   ```

3. **Create the system configuration** (`hosts/linux-{hostname}/default.nix`):
   ```nix
   {
     config,
     lib,
     pkgs,
     myvars,
     ...
   }: {
     imports = [
       ./hardware-configuration.nix
     ];
     # NOTE: other imports are handled by the outputs system

     # Host identification
     networking.hostName = myvars.hosts.{hostname}.hostname;

     # Boot configuration (adjust for your system)
     boot.loader = {
       systemd-boot = {
         enable = true;
         configurationLimit = 10;
       };
       efi.canTouchEfiVariables = true;
     };

     # User configuration
     users.users.${myvars.user.username} = {
       isNormalUser = true;
       description = myvars.user.fullName;
       extraGroups = [
         "wheel"          # sudo access
         "networkmanager"
         "audio"
         "video"
       ];
     };

     # Host-specific services
     services = {
       openssh.enable = true;
       # Add other services as needed
     };

     # System state version
     system.stateVersion = "25.05";
   }
   ```

4. **Create the home configuration** (`hosts/linux-{hostname}/home.nix`):
   ```nix
   {
     config,
     lib,
     pkgs,
     myvars,
     ...
   }: {
     imports = [
       # Choose appropriate profiles
       ../../home/profiles/base    # Essential CLI tools
       ../../home/profiles/tui     # TUI applications
       # ../../home/profiles/gui   # Desktop applications (if needed)

       # Role-based package sets
       ../../home/roles/dev        # Development tools
     ];

     # Home Manager configuration
     home = {
       username = myvars.user.username;
       homeDirectory = "/home/${myvars.user.username}";
       stateVersion = "25.05";
     };

     # Git configuration
     programs.git = {
       userName = myvars.git.userName;
       userEmail = myvars.git.userEmail;
     };
   }
   ```

5. **Create the outputs file** (`outputs/x86_64-linux/src/{hostname}.nix`):
   ```nix
   {
     inputs, lib, mylib, myvars, system, genSpecialArgs, ...
   }@args:
   let
     name = "{hostname}";
     modules = {
       nixos-modules = (map mylib.relativeToRoot [
         "modules/base.nix"
         "modules/nixos"
         "hosts/linux-${name}"
       ]) ++ [{
         nixpkgs.hostPlatform = system;
       }];
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

##### For ARM64 Linux Systems (like Raspberry Pi):

Follow the same steps as x86_64 Linux, but:
- Create the outputs file in `outputs/aarch64-linux/src/{hostname}.nix`
- For Raspberry Pi specifically, add specialized modules:
  ```nix
  nixos-modules = (map mylib.relativeToRoot [
    "modules/base.nix"
    "modules/nixos"
    "modules/nixos/raspberry-pi.nix"  # Pi-specific hardware support
    "hosts/linux-${name}"
  ]) ++ [{
    nixpkgs.hostPlatform = system;
  }];
  ```

### Step 3: Update Variables (if needed)

If your host has specific metadata, add it to `variables/default.nix`:

```nix
hosts = {
  # ... existing hosts ...
  {hostname} = {
    hostname = "{hostname}";
    system = "{architecture}";        # e.g., "aarch64-darwin"
    description = "Brief description";
  };
};
```

### Step 4: Stage and Test

1. **Stage files for haumea discovery:**
   ```bash
   git add .
   ```
   ⚠️ **Important**: Haumea only sees files tracked by Git!

2. **Test the configuration:**
   ```bash
   # Verify host is discovered
   nix eval .#darwinConfigurations --apply 'builtins.attrNames'  # macOS
   nix eval .#nixosConfigurations --apply 'builtins.attrNames'   # Linux

   # Test build (replace {hostname} with your host name)
   nix eval .#darwinConfigurations.{hostname}.config.system.build.toplevel  # macOS
   nix eval .#nixosConfigurations.{hostname}.config.system.build.toplevel   # Linux
   ```

3. **Deploy the configuration:**
   ```bash
   # macOS
   sudo darwin-rebuild switch --flake .#{hostname}

   # Linux
   sudo nixos-rebuild switch --flake .#{hostname}
   ```

## Technical Details

### Variable Passing

The new architecture uses `myvars` instead of the old `vars` parameter:

```nix
# ✅ Correct (new architecture)
{myvars, pkgs, ...}: {
  users.users.${myvars.user.username} = {
    name = myvars.user.username;
    home = "/Users/${myvars.user.username}";
  };
}

# ❌ Incorrect (old architecture)
{vars, pkgs, ...}: {
  users.users.${vars.user.username} = {
    name = vars.user.username;
    home = "/Users/${vars.user.username}";
  };
}
```

### Module Imports

The outputs system automatically handles module imports, so host configurations should NOT include base imports:

```nix
# ✅ Correct (new architecture)
{myvars, pkgs, ...}: {
  # NOTE: imports are handled by the outputs system

  # Host-specific configuration only
  system.primaryUser = myvars.user.username;
}

# ❌ Incorrect (old architecture)
{myvars, pkgs, ...}: {
  imports = [
    ../../modules/base.nix
    ../../modules/darwin
  ];

  system.primaryUser = myvars.user.username;
}
```

### File Naming

Host files must match the hostname for consistency:
- Host directory: `hosts/darwin-{hostname}/` or `hosts/linux-{hostname}/`
- Outputs file: `outputs/{arch}/src/{hostname}.nix`
- Configuration name: `{hostname}` (available as `darwinConfigurations.{hostname}`)

## Troubleshooting

### Host Not Discovered

**Problem**: `nix eval .#darwinConfigurations --apply 'builtins.attrNames'` doesn't show your host.

**Solutions**:
1. **Check Git staging**: `git add .` (haumea only sees tracked files)
2. **Verify file location**: Ensure outputs file is in correct `outputs/{arch}/src/` directory
3. **Check syntax**: Run `nix flake check` to verify configuration syntax
4. **Architecture mismatch**: Verify you're using the correct architecture directory

### Build Failures

**Problem**: `nix eval .#{hostname}.config.system.build.toplevel` fails.

**Solutions**:
1. **Variable references**: Ensure you're using `myvars` not `vars`
2. **Import statements**: Remove manual imports from host `default.nix`
3. **Missing variables**: Check if host is defined in `variables/default.nix`
4. **Module conflicts**: Verify no conflicting module definitions

### Home Manager Issues

**Problem**: Home Manager configuration fails to build.

**Solutions**:
1. **Profile imports**: Verify profile paths are correct (e.g., `../../home/profiles/darwin`)
2. **Parameter mismatch**: Ensure home.nix accepts correct parameters
3. **Package conflicts**: Check for conflicting package definitions between system and home

### Architecture Detection

**Problem**: Unsure which architecture directory to use.

**Solutions**:
```bash
# Check current system
nix eval --expr 'builtins.currentSystem'

# macOS: System Information → Hardware
# Linux: uname -m

# Architecture mapping:
# x86_64-darwin  → Intel Mac
# aarch64-darwin → Apple Silicon Mac
# x86_64-linux   → Intel/AMD Linux
# aarch64-linux  → ARM64 Linux (Pi, etc.)
```

### Git Staging Reminder

Always remember to stage new files before testing:
```bash
git add .
```

Haumea can only discover files that Git knows about!

## Examples

### Example: Adding a Personal Linux Laptop

```bash
# 1. Create directories
mkdir -p hosts/linux-laptop

# 2. Generate hardware config (on target system)
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix

# 3. Create configurations (use templates above)
# hosts/linux-laptop/default.nix
# hosts/linux-laptop/home.nix

# 4. Create outputs file
# outputs/x86_64-linux/src/laptop.nix

# 5. Add to variables (optional)
# Edit variables/default.nix

# 6. Stage and test
git add .
nix eval .#nixosConfigurations.laptop.config.system.build.toplevel

# 7. Deploy
sudo nixos-rebuild switch --flake .#laptop
```

### Example: Adding a Work MacBook

```bash
# 1. Create directories
mkdir -p hosts/darwin-work

# 2. Create configurations (use templates above)
# hosts/darwin-work/default.nix (with work-specific homebrew apps)
# hosts/darwin-work/home.nix (import work role)

# 3. Create outputs file
# outputs/aarch64-darwin/src/work.nix (if Apple Silicon)

# 4. Stage and test
git add .
nix eval .#darwinConfigurations.work.config.system.build.toplevel

# 5. Deploy
sudo darwin-rebuild switch --flake .#work
```

## Migration from Old Architecture

If you have an existing host using the old architecture:

1. **Rename files**: `system.nix` → `default.nix`
2. **Update parameters**: `vars` → `myvars`
3. **Remove imports**: Delete manual module imports from host config
4. **Create outputs file**: Add corresponding file in `outputs/{arch}/src/`
5. **Update commands**: Use new host naming scheme

The migration maintains full compatibility while providing better scalability and organization.