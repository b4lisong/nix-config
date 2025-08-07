-- Treesitter configuration for enhanced syntax highlighting and parsing
-- Provides better code understanding and manipulation capabilities
return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main', -- Explicitly use main branch for 2024+ compatibility
  build = ':TSUpdate',
  event = { 'BufReadPost', 'BufNewFile' },
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
  },
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'go',
      'gomod', -- Go module files (go.mod, go.sum)
      'html',
      'javascript',
      'json',
      -- 'latex', -- Disabled due to query parsing errors - using built-in LaTeX syntax
      'lua',
      'luadoc',
      'luap',
      'markdown',
      'markdown_inline',
      'python',
      'query',
      'regex',
      'tsx',
      'typescript',
      'vim',
      'vimdoc',
      'yaml',
      'nix',
    },
    auto_install = true,
    highlight = {
      enable = true,
      -- Disable treesitter highlighting for LaTeX due to query parsing issues
      disable = { "latex" },
      additional_vim_regex_highlighting = { "latex" }, -- Use built-in LaTeX syntax
    },
    indent = {
      enable = true,
    },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<C-space>',
        node_incremental = '<C-space>',
        scope_incremental = false,
        node_decremental = '<bs>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        disable = { "latex" }, -- Disable textobjects for LaTeX due to query parsing issues
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        disable = { "latex" }, -- Disable textobjects for LaTeX due to query parsing issues
        goto_next_start = {
          [']f'] = '@function.outer',
          [']c'] = '@class.outer',
        },
        goto_next_end = {
          [']F'] = '@function.outer',
          [']C'] = '@class.outer',
        },
        goto_previous_start = {
          ['[f'] = '@function.outer',
          ['[c'] = '@class.outer',
        },
        goto_previous_end = {
          ['[F'] = '@function.outer',
          ['[C'] = '@class.outer',
        },
      },
    },
  },
  config = function(_, opts)
    -- Override parser configuration for repositories that changed from master to main
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    
    -- Fix gomod parser to use main branch instead of default master
    parser_config.gomod = {
      install_info = {
        url = "https://github.com/camdencheek/tree-sitter-go-mod",
        files = { "src/parser.c" },
        branch = "main", -- Explicitly specify main branch
      },
      maintainers = { "@camdencheek" },
    }
    
    require('nvim-treesitter.configs').setup(opts)
  end,
}