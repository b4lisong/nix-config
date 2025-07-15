-- WhichKey provides keymap discovery and help menus
-- Displays available keybindings in a popup window

return {
  'folke/which-key.nvim',
  event = 'VeryLazy',
  opts = {
    -- Use default settings for initial setup
  },
  keys = {
    {
      '<leader>?',
      function()
        require('which-key').show({ global = false })
      end,
      desc = 'Buffer Local Keymaps'
    },
  },
  config = function(_, opts)
    local wk = require('which-key')
    wk.setup(opts)
  end,
}