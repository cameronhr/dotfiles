vim.g.mapleader = " "  -- Set leader key to space
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
print("Leader set to: " .. vim.inspect(vim.g.mapleader))

-- Lazy-load Telescope in keymap
vim.keymap.set('n', '<leader>ff', function() require('telescope.builtin').find_files() end, {})
vim.keymap.set('n', '<leader>fg', function() require('telescope.builtin').live_grep() end, {})
vim.keymap.set('n', '<leader>fb', function() require('telescope.builtin').buffers() end, {})
vim.keymap.set('n', '<leader>fh', function() require('telescope.builtin').help_tags() end, {})
