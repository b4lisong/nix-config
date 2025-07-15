/*
`home/roles/dev/default.nix`
Development tools and environments

This role module provides packages and configurations for software development.
It demonstrates the dual package system by using both stable and unstable packages
based on development needs.

Purpose:
- Groups development-specific tools separately from other applications
- Enables development-focused machine configurations
- Provides both stable and cutting-edge development tools
- Supports various programming languages and development workflows

Usage:
- Imported by hosts used for software development
- Combined with other roles (personal, work) for complete environments
- Demonstrates the stable vs unstable package selection strategy

Architecture:
- Part of the role-based package organization system
- Showcases dual nixpkgs usage (stable + unstable)
- Complements other roles: personal, work, security, docker
- Can be extended with language-specific development environments

Package Selection Strategy:
- Stable packages: Core tools that need reliability (editors, established tools)
- Unstable packages: Rapidly evolving tools where latest features matter
- This approach balances stability with access to cutting-edge development tools
*/
{
  pkgs, # Stable nixpkgs package set
  pkgs-unstable, # Unstable nixpkgs package set (bleeding-edge)
  ...
}: {
  imports = [
    ../../modules/editors/neovim.nix  # Modern neovim with IDE enhancements
  ];

  home.packages = with pkgs; [
    ## Stable packages - reliable, well-tested versions
    # neovim is now provided by the imported neovim.nix module above
    uv # Extremely fast Python package installer and resolver
    gh # GitHub CLI tool
    frogmouth # TUI Markdown viewer

    ## Unstable packages - latest features and versions for development
    # TODO: Revert to unstable nodejs once packaging issue is resolved
    # Issue: https://github.com/NixOS/nixpkgs/issues/423244
    # Temporarily using stable nodejs to avoid build failures
    nodejs # Stable Node.js (was: pkgs-unstable.nodePackages_latest.nodejs)
    pkgs-unstable.claude-code # Latest Claude Code CLI tool

    # Additional development tools can be added here:
    # Stable packages (prefer for core workflow tools):
    # git              # Already in base profile
    # tmux             # Already in base profile
    # docker           # Container runtime (if needed)
    # postgresql       # Database server
    #
    # Unstable packages (prefer for rapidly evolving tools):
    # pkgs-unstable.bun              # Fast JavaScript runtime/bundler
    # pkgs-unstable.deno             # Modern JavaScript/TypeScript runtime
    # pkgs-unstable.go               # Go programming language
    # pkgs-unstable.rustc            # Rust compiler
    # pkgs-unstable.cargo            # Rust package manager
    # pkgs-unstable.python311        # Latest Python version
    # pkgs-unstable.vscode           # Latest VS Code features
  ];

  # Development environment configurations
  programs = {
    # Example development program configurations
    # git = {
    #   # Development-specific git settings (already configured in base profile)
    #   extraConfig = {
    #     # Development workflow settings
    #   };
    # };
  };

  # Development-specific environment variables
  home.sessionVariables = {
    # Example development environment variables
    # NODE_ENV = "development";
    # DEVELOPMENT = "true";
  };
}
