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
            })
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "ray-x/cmp-treesitter", -- Completion for symbols from Treesitter
            "hrsh7th/cmp-buffer", -- For buffer-local completion
            "hrsh7th/cmp-path" -- For file path completion
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
}, {
    -- Lazy.nvim configuration options
    change_detection = { notify = false },
})
