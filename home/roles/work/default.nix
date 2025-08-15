/*
`home/roles/work/default.nix`
Work-related applications and configurations

This role module provides packages and configurations specifically for
professional/work environments. It's designed to be imported by hosts
that are used primarily for work purposes.

Purpose:
- Groups work-specific applications separately from personal tools
- Enables work-focused machine configurations
- Provides a clear boundary between work and personal software
- Allows for compliance with work policies and requirements

Usage:
- Imported by work machines or work-focused user profiles
- Can be combined with dev role for software development work
- Kept separate from personal role to maintain work/life boundaries

Architecture:
- Part of the role-based package organization system
- Complements other roles: dev, personal, security, docker
- Can include company-specific tools and configurations
- May include compliance and security tools required by employers

Examples of what this role might include when implemented:
- Business communication tools (Slack, Microsoft Teams)
- Office productivity suites
- VPN clients for corporate networks
- Company-specific development tools
- Compliance and monitoring software
- Enterprise security tools
*/
{pkgs, ...}: {
  # Placeholder for work-specific packages and configurations
  # When implemented, this might include:

  home.packages = with pkgs; [
    #   # Communication and collaboration
    #   slack # Team communication
    #   teams # Microsoft Teams for enterprise
    #
    #   # Productivity and office tools
    #   libreoffice # Office suite for documents/spreadsheets
    #   thunderbird # Corporate email client
    #
    #   # VPN and networking
    #   openvpn # Corporate VPN access
    #
    #   # Development tools (work-specific)
    #   postman # API development and testing
    #
    #   # Compliance and security
    #   # Company-specific security agents
    # Browsers
    firefox-devedition
  ];

  # programs = {
  #   # Work-specific program configurations
  #   # These might include corporate settings, certificates, etc.
  # };
}
