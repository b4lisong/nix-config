-- Catppuccin colorscheme plugin
-- Enhances the manual implementation with better plugin integration
return {
  'catppuccin/nvim',
  name = 'catppuccin',
  priority = 1000, -- Load early to override manual theme
  config = function()
    require('catppuccin').setup({
      flavour = 'mocha', -- Match current manual implementation
      background = {
        light = 'latte',
        dark = 'mocha',
      },
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors = true,
      integrations = {
        cmp = true,
        telescope = true,
        treesitter = true,
        lsp_trouble = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
      },
    })
    
    -- Override manual theme with plugin version
    vim.cmd.colorscheme('catppuccin')
  end,
}