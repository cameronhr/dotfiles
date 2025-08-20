local harpoon = require("harpoon")

-- Set leader key to space
vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Diagnostic navigation with virtual lines: https://www.reddit.com/r/neovim/comments/1jm5atz/comment/mk9w6v0
---@param jumpCount number
local function jumpWithVirtLineDiags(jumpCount)
	pcall(vim.api.nvim_del_augroup_by_name, "jumpWithVirtLineDiags") -- prevent autocmd for repeated jumps

	vim.diagnostic.jump({ count = jumpCount })

	vim.diagnostic.config({
		virtual_text = false,
		virtual_lines = { current_line = true },
	})

	vim.defer_fn(function() -- deferred to not trigger by jump itself
		vim.api.nvim_create_autocmd("CursorMoved", {
			desc = "User(once): Reset diagnostics virtual lines",
			once = true,
			group = vim.api.nvim_create_augroup("jumpWithVirtLineDiags", {}),
			callback = function()
				vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
			end,
		})
	end, 1)
end

-- Keep visual selection after indent/dedent
vim.api.nvim_set_keymap("v", "<", "<gv", { noremap = true, silent = true })
vim.api.nvim_set_keymap("v", ">", ">gv", { noremap = true, silent = true })

vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Telescope keymaps
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

-- LSP kemaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set("n", "gr", vim.lsp.buf.references, { desc = "Go to references" })
vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover documentation" })
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format, { desc = "Format file" })
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code actions" })
vim.keymap.set("n", "ge", function()
	jumpWithVirtLineDiags(1)
end, { desc = "Next diagnostic" })
vim.keymap.set("n", "gE", function()
	jumpWithVirtLineDiags(-1)
end, { desc = "Prev diagnostic" })
vim.keymap.set("n", "<leader>k", function()
	vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })

	vim.api.nvim_create_autocmd("CursorMoved", {
		group = vim.api.nvim_create_augroup("line-diagnostics", { clear = true }),
		callback = function()
			vim.diagnostic.config({ virtual_lines = false, virtual_text = true })
			return true
		end,
	})
end)

-- Harpoon keymaps
harpoon:setup()
vim.keymap.set("n", "<leader>a", function()
	harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
vim.keymap.set("n", "<C-1>", function()
	harpoon:list():select(1)
end)
vim.keymap.set("n", "<C-2>", function()
	harpoon:list():select(2)
end)
vim.keymap.set("n", "<C-3>", function()
	harpoon:list():select(3)
end)
vim.keymap.set("n", "<C-4>", function()
	harpoon:list():select(4)
end)
vim.keymap.set("n", "<leader>o", function()
	harpoon:list():prev()
end)
vim.keymap.set("n", "<leader>i", function()
	harpoon:list():next()
end)

-- Soft-wrap text
vim.keymap.set("n", "<leader>w", function()
	vim.wo.wrap = not vim.wo.wrap
	vim.wo.linebreak = not vim.wo.linebreak
	vim.bo.textwidth = 0
end, { noremap = true, silent = true, desc = "Toggle soft-wrap" })
