/*
`hosts/sksm3/home.nix`
Home Manager configuration for the sksm3 host

This file defines the user-level (Home Manager) configuration for the sksm3 host.
It imports the appropriate profiles and roles to create a complete user environment
tailored for (mostly) professional work on this Apple Silicon MacBook.

Host Context:
- Work MacBook (Apple Silicon aarch64-darwin)
- Professional development and work machine
- Used for software development, penetration testing, and administrative tasks

Configuration Strategy:
1. Import darwin profile (complete macOS desktop experience)
   - Includes: base → tui → gui → darwin profiles
   - Provides: CLI tools, TUI apps, GUI apps, macOS optimizations
2. Import dev role (development tools and environments)
   - Provides: Neovim, Node.js, Claude Code
3. Import work role (work-specific tools and configurations)
   - Provides: Professional tools and compliance requirements
   - Currently minimal but ready for work-specific extensions

This combination creates a complete environment suitable for:
- Software development and coding
- Professional work and collaboration
- Corporate compliance and security
- Work-focused productivity without personal entertainment

Override Examples:
- Font sizes can be adjusted for this specific display
- Terminal padding can be customized for work preference
- Application-specific settings can be fine-tuned per host
- Work-specific configurations can override personal defaults
*/
{lib, ...}: {
  imports = [
    # Complete macOS desktop profile (includes base, tui, gui profiles)
    ../../home/profiles/darwin

    # Role-based package sets for this work host's purpose
    ../../home/roles/dev # Development tools and environments
    ../../home/roles/work # Work-specific tools and configurations

    # Note: personal role excluded for work machine
    # ../../home/roles/personal # Entertainment, communication, creative tools
    
    # Additional roles can be imported as needed:
    # ../../home/roles/security # Security and penetration testing tools
  ];

  # Host-specific Home Manager customizations
  # These override or extend the imported profiles and roles

  # Display and interface customizations for this specific machine
  # (Darwin profile sets font.size = 14 by default for high-DPI displays)
  programs.kitty = {
    # Example host-specific overrides (uncomment and adjust as needed)
    # font.size = lib.mkForce 16;                    # Larger font for this display
    # settings.window_padding_width = lib.mkForce 20; # Professional padding
    # settings.background_opacity = lib.mkForce "1.0"; # Solid background for work
  };

  # Host-specific application configurations
  # These can override profile or role settings for this particular machine
  programs = {
    # Work-specific Git configuration
    # git.extraConfig = {
    #   # Work-specific git settings
    #   user.email = lib.mkForce "work-email@company.com"; # Override personal email
    #   core.editor = "cursor"; # Use Cursor as git editor on work machine
    # };

    # Work-focused shell aliases
    # zsh.shellAliases = {
    #   # Work-specific convenience aliases
    #   work = "cd ~/Work";
    #   projects = "cd ~/Work/Projects";
    #   docs = "cd ~/Work/Documentation";
    # };
  };

  # Host-specific environment variables
  home.sessionVariables = {
    # Work environment identification
    # DEVELOPMENT_MODE = "work"; # Distinguish from personal machines
    # WORK_ENVIRONMENT = "true"; # Flag for work-specific tooling
  };
}
