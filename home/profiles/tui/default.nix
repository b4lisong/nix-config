/*
`home/profiles/tui/default.nix`
Defines the user-level (Home Manager) packages and configurations
common to TUI systems and Darwin/macOS CLI tools.
Inherits from `/home/profiles/base/default.nix`
*/
{pkgs, ...}: {
  imports = [../base];

  home.packages = with pkgs; [
    # System Monitoring & Analysis
    btop # Resource monitor and process viewer with a beautiful interface
    gping # Ping with a graph, useful for visualizing network latency
    ncdu # Disk usage analyzer with NCurses interface, helps find space hogs

    # File management
    yazi # Terminal file manager with a modern interface and features

    # Security
    _1password-cli # Command-line interface for 1Password password manager
  ];
}
