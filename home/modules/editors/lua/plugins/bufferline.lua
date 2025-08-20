return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  version = "*",
  opts = function()
    return {
      options = {
        mode = "buffers",
        style_preset = require("bufferline").style_preset.default,
      themable = true,
      numbers = "none",
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,
      indicator = {
        icon = "▎",
        style = "icon",
      },
      buffer_close_icon = "",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      max_name_length = 30,
      max_prefix_length = 30,
      tab_size = 21,
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        if context.buffer:current() then
          return ""
        end
        return "(" .. count .. ")"
      end,
      custom_filter = function(buf_number, buf_numbers)
        if vim.bo[buf_number].filetype ~= "oil" then
          return true
        end
      end,
      offsets = {
        {
          filetype = "neo-tree",
          text = "Neo-tree",
          text_align = "left",
          separator = true,
        },
      },
      color_icons = true,
      show_buffer_icons = true,
      show_buffer_close_icons = true,
      show_close_icon = true,
      show_tab_indicators = true,
      show_duplicate_prefix = true,
      persist_buffer_sort = true,
      move_wraps_at_ends = false,
      separator_style = "slant",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      hover = {
        enabled = true,
        delay = 200,
        reveal = { "close" },
      },
      sort_by = "insert_after_current",
      },
      highlights = require("catppuccin.groups.integrations.bufferline").get(),
    }
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)

    -- AstroNvim-style keybindings
    local map = vim.keymap.set

    -- Core navigation
    map("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
    map("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })
    map("n", "<leader>bb", "<cmd>BufferLinePick<cr>", { desc = "Navigate to buffer tab" })
    map("n", "<leader>bp", "<cmd>BufferLineTogglePin<cr>", { desc = "Toggle pin buffer" })

    -- Buffer management
    map("n", "<leader>bd", function()
      require("bufferline").close_buffer_with_pick()
    end, { desc = "Delete buffer tab" })
    map("n", "<leader>bc", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close all buffers except current" })
    map("n", "<leader>bC", function()
      local buffers = vim.api.nvim_list_bufs()
      for _, buf in ipairs(buffers) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "buflisted") then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end, { desc = "Close all buffers" })

    -- Buffer positioning
    map("n", ">b", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })
    map("n", "<b", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })

    -- Buffer sorting
    map("n", "<leader>bse", "<cmd>BufferLineSortByExtension<cr>", { desc = "Sort by extension" })
    map("n", "<leader>bsi", "<cmd>BufferLineSortByTabs<cr>", { desc = "Sort by buffer number" })
    map("n", "<leader>bsm", "<cmd>BufferLineSortByRelativeDirectory<cr>", { desc = "Sort by last modification" })
    map("n", "<leader>bsp", "<cmd>BufferLineSortByDirectory<cr>", { desc = "Sort by full path" })
    map("n", "<leader>bsr", "<cmd>BufferLineSortByRelativeDirectory<cr>", { desc = "Sort by relative path" })

    -- Buffer splits
    map("n", "<leader>b\\", function()
      vim.cmd("split")
    end, { desc = "Open buffer in horizontal split" })
    map("n", "<leader>b|", function()
      vim.cmd("vsplit")
    end, { desc = "Open buffer in vertical split" })

    -- Numeric buffer navigation (1-9)
    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        require("bufferline").go_to_buffer(i, true)
      end, { desc = "Go to buffer " .. i })
    end
  end,
}