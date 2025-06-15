{ pkgs, ... }:

{
  /*
    Base Fonts Configuration
    
    Essential fonts that should be available on ALL systems regardless of OS.
    This is the minimum font set that every machine should have for:
    - Terminal and development work
    - Basic UI and system needs
    - Proper symbol and emoji support
    
    Additional specialized fonts can be added by:
    - Individual systems (systems/darwin/, systems/nixos/)
    - Individual hosts (hosts/darwin/*, hosts/nixos/*)
    - Specific modules for specialized use cases
  */

  fonts.packages = with pkgs; [
    # === ESSENTIAL PROGRAMMING FONTS ===
    # Nerd Fonts for terminal and development work
    nerd-fonts.sauce-code-pro      # SauceCodePro Nerd Font (based on Source Code Pro)
    nerd-fonts.symbols-only        # Essential symbols for terminal prompts and status bars
    
    # Terminal enhancement fonts
    powerline-fonts                # Powerline-patched fonts for enhanced terminal prompts
    
    # === ICON FONTS ===
    # Essential icon fonts for UI applications and development
    font-awesome                   # Font Awesome icons (widely used across applications)
    material-design-icons          # Material Design icons (Google standard)
    
    # === EMOJI SUPPORT ===
    # Universal emoji support across all systems
    noto-fonts-emoji              # Google Noto emoji fonts (comprehensive emoji coverage)
    
    # === CORE SYSTEM FONTS ===
    # High-quality general-purpose fonts for documents and UI
    dejavu_fonts                  # DejaVu family (Sans, Serif, Mono) - excellent fallback fonts
  ];
}