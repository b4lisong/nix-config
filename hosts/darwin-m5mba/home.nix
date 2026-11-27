/*
`hosts/darwin-m5mba/home.nix`
Home Manager configuration for the m5mba host

Personal MacBook Air 15" (M5, early 2026). Same profile and roles as a2251:
- darwin profile: base -> tui -> gui -> darwin
- personal role: entertainment, communication, creative tools
- dev role: development tools

On aarch64-darwin, pkgs-unstable is real nixpkgs-unstable (a2251 sources it
from stable; see docs/x86_64-darwin-eol.md).
*/
{...}: {
  imports = [
    ../../home/profiles/darwin
    ../../home/roles/personal
    ../../home/roles/dev
  ];
}
