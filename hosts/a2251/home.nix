/*
`hosts/a2251/home.nix`
Home Manager configuration for the a2251 host

This file defines the user-level (Home Manager) configuration for the a2251 host.
It imports the appropriate profiles and roles to create a complete user environment
tailored for personal development work on this Intel MacBook Pro.

Host Context:
- Personal MacBook Pro (Intel x86_64)
- Primary development and personal machine
- Used for software development, personal projects, and entertainment

Configuration Strategy:
1. Import darwin profile (complete macOS desktop experience)
   - Includes: base → tui → gui → darwin profiles
   - Provides: CLI tools, TUI apps, GUI apps, macOS optimizations
2. Import personal role (entertainment and personal productivity)
   - Provides: Spotify, Signal, GIMP, Firefox Developer Edition
3. Import dev role (development tools and environments)
   - Provides: Neovim, Node.js, Claude Code

This combination creates a complete environment suitable for:
- Software development and coding
- Personal projects and learning
- Entertainment and communication
- Creative work and productivity

Override Examples:
- Font sizes can be adjusted for this specific display
- Terminal padding can be customized for personal preference
- Application-specific settings can be fine-tuned per host
*/
{lib, ...}: {
  imports = [
    # Complete macOS desktop profile (includes base, tui, gui profiles)
    ../../home/profiles/darwin

    # Role-based package sets for this host's purpose
    ../../home/roles/personal # Entertainment, communication, creative tools
    ../../home/roles/dev # Development tools and environments

    # Additional roles can be imported as needed:
    # ../../home/roles/work     # Work-specific tools (for mixed-use machines)
    # ../../home/roles/security # Security and penetration testing tools
    # ../../home/roles/docker   # Container and orchestration tools
  ];

  # Host-specific Home Manager customizations
  # These override or extend the imported profiles and roles

  # Display and interface customizations for this specific machine
  # (Darwin profile sets font.size = 14 by default for high-DPI displays)
  programs.kitty = {
    # Example host-specific overrides (uncomment and adjust as needed)
    # font.size = lib.mkForce 16;                    # Larger font for this display
    # settings.window_padding_width = lib.mkForce 30; # More padding for aesthetics
    # settings.background_opacity = lib.mkForce "0.9"; # Different transparency
  };

  # Host-specific application configurations
  # These can override profile or role settings for this particular machine
  programs = {
    # Example: Git configuration specific to this host
    # git.extraConfig = {
    #   # Host-specific git settings
    #   core.editor = "cursor"; # Use Cursor as git editor on this machine
    # };

    # Example: Shell aliases specific to this host
    # zsh.shellAliases = {
    #   # Host-specific convenience aliases
    #   dev = "cd ~/Development";
    #   personal = "cd ~/Personal";
    # };
  };

  # Host-specific environment variables
  home.sessionVariables = {
    # Example: Development environment specific to this machine
    # DEVELOPMENT_MODE = "personal"; # Distinguish from work machines
  };
}
