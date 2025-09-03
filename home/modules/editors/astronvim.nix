# AstroNvim Auto-Setup Configuration
# Automatically clones personal AstroNvim template for new systems
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Create a setup script that can be run independently
  astronvimSetupScript = pkgs.writeShellScriptBin "astronvim-setup" ''
    set -e
    
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    SETUP_MARKER="$HOME/.config/astronvim-setup-done"
    
    # Exit if already set up
    if [[ -f "$SETUP_MARKER" ]]; then
      echo "AstroNvim already set up (marker file exists)"
      exit 0
    fi
    
    echo "=== AstroNvim Setup Starting ==="
    
    # Ensure .config directory exists
    mkdir -p "$HOME/.config"
    
    echo "Checking directory: $NVIM_CONFIG_DIR"
    
    # Only clone if the directory doesn't exist or is empty
    if [[ ! -d "$NVIM_CONFIG_DIR" ]] || [[ -z "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]]; then
      echo "Setting up AstroNvim from personal template..."
      
      # Remove any existing directory to ensure clean setup
      rm -rf "$NVIM_CONFIG_DIR"
      
      # Clone personal AstroNvim template
      if ${pkgs.git}/bin/git clone --depth 1 https://github.com/b4lisong/nvim.git "$NVIM_CONFIG_DIR"; then
        # Remove .git directory to make it a clean local copy
        rm -rf "$NVIM_CONFIG_DIR/.git"
        echo "✓ AstroNvim template successfully cloned to ~/.config/nvim"
        
        # Create marker file to prevent future runs
        touch "$SETUP_MARKER"
        echo "✓ Setup marker created"
      else
        echo "✗ Failed to clone AstroNvim template"
        exit 1
      fi
    else
      echo "AstroNvim configuration already exists - creating marker to skip future runs"
      touch "$SETUP_MARKER"
    fi
    
    echo "=== AstroNvim Setup Complete ==="
  '';
in {
  # Basic neovim package (AstroNvim requires Neovim 0.10+)
  home.packages = with pkgs; [
    neovim
    git
    astronvimSetupScript # Make the setup script available
  ];

  # Try both activation script (for Darwin) and systemd service (for NixOS)
  home.activation.astronvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    # Run the setup script during activation
    ${astronvimSetupScript}/bin/astronvim-setup || echo "AstroNvim setup via activation failed, will try systemd service"
  '';

  # Systemd user service for NixOS systems
  systemd.user.services.astronvim-setup = lib.mkIf pkgs.stdenv.isLinux {
    Unit = {
      Description = "AstroNvim Initial Setup";
      After = ["network-online.target"];
      Wants = ["network-online.target"];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${astronvimSetupScript}/bin/astronvim-setup";
      RemainAfterExit = true;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };

  # Shell aliases for convenience
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim";    # Keep traditional vim for quick edits
    nv = "nvim";  # Neovim with AstroNvim configuration
  };
}