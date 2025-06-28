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
      
      " === PREPARATION FOR FUTURE PLUGINS ===
      
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
    
    # Language servers and IDE tools
    # These packages provide intelligent language features
    extraPackages = with pkgs; [
      # Language servers for IDE intelligence
      nixd                                    # Nix language server (modern, feature-rich)
      nodePackages.typescript-language-server # TypeScript/JavaScript LSP
      lua-language-server                     # Lua LSP (for neovim config)
      python-lsp-server                       # Python LSP with good plugin ecosystem
      vscode-langservers-extracted           # JSON, HTML, CSS, ESLint language servers
      
      # Additional development tools
      # ripgrep  # Already in base profile - used by telescope
      # fd       # Already in base profile - used by telescope
      # alejandra # Already in base profile - used by nixd for formatting
    ];
    
    # Plugin configuration - Building IDE capabilities incrementally
    plugins = with pkgs.vimPlugins; [
      # Phase 1: Treesitter - Modern syntax highlighting and parsing
      # Provides foundation for better highlighting, folding, and future IDE features
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          lua << EOF
          require('nvim-treesitter.configs').setup {
            -- Enable syntax highlighting
            highlight = {
              enable = true,
              -- Disable vim regex highlighting in favor of treesitter
              additional_vim_regex_highlighting = false,
            },
            
            -- Enable incremental selection based on treesitter
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "gnn",    -- Start selection
                node_incremental = "grn",  -- Increment to next node
                scope_incremental = "grc", -- Increment to next scope
                node_decremental = "grm",  -- Decrement to previous node
              },
            },
            
            -- Enable indentation based on treesitter
            indent = {
              enable = true,
            },
            
            -- Enable treesitter-based folding
            -- This will be configured in the main vim config
          }
          EOF
        '';
      }

      # Phase 2: Telescope - Fuzzy finding and project navigation
      # Dependency for telescope (required)
      plenary-nvim
      
      # Telescope: Highly extendable fuzzy finder
      {
        plugin = telescope-nvim;
        config = ''
          lua << EOF
          local telescope = require('telescope')
          local actions = require('telescope.actions')
          
          telescope.setup {
            defaults = {
              -- Default configuration for telescope
              prompt_prefix = "🔍 ",
              selection_caret = "➤ ",
              path_display = { "truncate" },
              
              -- File and text search configuration
              file_ignore_patterns = {
                "node_modules/.*",
                "%.git/.*",
                "%.DS_Store",
                "target/.*",
                "build/.*",
                "dist/.*",
              },
              
              -- Use existing tools from base profile
              vimgrep_arguments = {
                "rg",
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
                "--smart-case",
                "--hidden",
                "--glob=!.git/",
              },
              
              -- Keymaps within telescope
              mappings = {
                i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                  ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                  ["<Esc>"] = actions.close,
                },
                n = {
                  ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                },
              },
            },
            
            pickers = {
              -- File finder configuration
              find_files = {
                hidden = true,  -- Show hidden files
                follow = true,  -- Follow symlinks
                -- Use fd from base profile for fast file finding
                find_command = { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" },
              },
              
              -- Live grep configuration
              live_grep = {
                additional_args = function()
                  return { "--hidden", "--glob=!.git/" }
                end,
              },
              
              -- Buffer configuration
              buffers = {
                show_all_buffers = true,
                sort_mru = true,  -- Sort by most recently used
                mappings = {
                  i = {
                    ["<C-d>"] = actions.delete_buffer,
                  },
                },
              },
            },
          }
          EOF
        '';
      }
      
      # Phase 3: Language Server Protocol - IDE Intelligence
      # LSP Configuration for intelligent language features
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          local lspconfig = require('lspconfig')
          local capabilities = vim.lsp.protocol.make_client_capabilities()
          
          -- Common LSP configuration function
          local on_attach = function(client, bufnr)
            -- Enable completion triggered by <c-x><c-o>
            vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
            
            -- Buffer local mappings
            local bufopts = { noremap=true, silent=true, buffer=bufnr }
            
            -- Core LSP navigation
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
            vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
            vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<CR>', bufopts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
            vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
            
            -- Documentation and help
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
            vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
            
            -- Code actions and refactoring
            vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
            vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
            vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format { async = true } end, bufopts)
            
            -- Workspace management
            vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
            vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
            vim.keymap.set('n', '<leader>wl', function()
              print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
            end, bufopts)
          end
          
          -- Configure diagnostic signs and display
          local signs = { Error = "✗", Warn = "⚠", Hint = "💡", Info = "ℹ" }
          for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
          end
          
          -- Configure diagnostic display
          vim.diagnostic.config({
            virtual_text = {
              prefix = '●',
              source = "if_many",
            },
            signs = true,
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = {
              border = 'rounded',
              source = 'always',
              header = '',
              prefix = '',
            },
          })
          
          -- Language server configurations
          
          -- Nix language server (for your configuration files)
          lspconfig.nixd.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              nixd = {
                nixpkgs = {
                  expr = "import <nixpkgs> { }",
                },
                formatting = {
                  command = { "alejandra" },
                },
                options = {
                  nixos = {
                    expr = "(builtins.getFlake \"/path/to/your/flake\").nixosConfigurations.your-host.options",
                  },
                  home_manager = {
                    expr = "(builtins.getFlake \"/path/to/your/flake\").homeConfigurations.your-user.options",
                  },
                },
              },
            },
          })
          
          -- TypeScript/JavaScript language server
          lspconfig.ts_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
          })
          
          -- Lua language server (for neovim configuration)
          lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              Lua = {
                runtime = {
                  version = 'LuaJIT',
                },
                diagnostics = {
                  globals = {'vim'},
                },
                workspace = {
                  library = vim.api.nvim_get_runtime_file("", true),
                  checkThirdParty = false,
                },
                telemetry = {
                  enable = false,
                },
              },
            },
          })
          
          -- Python language server
          lspconfig.pylsp.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
              pylsp = {
                plugins = {
                  pycodestyle = {
                    ignore = {'W391'},
                    maxLineLength = 100,
                  }
                }
              }
            }
          })
          
          -- JSON language server
          lspconfig.jsonls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
          
          EOF
        '';
      }
      
      # Future plugins (Phase 4):
      # Phase 4: nvim-cmp (completion)
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