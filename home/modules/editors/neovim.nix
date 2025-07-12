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

    # Lua configuration for lazy.nvim plugins
    # Since extraFiles doesn't exist, we'll manage lua files through the Nix store
    # and reference them in extraLuaConfig or put them in ~/.config/nvim/lua manually

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

      " === TELESCOPE FILE NAVIGATION ===

      " Enhanced file navigation with telescope fuzzy finding
      nnoremap <Leader>ff <cmd>Telescope find_files<CR>
      nnoremap <Leader>fb <cmd>Telescope buffers<CR>
      nnoremap <Leader>fg <cmd>Telescope live_grep<CR>
      nnoremap <Leader>fh <cmd>Telescope help_tags<CR>
      nnoremap <Leader>fc <cmd>Telescope commands<CR>
      nnoremap <Leader>fk <cmd>Telescope keymaps<CR>

      " Git integration (when in git repo)
      nnoremap <Leader>gf <cmd>Telescope git_files<CR>
      nnoremap <Leader>gc <cmd>Telescope git_commits<CR>
      nnoremap <Leader>gb <cmd>Telescope git_branches<CR>

      " === LSP INTEGRATION WITH TELESCOPE ===

      " LSP symbol navigation (enhanced by telescope)
      nnoremap <Leader>ls <cmd>Telescope lsp_document_symbols<CR>
      nnoremap <Leader>lw <cmd>Telescope lsp_workspace_symbols<CR>
      nnoremap <Leader>ld <cmd>Telescope diagnostics<CR>
      nnoremap <Leader>li <cmd>Telescope lsp_implementations<CR>
      nnoremap <Leader>lt <cmd>Telescope lsp_type_definitions<CR>

      " === DIAGNOSTIC NAVIGATION ===

      " Navigate between diagnostics (errors, warnings, etc.)
      nnoremap ]d <cmd>lua vim.diagnostic.goto_next()<CR>
      nnoremap [d <cmd>lua vim.diagnostic.goto_prev()<CR>
      nnoremap <Leader>dl <cmd>lua vim.diagnostic.setloclist()<CR>
      nnoremap <Leader>df <cmd>lua vim.diagnostic.open_float()<CR>

      " Folding controls (enhanced by treesitter)
      nnoremap <Leader>zo :foldopen<CR>
      nnoremap <Leader>zc :foldclose<CR>
      nnoremap <Leader>za :foldopen!<CR>
      nnoremap <Leader>zm :foldclose!<CR>

      " === TREESITTER ENHANCEMENTS ===

      " Enable treesitter-based folding (better than syntax-based)
      if has('nvim')
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable  " Start with folds open
        set foldlevel=99  " High fold level means most folds will be open

        " Treesitter-based text objects and navigation
        " These will be enhanced as we add more treesitter features
      endif

      " === PLUGIN OPTIMIZATION SETTINGS ===

      " Better completion experience (for LSP integration)
      set completeopt=menu,menuone,noselect

      " Shorter update time for better responsiveness
      set updatetime=250

      " Always show sign column to prevent layout shifts
      set signcolumn=yes

      " Better split behavior for plugin windows
      set splitbelow
      set splitright

      " === LAZY.NVIM INITIALIZATION ===

      " Bootstrap lazy.nvim plugin manager
      lua << EOF
      local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
      if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
          "git",
          "clone",
          "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable",
          lazypath,
        })
      end
      vim.opt.rtp:prepend(lazypath)

      -- Setup lazy.nvim to load all plugins
      require("lazy").setup("plugins", {
        root = vim.fn.stdpath("data") .. "/lazy",
        lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
        performance = {
          rtp = {
            disabled_plugins = {
              "gzip",
              "matchit",
              "matchparen",
              "netrwPlugin",
              "tarPlugin",
              "tohtml",
              "tutor",
              "zipPlugin",
            },
          },
        },
        ui = {
          border = "rounded",
        },
        change_detection = {
          notify = false,
        },
      })
      EOF
    '';

    # Configure neovim package and build options
    package = pkgs.neovim-unwrapped;

    # System-level tools and language servers
    # These are managed by Nix for reproducibility and system integration
    extraPackages = with pkgs; [
      # Language servers for IDE intelligence (system dependencies)
      nixd # Nix language server (modern, feature-rich)
      nodePackages.typescript-language-server # TypeScript/JavaScript LSP
      lua-language-server # Lua LSP (for neovim config)
      python3Packages.python-lsp-server # Python LSP with good plugin ecosystem
      vscode-langservers-extracted # JSON, HTML, CSS, ESLint language servers

      # Development tools (system dependencies)
      # ripgrep  # Already in base profile - used by telescope
      # fd       # Already in base profile - used by telescope
      # alejandra # Already in base profile - used by nixd for formatting
    ];

    # All plugins now managed by lazy.nvim for flexibility and performance
    # This provides a clean separation: Nix manages system tools, lazy.nvim manages editor plugins
    plugins = [];
  };

  # Neovim-specific environment variables
  # Note: EDITOR and VISUAL are not set here to allow gradual transition
  # Users can explicitly use 'nv' or 'nvim' when they want IDE features
  home.sessionVariables = {
    # Future: Can set EDITOR = "nvim" when ready for full transition
  };

  # Shell aliases for neovim
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    v = "vim"; # Keep v for traditional vim (quick edits)
    nv = "nvim"; # Explicit neovim alias for IDE features
  };

  # Place Lua plugin files in the correct location for lazy.nvim
  home.file = {
    ".config/nvim/lua/plugins/init.lua".source = ./lua/plugins/init.lua;
    ".config/nvim/lua/plugins/telescope.lua".source = ./lua/plugins/telescope.lua;
    ".config/nvim/lua/plugins/treesitter.lua".source = ./lua/plugins/treesitter.lua;
    ".config/nvim/lua/plugins/lsp.lua".source = ./lua/plugins/lsp.lua;
    ".config/nvim/lua/plugins/completion.lua".source = ./lua/plugins/completion.lua;
    ".config/nvim/lua/plugins/lualine.lua".source = ./lua/plugins/lualine.lua;
    ".config/nvim/lua/plugins/catppuccin.lua".source = ./lua/plugins/catppuccin.lua;
    ".config/nvim/lua/plugins/neo-tree.lua".source = ./lua/plugins/neo-tree.lua;
    ".config/nvim/lua/plugins/toggleterm.lua".source = ./lua/plugins/toggleterm.lua;
  };
}
