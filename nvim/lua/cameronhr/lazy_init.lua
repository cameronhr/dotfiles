local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	-- Plugins list
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "storm",
				light_style = "day",
				transparent = true,
				terminal_colors = true,
			})
		end,
	},
	{
		"f-person/auto-dark-mode.nvim",
		lazy = false,
		config = function()
			require("auto-dark-mode").setup({
				update_interval = 1000,
				set_dark_mode = function()
					vim.cmd("colorscheme tokyonight-storm")
				end,
				set_light_mode = function()
					vim.cmd("colorscheme tokyonight-day")
				end,
			})
			require("auto-dark-mode").init()
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		lazy = false,
		config = function()
			require("telescope").setup({
				defaults = {
					vimgrep_arguments = {
						"rg",
						"--hidden",
						"--smart-case",
						"--no-heading",
					},
					layout_strategy = "horizontal",
					layout_config = { width = 0.9, height = 0.8 },
				},
			})
		end,
	},
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		lazy = false,
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "python", "lua", "bash", "javascript", "sql" },
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = { "markdown" },
				},
				indent = { enable = true },
				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,
				-- Automatically install missing parsers when entering buffer
				auto_install = true,
			})
		end,
	},
	{
		"tpope/vim-dadbod",
		dependencies = {
			"kristijanhusak/vim-dadbod-completion",
			"kristijanhusak/vim-dadbod-ui",
			"hrsh7th/nvim-cmp",
		},
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-nvim-lsp",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
		},
		lazy = false,
		config = function()
			local cmp = require("cmp")
			cmp.setup({
				snippet = {
					expand = function(_) end,
				},
				mapping = {
					["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
					["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				},
				sources = {
					{ name = "treesitter" },
					{ name = "buffer" },
					{ name = "path" },
					{ name = "vim-dadbod-completion" },
					{ name = "nvim_lsp" },
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			-- "williamboman/mason-null-ls.nvim",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason").setup()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"basedpyright",
					"ruff",
					"yamlls",
				},
				automatic_installation = true,
			})

			local lspconfig = require("lspconfig")
			local capabilities = require("cmp_nvim_lsp").default_capabilities()
			lspconfig.basedpyright.setup({
				capabilities = capabilities,
			})
			lspconfig.ruff.setup({
				capabilities = capabilities,
				init_options = {
					settings = {
						lint = {
							ignore = { "I", "E402" },
						},
					},
				},
			})

			vim.diagnostic.config({
				virtual_text = true,
				signs = true,
				underline = true,
				float = {
					border = "rounded",
					source = "always",
					header = "",
					prefix = "",
					focusable = false,
					max_width = 80,
					wrap = true,
				},
			})

			lspconfig.yamlls.setup({
				capabilities = capabilities,
				settings = {
					yaml = {
						format = { enable = true },
						validate = true,
						schemaStore = {
							enable = true,
							url = "https://www.schemastore.org/api/json/catalog.json",
						},
					},
				},
			})
		end,
	},
	{
		"stevearc/conform.nvim",
		config = function()
			require("conform").setup({
				formatters_by_ft = {
					lua = { "stylua" },
					python = { "ruff_format" },
					yaml = { "prettier" },
				},

				format_on_save = {
					lsp_format = "fallback",
					timeout_ms = 500,
				},

				log_level = vim.log.levels.DEBUG,

				notify_no_formatters = true,
			})
		end,
	},
	{
		"tpope/vim-fugitive",
		cmd = { "G", "Git" },
	},
}, {
	-- Lazy.vim configuration options
	change_detection = { notify = false },
})
