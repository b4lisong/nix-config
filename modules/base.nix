/*
modules/base.nix

Defines the common system-level configuration shared by both NixOS and Darwin
*/
{
  lib,
  nixpkgs,
  pkgs,
  ...
}: {
  # Define a minimum set of programs for all systems
  environment.systemPackages = with pkgs; [
    # Core tools - Essential command-line utilities
    vim # Ubiquitous text editor with extensive plugin ecosystem
    git # Distributed version control system

    # Archives - File compression and extraction utilities
    zip # Create and extract ZIP archives
    xz # High compression ratio archive format
    zstd # Modern compression algorithm with high speed/ratio balance
    unzipNLS # Extract ZIP archives with international character support
    p7zip # High compression ratio archive format (7z)

    # Text processing
    # Docs: https://github.com/learnbyexample/Command-line-text-processing
    gnugrep # GNU grep, provides `grep`/`egrep`/`fgrep` for pattern matching
    gnused # GNU sed, powerful stream editor for text transformation
    gawk # GNU awk, pattern scanning and processing language
    jq # Lightweight and flexible command-line JSON processor

    # Networking tools - Network diagnostics and utilities
    mtr # Network diagnostic tool combining traceroute and ping
    iperf3 # Network performance measurement tool
    dnsutils # DNS utilities including `dig` and `nslookup`
    ldns # Modern DNS toolkit, provides `drill` command
    wget # Non-interactive network downloader
    curl # Transfer data from or to a server
    aria2 # Multi-threaded download utility supporting multiple protocols
    socat # Multipurpose relay for bidirectional data transfer
    nmap # Network exploration and security auditing tool
    ipcalc # IP address calculator for IPv4/v6 networks

    # Misc - General purpose utilities
    file # Determine file type
    findutils # Find files and directories
    which # Locate a command in PATH
    tree # Display directory structure as tree
    gnutar # GNU version of the tar archiving utility
    rsync # Fast, versatile file copying and synchronization tool
  ];

  # Define a minimum set of fonts for all systems
  fonts.packages = with pkgs; [
    nerd-fonts.sauce-code-pro # Popular coding font with programming ligatures
    nerd-fonts.symbols-only # Icon font for terminal and UI
    font-awesome # Icon toolkit based on CSS and LESS
    material-design-icons # Material Design icon set
    noto-fonts-emoji # Color emoji font with broad Unicode support
    dejavu_fonts # High-quality font family with wide Unicode coverage
  ];

  # Enable modern Nix features:
  # - nix-command: New CLI interface with better UX and features
  # - flakes: Reproducible and composable Nix packages and configurations
  nix.settings.experimental-features = "nix-command flakes";

  # Enable unfree packages @ the system level
  nixpkgs.config.allowUnfree = true;
}
