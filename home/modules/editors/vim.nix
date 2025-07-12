/*
`home/modules/editors/vim.nix`
Vim configuration using shared vim settings

This module configures vim to use the shared vim configuration file that
contains settings compatible with both vim and neovim. This ensures
consistency between both editors while allowing each to have specific
enhancements.

Architecture:
- Sources shared-vim-config.vim for all common settings
- Provides a stable vim environment for fallback/compatibility
- Allows neovim to build upon the same foundation
*/
_: {
  programs.vim = {
    enable = true;

    # Source the shared vim configuration file
    # This file contains all settings that work in both vim and neovim
    extraConfig = ''
      " Source shared vim/neovim configuration
      " This provides consistent behavior between both editors
      source ${./shared-vim-config.vim}

      " Vim-specific settings can be added here if needed
      " (Currently all settings are shared between vim and neovim)
    '';
  };
}
