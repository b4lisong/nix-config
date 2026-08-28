# Planning for the x86_64-darwin End of Life

`darwin-a2251` is an Intel MacBook Pro (`x86_64-darwin`). Nixpkgs is dropping
that platform, so this host cannot follow the rest of the fleet past 26.05.
This document records the deadline, what has already been done, and what the
eventual split requires.

## The deadline

Nixpkgs 26.05 is the final release supporting `x86_64-darwin`. From the
[26.05 release announcement](https://nixos.org/blog/announcements/2026/nixos-2605/):

> This will be the last release of Nixpkgs to support x86_64-darwin. Platform
> support will be maintained and binaries built until Nixpkgs 26.05 goes out of
> support at the end of 2026.

> For 26.11, due to Apple's deprecation of the platform and limited build
> infrastructure and developer time, we will no longer build packages for
> x86_64-darwin or support building them from source.

Two dates matter:

- **End of 2026**: 26.05 goes out of support. Binaries stop being built and
  security fixes stop.
- **26.11**: the platform is removed outright. Source builds are not a fallback
  because the macOS 28.0 SDK does not ship x86_64 stubs.

The removal is an unconditional `throwIf` in `pkgs/top-level/default.nix`
(commit `90796a20f316`, 2026-06-21). It fires at import time rather than per
package, and there is no `allowUnsupportedSystem` escape hatch. Any
`import nixpkgs { system = "x86_64-darwin"; }` against 26.11 aborts evaluation.

## What is already in place

The 26.05 upgrade (commit `aeccfc6`) pinned matched release branches:

```nix
nixpkgs.url      = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
nix-darwin.url   = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
home-manager.url = "github:nix-community/home-manager/release-26.05";
```

nix-darwin must track a release branch rather than `master`. It asserts that
its release equals the Nixpkgs release, and `master` follows
`nixpkgs-unstable`, so the pairing breaks as soon as unstable moves on.

`outputs/default.nix` also routes the unstable package set for this host:

```nix
unstableFor =
  system: if system == "x86_64-darwin" then inputs.nixpkgs else inputs.nixpkgs-unstable;
```

This exists because `nixpkgs-unstable` is already 26.11 and already throws for
`x86_64-darwin`. Sourcing `pkgs-unstable` from 26.05 instead is not a downgrade
in practice: 26.05 carried Go 1.26.6 against 1.26.3 in the last pre-drop
unstable, and 26.05 still receives security fixes.

## Why `unstableFor` is not sufficient on its own

`unstableFor` only selects the source for `pkgs-unstable`. The package set the
system is actually built from comes from a separate path in
`lib/macosSystem.nix`:

```nix
inherit (inputs) nixpkgs home-manager nix-darwin;
...
nixpkgs.pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
```

That is the main `nixpkgs` input, which `unstableFor` does not touch. Bumping
`nixpkgs.url` to 26.11 for the Linux hosts would therefore break this host,
regardless of how `pkgs-unstable` is routed.

## What the split requires

To let the Linux hosts advance while `darwin-a2251` stays on 26.05:

1. Add a nixpkgs input pinned to 26.05, for example
   `nixpkgs-darwin-intel.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin"`.
2. Add a nix-darwin input pinned to `nix-darwin-26.05`, with
   `inputs.nixpkgs.follows` pointing at the pinned nixpkgs. The release
   assertion makes this mandatory, not optional.
3. Add a home-manager input pinned to `release-26.05`, following the same
   pinned nixpkgs.
4. Parameterize `lib/macosSystem.nix` to take which nixpkgs, nix-darwin, and
   home-manager to build from, selected by system, instead of inheriting the
   globals.
5. Handle `forAllSystems` in `outputs/default.nix`. It builds `devShells` and
   `formatter` via `nixpkgs.legacyPackages.${system}` for every system
   including `x86_64-darwin`, which throws under a 26.11 main nixpkgs. Either
   route those to the pinned input or drop `x86_64-darwin` from the list.

Scoping by system is equivalent to scoping by host here. `darwin-a2251` is the
only `x86_64-darwin` host, and `darwin-sksm3` is `aarch64-darwin`, so a
`system == "x86_64-darwin"` branch affects exactly one machine.

## When to act

Nothing breaks until `nixpkgs.url` is bumped past 26.05, and 26.05 is supported
through December 2026. The trigger is the first time a Linux host needs
something from 26.11.

After the end of 2026 the pinned 26.05 stops receiving security fixes. At that
point the choice is to accept a frozen, unpatched package set on this host or
retire it from the flake. Retiring means deleting
`outputs/x86_64-darwin/src/a2251.nix` and `hosts/darwin-a2251/`, and removing
the `x86_64-darwin` entry from `darwinSystems` in `outputs/default.nix`.

## Related notes

Signal is installed as a Homebrew cask rather than a Nix package on Darwin.
Nixpkgs replaced the `signal-desktop-bin` binary package with a
build-from-source `signal-desktop`, whose `signal-webrtc` dependency does not
compile on Darwin because `third_party/nasm` includes the glibc-only
`endian.h`. This is independent of the platform removal and affects Apple
Silicon as well.

Evaluating anything for `x86_64-darwin` against 26.05 emits:

```
evaluation warning: Nixpkgs 26.05 will be the last release to support x86_64-darwin
```

This cannot be fixed while the host exists. It is a standing exception to the
rule in `CLAUDE.md` that warnings are treated as blocking.
