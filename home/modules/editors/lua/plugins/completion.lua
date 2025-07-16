-- Blink Completion: High-performance completion with fuzzy matching
-- Migrated from nvim-cmp for better performance and modern features
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  dependencies = {
    'L3MON4D3/LuaSnip',
    'rafamadriz/friendly-snippets',
  },
  version = '*', -- Use latest stable version
  opts = {
    -- Keymap configuration
    keymap = {
      preset = 'default',
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          elseif cmp.is_visible() then
            return cmp.select_next()
          else
            -- Only show completion if there's text before cursor
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before_cursor = line:sub(1, col)
            
            -- Check if there's non-whitespace text before cursor
            if before_cursor:match('%S') then
              return cmp.show()
            else
              -- Let it fall through to normal tab behavior
              return false
            end
          end
        end,
        'snippet_forward',
        'fallback'
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.is_visible() then
            return cmp.select_prev()
          end
        end,
        'snippet_backward',
        'fallback'
      },
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    },

    -- Appearance configuration
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono',
    },

    -- Completion sources configuration
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lsp = {
          name = 'LSP',
          module = 'blink.cmp.sources.lsp',
          enabled = true,
          score_offset = 100, -- Prioritize LSP completions
        },
        path = {
          name = 'Path',
          module = 'blink.cmp.sources.path',
          enabled = true,
          score_offset = 3,
        },
        snippets = {
          name = 'Snippets',
          module = 'blink.cmp.sources.snippets',
          enabled = true,
          score_offset = 85, -- High priority for snippets
        },
        buffer = {
          name = 'Buffer',
          module = 'blink.cmp.sources.buffer',
          enabled = true,
          score_offset = 5, -- Lower priority fallback
        },
      },
    },

    -- Snippet configuration for new API
    snippets = {
      preset = 'luasnip', -- Use LuaSnip as snippet engine
    },

    -- Completion behavior configuration
    completion = {
      accept = {
        auto_brackets = {
          enabled = true,
        },
      },
      menu = {
        enabled = true,
        min_width = 15,
        max_height = 10,
        border = 'rounded',
        winblend = 0,
        winhighlight = 'Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection,Search:None',
        -- Source indicators similar to nvim-cmp format
        draw = {
          columns = {
            { 'label', 'label_description', gap = 1 },
            { 'kind_icon', 'kind' }
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 250,
        update_delay_ms = 50,
        window = {
          min_width = 10,
          max_width = 60,
          max_height = 20,
          border = 'rounded',
          winblend = 0,
          winhighlight = 'Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:Visual,Search:None',
        },
      },
      ghost_text = {
        enabled = false, -- Disable ghost text for cleaner experience
      },
    },

    -- Fuzzy matching configuration for better search
    fuzzy = {
      use_typo_resistance = true,
      use_frecency = true,
      use_proximity = true,
      max_items = 200,
      sorts = { 'score', 'sort_text' },
    },

    -- Signature help configuration
    signature = {
      enabled = true,
      window = {
        min_width = 1,
        max_width = 100,
        max_height = 10,
        border = 'rounded',
        winblend = 0,
        winhighlight = 'Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder',
      },
    },
  },
  config = function(_, opts)
    -- Load friendly-snippets for LuaSnip
    require('luasnip.loaders.from_vscode').lazy_load()
    
    -- Setup blink.cmp with our configuration
    require('blink.cmp').setup(opts)
  end,
}