-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<C-Left>", "<C-w>h", { desc = "Go to left window" })
vim.keymap.set("n", "<C-Down>", "<C-w>j", { desc = "Go to lower window" })
vim.keymap.set("n", "<C-Up>", "<C-w>k", { desc = "Go to upper window" })
vim.keymap.set("n", "<C-Right>", "<C-w>l", { desc = "Go to right window" })
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>gg", "<cmd>Neogit<cr>", { desc = "Neogit" })
vim.keymap.set("n", "<leader>cj", "<cmd>%!jq .<cr>", { desc = "Format JSON (jq)" })
