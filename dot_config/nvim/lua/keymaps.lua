-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous [D]iagnostic message" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next [D]iagnostic message" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic [E]rror messages" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

-- Quickfix keymaps
vim.keymap.set("n", "[q", ":cprev<CR>")
vim.keymap.set("n", "]q", ":cnext<CR>")

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
-- vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
-- vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
-- vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
-- vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.keymap.set("n", "<M-,>", "<C-w>5<", { desc = "Resize split (broader horizontal)" })
vim.keymap.set("n", "<M-.>", "<C-w>5>", { desc = "Resize split (slimmer horizontal)" })
vim.keymap.set("n", "<M-t>", "<C-W>+", { desc = "Resize split (taller vertical)" })
vim.keymap.set("n", "<M-s>", "<C-W>-", { desc = "Resize split (shorter vertical)" })

-- Move lines/selections up and down
vim.keymap.set("n", "<C-j>", ":m .+1<CR>")
vim.keymap.set("n", "<C-k>", ":m .-2<CR>")
vim.keymap.set("v", "<C-j>", ":m '>+1<CR>gv")
vim.keymap.set("v", "<C-k>", ":m '<-2<CR>gv")

-- yank current file + line to system clipboard
vim.keymap.set("n", "cp", ':let @+ = expand("%")<CR>')
vim.keymap.set("n", "cl", ':let @+ = expand("%") . ":" . line(".")<CR>')

-- down one visual line, not one newline
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
-- reselect after indent
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")
-- stay on first match
vim.keymap.set("n", "*", "g*``")
-- select whole file
vim.keymap.set("n", "VV", "ggVG")

-- set text wrapping toggles
vim.keymap.set("n", "<leader>Tw", ":set invwrap<CR>:set wrap?<CR>", { desc = "[T]oggle [W]rap" })

-- common typos
vim.api.nvim_create_user_command("Wa", "wa", {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Qa", "qa", {})
