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
      -- Code operations
      { "<leader>c", group = "Code" },
      { "<leader>cf", desc = "Format buffer" },
      
      -- Buffer operations
      { "<leader>b", group = "Buffers" },
      { "<leader>bn", desc = "Next buffer" },
      { "<leader>bp", desc = "Previous buffer" },
      { "<leader>bd", desc = "Delete buffer" },
      
      -- Find/File operations
      { "<leader>f", group = "Find" },
      { "<leader>ff", desc = "Find files" },
      { "<leader>fb", desc = "Find buffers" },
      { "<leader>fg", desc = "Live grep" },
      { "<leader>fh", desc = "Help tags" },
      { "<leader>fc", desc = "Commands" },
      { "<leader>fk", desc = "Keymaps" },
      
      -- Git operations
      { "<leader>g", group = "Git" },
      { "<leader>gf", desc = "Git files" },
      { "<leader>gc", desc = "Git commits" },
      { "<leader>gb", desc = "Git branches" },
      
      -- LSP operations
      { "<leader>l", group = "LSP" },
      { "<leader>ls", desc = "Document symbols" },
      { "<leader>lw", desc = "Workspace symbols" },
      { "<leader>ld", desc = "Diagnostics" },
      { "<leader>li", desc = "Implementations" },
      { "<leader>lt", desc = "Type definitions" },
      
      -- LSP Actions (standard keybindings from on_attach)
      { "gd", desc = "Go to definition" },
      { "gD", desc = "Go to declaration" },
      { "gi", desc = "Go to implementation" },
      { "gt", desc = "Go to type definition" },
      { "gr", desc = "Show references" },
      { "K", desc = "Hover documentation" },
      { "<C-k>", desc = "Signature help" },
      { "<leader>ca", desc = "Code actions" },
      { "<leader>rn", desc = "Rename symbol" },
      { "[d", desc = "Previous diagnostic" },
      { "]d", desc = "Next diagnostic" },
      
      -- Diagnostics
      { "<leader>d", group = "Diagnostics" },
      { "<leader>dl", desc = "Diagnostic loclist" },
      { "<leader>df", desc = "Diagnostic float" },
      
      -- Folding
      { "<leader>z", group = "Folding" },
      { "<leader>zo", desc = "Open fold" },
      { "<leader>zc", desc = "Close fold" },
      { "<leader>za", desc = "Open all folds" },
      { "<leader>zm", desc = "Close all folds" },
      
      -- Miscellaneous
      { "<leader>so", desc = "Source config" },
      
      -- Window Management
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