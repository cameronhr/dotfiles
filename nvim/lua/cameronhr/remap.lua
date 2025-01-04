vim.g.mapleader = " "  -- Set leader key to space
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
print("Leader set to: " .. vim.inspect(vim.g.mapleader))
