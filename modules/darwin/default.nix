/*
System-level configuration common to all Darwin/macOS hosts
Extends base system configuration in `modules/base.nix`
*/
{ pkgs, ... }:
{
  # Enable Touch ID authentication for sudo
  # This allows using fingerprint authentication when running sudo commands
  security.pam.services.sudo_local.touchIdAuth = true;

  # System state version for compatibility
  # This should be incremented when making breaking changes to the system configuration
  system.stateVersion = 6;
}
