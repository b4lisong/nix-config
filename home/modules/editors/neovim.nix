/*
`home/modules/editors/neovim.nix`
Neovim configuration with shared vim settings and IDE enhancements

This module configures neovim to use the shared vim configuration as a foundation
while adding neovim-specific features and modern IDE capabilities. This approach
allows for incremental enhancement while maintaining compatibility with vim.

Architecture:
- Sources shared-vim-config.vim for consistent base behavior with vim
- Adds neovim-specific enhancements (better terminal integration, modern features)
- Provides foundation for future IDE features (LSP, plugins, etc.)
- Uses Home Manager's programs.neovim module for advanced configuration

Future Enhancement Areas:
- Language Server Protocol (LSP) integration
- Plugin management (treesitter, telescope, completion, etc.)
- Advanced key mappings for IDE features
- Git integration and workflow tools
*/
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    
    # Use stable neovim from nixpkgs for reliability
    # Future: Could switch to unstable for bleeding-edge features
    
    # Don't make neovim the default editor yet (gradual transition)
    defaultEditor = false;
    
    # Don't override vi and vim aliases (let them point to traditional vim)
    vimAlias = false;
    viAlias = false;
    
    # Additional neovim-specific configuration
    extraConfig = ''
      " === NEOVIM-SPECIFIC CONFIGURATION ===
      
      " Source shared vim/neovim configuration first
      " This provides the same foundation as vim.nix
      source ${./shared-vim-config.vim}
      
      " === NEOVIM ENHANCEMENTS ===
      
      " Better terminal integration (neovim-specific)
      if has('nvim')
        " Terminal mode key mappings
        tnoremap <Esc> <C-\><C-n>
        tnoremap <C-h> <C-\><C-n><C-w>h
        tnoremap <C-j> <C-\><C-n><C-w>j
        tnoremap <C-k> <C-\><C-n><C-w>k
        tnoremap <C-l> <C-\><C-n><C-w>l
        
        " Better terminal window navigation
        nnoremap <C-h> <C-w>h
        nnoremap <C-j> <C-w>j
        nnoremap <C-k> <C-w>k
        nnoremap <C-l> <C-w>l
        
        " Open terminal in split
        nnoremap <Leader>t :split<CR>:terminal<CR>:startinsert<CR>
        nnoremap <Leader>vt :vsplit<CR>:terminal<CR>:startinsert<CR>
      endif
      
      " === MODERN NEOVIM FEATURES ===
      
      " Use system clipboard (neovim handles this better than vim)
      if has('nvim')
        set clipboard+=unnamedplus
      endif
      
      " Better search highlighting (neovim-specific improvements)
      if has('nvim')
        " Highlight search results as you type (incremental)
        set inccommand=split
      endif
      
      " === FUTURE IDE ENHANCEMENTS ===
      
      " Placeholder for LSP configuration
      " Will be expanded as we add language server support
      
      " Placeholder for plugin configuration
      " Will be expanded as we add plugins via Home Manager
      
      " === DEVELOPMENT WORKFLOW ===
      
      " Quick save and source config
      nnoremap <Leader>w :w<CR>
      nnoremap <Leader>so :source $MYVIMRC<CR>
      
      " Buffer navigation
      nnoremap <Leader>bn :bnext<CR>
      nnoremap <Leader>bp :bprevious<CR>
      nnoremap <Leader>bd :bdelete<CR>
      
      " Quick file navigation (will be enhanced with telescope later)
      nnoremap <Leader>ff :find<Space>
      nnoremap <Leader>fb :buffers<CR>
      
      " === PREPARATION FOR PLUGINS ===
      
      " These settings optimize neovim for future plugin integration
      
      " Better completion experience (for future LSP integration)
      set completeopt=menu,menuone,noselect
      
      " Shorter update time for better responsiveness
      set updatetime=250
      
      " Always show sign column to prevent layout shifts
      set signcolumn=yes
      
      " Better split behavior for future plugin windows
      set splitbelow
      set splitright
    '';
    
    # Configure neovim package and build options
    package = pkgs.neovim-unwrapped;
    
    # Neovim-specific packages (can be extended as we add features)
    # These don't affect vim, only neovim
    extraPackages = with pkgs; [
      # Future: Language servers can be added here
      # nodePackages.typescript-language-server
      # lua-language-server
      # rust-analyzer
      
      # Future: Additional tools for IDE features
      # ripgrep  # Already in base profile
      # fd       # Already in base profile
    ];
    
    # Plugin configuration (currently empty, will be expanded)
    plugins = [
      # Future: Plugins will be added here as we enhance IDE capabilities
      # pkgs.vimPlugins.nvim-lspconfig
      # pkgs.vimPlugins.nvim-treesitter
      # pkgs.vimPlugins.telescope-nvim
      # pkgs.vimPlugins.nvim-cmp
    ];
  };
  
  # Neovim-specific environment variables
  # Note: EDITOR and VISUAL are not set here to allow gradual transition
  # Users can explicitly use 'nv' or 'nvim' when they want IDE features
  home.sessionVariables = {
    # Future: Can set EDITOR = "nvim" when ready for full transition
  };
  
  # Shell aliases for neovim
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim";     # Keep v for traditional vim (quick edits)
    nv = "nvim";   # Explicit neovim alias for IDE features
  };
}