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
                transparent = false,
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
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "bash", "javascript" },
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
                },
            })
        end,
    },
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = { "jedi_language_server", "ruff" },
                automatic_installation = true,
            })

            local lspconfig = require("lspconfig")
            lspconfig.jedi_language_server.setup({})
            lspconfig.ruff.setup({
                init_options = {
                    settings = {
                        lint = {
                            ignore = {"I", "E402"}
                        }
                    }
                }
            })
        end
    },
    {
        "nvimtools/none-ls.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local null_ls = require("null-ls")
            null_ls.setup({
                sources = {
                    null_ls.builtins.formatting.isort.with({
                        extra_args = {"--profile", "black", "--multi-line", "3"}
                    }),
                    null_ls.builtins.formatting.black,
                }
            })
        end
    },
}, {
    -- Lazy.vim configuration options
    change_detection = { notify = false },
})
