-- Conform code formatter configuration
-- Provides lightweight, asynchronous code formatting with multiple formatter support
return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>cf',
      function()
        require('conform').format({ async = true, lsp_fallback = true })
      end,
      mode = { 'n', 'v' },
      desc = 'Format buffer',
    },
  },
  opts = {
    -- Configure formatters by file type
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'isort', 'black' },
      javascript = { { 'prettierd', 'prettier' } },
      typescript = { { 'prettierd', 'prettier' } },
      nix = { 'alejandra' },
      json = { { 'prettierd', 'prettier' } },
      html = { { 'prettierd', 'prettier' } },
      css = { { 'prettierd', 'prettier' } },
      markdown = { { 'prettierd', 'prettier' } },
    },
    -- Format on save configuration
    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
    -- Formatter configurations
    formatters = {
      -- Ensure alejandra uses the system version
      alejandra = {
        command = 'alejandra',
      },
    },
  },
  init = function()
    -- Use conform for formatexpr
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}