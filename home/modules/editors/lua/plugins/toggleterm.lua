-- ToggleTerm terminal management for enhanced workflow
-- Provides floating and split terminal windows with persistent sessions
return {
  'akinsho/toggleterm.nvim',
  version = "*",
  event = 'VeryLazy',
  config = function()
    require('toggleterm').setup({
      -- Basic configuration
      size = function(term)
        if term.direction == "horizontal" then
          return 15
        elseif term.direction == "vertical" then
          return vim.o.columns * 0.4
        end
      end,
      open_mapping = [[<C-\>]], -- Ctrl+backslash to toggle
      hide_numbers = true,
      shade_filetypes = {},
      autochdir = false,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      terminal_mappings = true,
      persist_size = true,
      persist_mode = true,
      direction = 'float', -- Default to floating terminal
      close_on_exit = true,
      shell = vim.o.shell,
      auto_scroll = true,
      
      -- Floating terminal configuration
      float_opts = {
        border = 'curved',
        width = function()
          return math.floor(vim.o.columns * 0.8)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.8)
        end,
        winblend = 0,
        highlights = {
          border = "Normal",
          background = "Normal",
        },
      },
      
      -- Window highlighting
      highlights = {
        Normal = {
          guibg = "NONE",
        },
        NormalFloat = {
          link = 'Normal'
        },
        FloatBorder = {
          guifg = "#8AADF4", -- Blue border for visibility
        },
      },
    })
    
    -- Terminal-specific keymaps
    function _G.set_terminal_keymaps()
      local opts = {buffer = 0}
      -- Easy escape from terminal mode
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      -- Window navigation from terminal
      vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
      vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
      vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
      vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
    end
    
    -- Apply terminal keymaps when terminal opens
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
    
    -- Additional keymaps for different terminal orientations
    local keymap = vim.keymap.set
    keymap('n', '<leader>tf', '<cmd>ToggleTerm direction=float<cr>', { desc = 'Toggle floating terminal' })
    keymap('n', '<leader>th', '<cmd>ToggleTerm direction=horizontal<cr>', { desc = 'Toggle horizontal terminal' })
    keymap('n', '<leader>tv', '<cmd>ToggleTerm direction=vertical<cr>', { desc = 'Toggle vertical terminal' })
    keymap('n', '<leader>tt', '<cmd>ToggleTerm direction=tab<cr>', { desc = 'Toggle terminal in new tab' })
    
    -- Terminal instance management
    keymap('n', '<leader>t1', '<cmd>1ToggleTerm<cr>', { desc = 'Toggle terminal 1' })
    keymap('n', '<leader>t2', '<cmd>2ToggleTerm<cr>', { desc = 'Toggle terminal 2' })
    keymap('n', '<leader>t3', '<cmd>3ToggleTerm<cr>', { desc = 'Toggle terminal 3' })
  end,
}