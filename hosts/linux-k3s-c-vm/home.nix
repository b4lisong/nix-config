{
  config,
  pkgs,
  ...
}: {
  # Include base profile for essential CLI tools and git configuration
  imports = [
    ../../home/profiles/base
    ../../home/profiles/tui
  ];

  # Enable base shell and essential tools
  # The base profile provides:
  # - Git configuration with user credentials
  # - Essential CLI tools (archives, coreutils, findutils, etc.)
  # - Shell configuration (zsh with starship prompt)

  # Enable TUI applications for terminal-based administration
  # The tui profile provides:
  # - btop for system monitoring
  # - gping for network diagnostics
  # - yazi for file management
  # - Additional terminal utilities

  # No additional host-specific configuration needed for minimal k3s server
}