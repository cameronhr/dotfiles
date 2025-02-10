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
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        lazy = false,
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "python", "lua", "bash", "javascript", "sql"},
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
        'tpope/vim-dadbod',
        dependencies = {
            'kristijanhusak/vim-dadbod-completion',
            'kristijanhusak/vim-dadbod-ui',
            'hrsh7th/nvim-cmp',
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
                    --Python
                    null_ls.builtins.formatting.isort.with({
                        extra_args = {"--profile", "black", "--multi-line", "3"}
                    }),
                    null_ls.builtins.formatting.black,
                    -- YAML
                    null_ls.builtins.diagnostics.yamllint,
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "yaml" },
                    }),
                    -- JSON
                    null_ls.builtins.diagnostics.jsonlint,
                    null_ls.builtins.formatting.prettier.with({
                        filetypes = { "json" },
                    }),
                }
            })
        end
    },
    {
      "yetone/avante.nvim",
      event = "VeryLazy",
      lazy = false,
      version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
      opts = {
        provider = "claude",
        openai = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-sonnet-20241022",
        },
      },
      build = "make",
      dependencies = {
        "stevearc/dressing.nvim",
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
        {
          -- support for image pasting
          "HakonHarnes/img-clip.nvim",
          event = "VeryLazy",
          opts = {
            default = {
              embed_image_as_base64 = false,
              prompt_for_file_name = false,
              drag_and_drop = {
                insert_mode = true,
              },
            },
          },
        },
        {
          -- Make sure to set this up properly if you have lazy=true
          'MeanderingProgrammer/render-markdown.nvim',
          opts = {
            file_types = { "markdown", "Avante" },
          },
          ft = { "markdown", "Avante" },
        },
      },
    }
}, {
    -- Lazy.vim configuration options
    change_detection = { notify = false },
})
