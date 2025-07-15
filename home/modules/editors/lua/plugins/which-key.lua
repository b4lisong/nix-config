-- WhichKey provides keymap discovery and help menus
-- Displays available keybindings in a popup window
--
-- MAINTENANCE REQUIREMENT:
-- When keybindings are modified in neovim.nix, the descriptions below
-- MUST be updated to stay in sync. This ensures users see accurate
-- documentation when using WhichKey.
--
-- To add new keybinding groups:
-- 1. Add the keybinding to neovim.nix
-- 2. Add corresponding entry to wk.add() below
-- 3. Use format: { "<leader>x", desc = "Description" }
-- 4. For groups: { "<leader>x", group = "Group Name" }

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
    
    -- Add keybinding groups and descriptions
    wk.add({
      { "<leader>c", group = "Code" },
      { "<leader>cf", desc = "Format buffer" },
      { "<leader>w", group = "Window Management" },
      -- Window splitting
      { "<leader>wv", desc = "Split vertically" },
      { "<leader>wh", desc = "Split horizontally" },
      { "<leader>we", desc = "Make splits equal size" },
      { "<leader>wx", desc = "Close current window" },
      { "<leader>wm", desc = "Maximize window" },
      -- Window movement
      { "<leader>wH", desc = "Move window left" },
      { "<leader>wJ", desc = "Move window down" },
      { "<leader>wK", desc = "Move window up" },
      { "<leader>wL", desc = "Move window right" },
      { "<leader>wr", desc = "Rotate windows clockwise" },
      { "<leader>wR", desc = "Rotate windows counter-clockwise" },
      -- Window resizing
      { "<leader>w=", desc = "Equal window sizes" },
      { "<leader>w+", desc = "Increase height" },
      { "<leader>w-", desc = "Decrease height" },
      { "<leader>w>", desc = "Increase width" },
      { "<leader>w<", desc = "Decrease width" },
      { "<leader>w|", desc = "Maximize width" },
      { "<leader>w_", desc = "Maximize height" },
      -- Window navigation
      { "<leader>ww", desc = "Next window" },
      { "<leader>wp", desc = "Previous window" },
      { "<leader>wt", desc = "Top window" },
      { "<leader>wb", desc = "Bottom window" },
    })
  end,
}