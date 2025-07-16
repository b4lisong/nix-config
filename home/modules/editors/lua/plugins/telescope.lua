-- Telescope fuzzy finder configuration
-- Provides powerful file navigation and search capabilities
return {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    
    telescope.setup({
      defaults = {
        mappings = {
          i = {
            ['<C-u>'] = false,
            ['<C-d>'] = false,
            ['<esc>'] = actions.close,
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
          },
        },
        file_ignore_patterns = {
          "%.git/",
          "node_modules/",
          "%.npm/",
          "%.cache/",
        },
        prompt_prefix = "> ",
        selection_caret = "> ",
        path_display = { "truncate" },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })
    
    -- Load fzf extension if available
    pcall(telescope.load_extension, 'fzf')
  end,
}