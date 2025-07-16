-- LSP configuration for code intelligence
-- Integrates with language servers managed by Nix for IDE features
return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local keymap = vim.keymap

		-- LSP keymaps (set when LSP attaches to buffer)
		local on_attach = function(client, bufnr)
			local opts = { noremap = true, silent = true, buffer = bufnr }

			-- Navigation
			keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
			keymap.set("n", "gr", vim.lsp.buf.references, opts)

			-- Information
			keymap.set("n", "K", vim.lsp.buf.hover, opts)
			keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)

			-- Actions
			keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
			keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			keymap.set("n", "<leader>f", function()
				vim.lsp.buf.format({ async = true })
			end, opts)

			-- Diagnostics
			keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
			keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
			keymap.set("n", "<leader>dl", vim.diagnostic.setloclist, opts)
			keymap.set("n", "<leader>df", vim.diagnostic.open_float, opts)
		end

		-- Enhanced capabilities for autocompletion
		-- blink.cmp will automatically handle LSP capabilities
		local capabilities = vim.lsp.protocol.make_client_capabilities()

		-- Configure diagnostic display
		vim.diagnostic.config({
			virtual_text = {
				prefix = "●",
			},
			signs = true,
			underline = true,
			update_in_insert = false,
			severity_sort = true,
			float = {
				focusable = false,
				style = "minimal",
				border = "rounded",
				source = "always",
				header = "",
				prefix = "",
			},
		})

		-- LSP servers configuration
		-- These servers are installed via Nix in extraPackages

		-- Nix language server
		lspconfig.nixd.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				nixd = {
					nixpkgs = {
						expr = "import <nixpkgs> { }",
					},
					formatting = {
						command = { "alejandra" },
					},
				},
			},
		})

		-- TypeScript/JavaScript language server
		lspconfig.ts_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- Lua language server
		lspconfig.lua_ls.setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- Python language server
		lspconfig.pylsp.setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		-- HTML, CSS, JSON, ESLint servers (from vscode-langservers-extracted)
		local servers = { "html", "cssls", "jsonls", "eslint" }
		for _, server in ipairs(servers) do
			lspconfig[server].setup({
				capabilities = capabilities,
				on_attach = on_attach,
			})
		end
	end,
}

