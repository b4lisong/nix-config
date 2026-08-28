/*
`home/roles/personal/default.nix`
Personal productivity and entertainment applications

This role module provides packages and configurations for personal use,
including entertainment, communication, and creative applications.
It represents the "personal" aspect of a user's computing environment.

Purpose:
- Groups personal-use applications separately from work/development tools
- Allows hosts to selectively import personal tools based on the machine's purpose
- Enables easy management of personal vs. professional software stacks

Usage:
- Imported by hosts that are used for personal activities
- Can be combined with other roles (dev, work, etc.) on multi-purpose machines
- Provides a clear separation between personal and professional software

Architecture:
- Part of the role-based package organization system
- Complements other roles: dev, work, security, docker
- Can be imported alongside profiles for complete user environments
*/
{pkgs, ...}: {
  home.packages = with pkgs; [
    # Entertainment and Media
    spotify # Music streaming service

    # Communication
    # Signal is installed as a Homebrew cask in modules/darwin/homebrew.nix:
    # nixpkgs replaced the signal-desktop-bin binary package with a
    # build-from-source signal-desktop, whose signal-webrtc dependency does not
    # compile on Darwin (third_party/nasm includes the glibc-only <endian.h>).
    zoom-us # Video conferencing for personal use

    # Web browsing (development edition for personal projects)
    firefox-devedition # Firefox with developer tools and features

    # Additional personal applications can be added here:
    # discord # Gaming and community communication
    # vlc # Media player for various formats
    # obs-studio # Screen recording and streaming
    # keepassxc # Password management
    # thunderbird # Email client
  ];

  # Personal application configurations
  programs = {
    # Example personal program configurations
    # firefox = {
    #   enable = true;
    #   profiles.personal = {
    #     # Personal browsing profile settings
    #   };
    # };
  };
}
