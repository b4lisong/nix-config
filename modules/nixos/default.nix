/*
`modules/nixos/default.nix`
System-level configuration common to all NixOS hosts
Extends base system configuration in `modules/base.nix`

This module serves as the NixOS counterpart to `modules/darwin/default.nix`,
providing Linux-specific system configuration. Currently a placeholder
for future NixOS support when the configuration is extended beyond macOS.

When implemented, this should include:
- NixOS-specific system services and configuration
- Linux hardware management (sound, networking, etc.)
- Desktop environment integration (if applicable)
- User session management
- Package management configuration specific to NixOS

This module gets imported by NixOS hosts in the same way Darwin hosts
import the darwin module, providing a consistent configuration pattern
across platforms.
*/
_: {
  # Placeholder for future NixOS-specific configuration
  # When implemented, this will extend the base configuration with:
  # - Hardware configuration
  # - System services (NetworkManager, systemd services, etc.)
  # - Desktop environment setup
  # - Security policies (firewall, user permissions)
  # - Platform-specific optimizations

  # Add `~/.local/bin` to PATH
  environment.localBinInPath = true;
}
