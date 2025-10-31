{
  config,
  pkgs,
  lib,
  ...
}: {
  # Include base profile for essential CLI tools and git configuration
  imports = [
    ../../home/profiles/base
    ../../home/profiles/tui
    ../../home/roles/docker
  ];

  # Override home directory to avoid conflict with Incus VM module
  home.homeDirectory = lib.mkForce "/home/balisong";

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

  # Enable Docker role for container management tools
  # The docker role provides:
  # - docker-compose and container orchestration tools
  # - Docker CLI utilities and helpers
}
