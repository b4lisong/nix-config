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
  ];

  # Auto-setup AstroNvim template on new systems
  home.activation.astronvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    NVIM_CONFIG_DIR="$HOME/.config/nvim"
    
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
        echo "  You can now customize your configuration and manage it independently"
      else
        echo "✗ Failed to clone AstroNvim template from https://github.com/b4lisong/nvim.git"
        echo "  Please check your internet connection and repository access"
      fi
    else
      echo "AstroNvim configuration already exists in ~/.config/nvim - skipping clone"
    fi
  '';

  # Shell aliases for convenience
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim";    # Keep traditional vim for quick edits
    nv = "nvim";  # Neovim with AstroNvim configuration
  };
}