# AstroNvim Auto-Setup Configuration
# Automatically clones personal AstroNvim template for new systems
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Basic neovim package (AstroNvim requires Neovim 0.10+)
  home.packages = with pkgs; [
    neovim
    git # Required for cloning the template
    curl # Used for network connectivity testing in activation script
  ];

  # Auto-setup AstroNvim template on new systems
  home.activation.astronvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    echo "=== AstroNvim Activation Script Starting ==="
    
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    
    # Ensure .config directory exists
    mkdir -p "$HOME/.config"
    
    echo "Checking directory: $NVIM_CONFIG_DIR"
    echo "Directory exists: $(test -d "$NVIM_CONFIG_DIR" && echo "yes" || echo "no")"
    
    if [[ -d "$NVIM_CONFIG_DIR" ]]; then
      echo "Directory contents: $(ls -la "$NVIM_CONFIG_DIR" 2>/dev/null | wc -l) items"
    fi
    
    # Only clone if the directory doesn't exist or is empty
    if [[ ! -d "$NVIM_CONFIG_DIR" ]] || [[ -z "$(ls -A "$NVIM_CONFIG_DIR" 2>/dev/null)" ]]; then
      echo "Setting up AstroNvim from personal template..."
      echo "Git command: ${pkgs.git}/bin/git"
      echo "Target directory: $NVIM_CONFIG_DIR"
      
      # Remove any existing directory to ensure clean setup
      rm -rf "$NVIM_CONFIG_DIR"
      
      # Clone personal AstroNvim template with verbose output
      echo "Attempting clone..."
      if ${pkgs.git}/bin/git clone --depth 1 --verbose https://github.com/b4lisong/nvim.git "$NVIM_CONFIG_DIR"; then
        # Remove .git directory to make it a clean local copy
        rm -rf "$NVIM_CONFIG_DIR/.git"
        echo "✓ AstroNvim template successfully cloned to ~/.config/nvim"
        echo "  Final directory contents:"
        ls -la "$NVIM_CONFIG_DIR"
      else
        echo "✗ Failed to clone AstroNvim template from https://github.com/b4lisong/nvim.git"
        echo "  Git exit code: $?"
        echo "  Please check your internet connection and repository access"
        echo "  Current working directory: $(pwd)"
        echo "  Network test: $(${pkgs.curl}/bin/curl -s -o /dev/null -w "%{http_code}" https://github.com || echo "curl failed")"
      fi
    else
      echo "AstroNvim configuration already exists in ~/.config/nvim - skipping clone"
      echo "Existing contents:"
      ls -la "$NVIM_CONFIG_DIR"
    fi
    
    echo "=== AstroNvim Activation Script Complete ==="
  '';

  # Shell aliases for convenience
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim";    # Keep traditional vim for quick edits
    nv = "nvim";  # Neovim with AstroNvim configuration
  };
}