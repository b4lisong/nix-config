-- Lualine statusline configuration
-- Provides a modern, informative statusline with file info and git integration
return {
  'nvim-lualine/lualine.nvim',
  event = 'VeryLazy',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  config = function()
    local lualine = require('lualine')
    
    lualine.setup({
      options = {
        theme = 'catppuccin',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {
          statusline = {},
          winbar = {},
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = false,
        refresh = {
          statusline = 1000,
          tabline = 1000,
          winbar = 1000,
        },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {
          {
            'filename',
            file_status = true,
            newfile_status = false,
            path = 1,
            shorting_target = 40,
            symbols = {
              modified = '[+]',
              readonly = '[RO]',
              unnamed = '[No Name]',
              newfile = '[New]',
            },
          },
        },
        lualine_x = {
          'encoding',
          {
            'fileformat',
            symbols = {
              unix = 'LF',
              dos = 'CRLF',
              mac = 'CR',
            },
          },
          'filetype',
        },
        lualine_y = {'progress'},
        lualine_z = {'location'},
      },
      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {},
      },
      tabline = {
        lualine_a = {'buffers'},
        lualine_b = {'tabs'},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = {},
      },
      winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            file_status = true,        -- Show modification status
            newfile_status = true,     -- Show [New] for new files
            path = 1,                  -- Show relative path
            shorting_target = 40,      -- Shorten long paths
            symbols = {
              modified = '●',          -- Dot for modified files
              readonly = '',          -- Lock icon for readonly
              unnamed = '[No Name]',   -- Unnamed buffers
              newfile = '[New]',       -- New files
            },
          },
          {
            'diagnostics',
            sources = { 'nvim_lsp', 'nvim_diagnostic' },
            sections = { 'error', 'warn', 'info', 'hint' },
            diagnostics_color = {
              error = 'DiagnosticError',
              warn  = 'DiagnosticWarn',
              info  = 'DiagnosticInfo',
              hint  = 'DiagnosticHint',
            },
            symbols = {
              error = ' ',
              warn = ' ',
              info = ' ',
              hint = ' ',
            },
          }
        },
        lualine_x = {
          {
            'filetype',
            colored = true,
            icon_only = false,
          }
        },
        lualine_y = {},
        lualine_z = {}
      },
      inactive_winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            'filename',
            file_status = true,
            path = 1,
            symbols = {
              modified = '●',
              readonly = '',
              unnamed = '[No Name]',
            },
          }
        },
        lualine_x = {'filetype'},
        lualine_y = {},
        lualine_z = {}
      },
      extensions = {},
    })
  end,
}
