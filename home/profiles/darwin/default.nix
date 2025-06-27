/*
`home/profiles/darwin/default.nix`
Darwin/macOS Home Manager profile that provides a complete GUI system with macOS optimizations.

This profile imports the cross-platform GUI profile and adds Darwin-specific enhancements.
Every Darwin system is inherently a GUI system, so this profile represents the complete
Darwin experience: GUI applications + macOS-specific integrations and optimizations.
*/
{...}: {
  imports = [
    # Import cross-platform GUI baseline
    ../gui
    
    # Add Darwin-specific enhancements and integrations
    ../../modules/terminal/kitty-darwin.nix
    
    # Future Darwin-specific modules can be added here:
    # ../../modules/editors/vscode-darwin.nix
    # ../../modules/browsers/firefox-darwin.nix
    # ../../modules/media/spotify-darwin.nix
    # ../../modules/desktop/macos-defaults.nix
  ];
}