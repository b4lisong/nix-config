-- Snacks.nvim configuration for lazygit integration
-- Provides automatic colorscheme theming and Neovim integration for lazygit
return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  opts = {
    lazygit = {
      -- Use default settings for minimal implementation
      -- Automatically themes lazygit with current Neovim colorscheme
      -- Integrates editing with current Neovim instance
    }
  }
}