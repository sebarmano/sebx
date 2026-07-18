-- init.lua — placeholder neovim config managed by sebx.
-- Add your plugin manager (lazy.nvim) and plugins below over time.

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- ── Options ──────────────────────────────────────────────────────────────────
local opt = vim.opt

opt.number         = true
opt.relativenumber = true
opt.expandtab      = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.smartindent    = true
opt.wrap           = false
opt.ignorecase     = true
opt.smartcase      = true
opt.termguicolors  = true
opt.signcolumn     = "yes"
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.updatetime     = 200
opt.clipboard      = "unnamedplus"
opt.splitright     = true
opt.splitbelow     = true
opt.undofile       = true

-- ── Keymaps ──────────────────────────────────────────────────────────────────
local map = vim.keymap.set

map("n", "<leader>w", "<cmd>w<cr>")
map("n", "<leader>q", "<cmd>q<cr>")
map("n", "<Esc>",     "<cmd>nohlsearch<cr>")
map("n", "<C-h>",     "<C-w>h")
map("n", "<C-j>",     "<C-w>j")
map("n", "<C-k>",     "<C-w>k")
map("n", "<C-l>",     "<C-w>l")

-- ── Plugin manager bootstrap (lazy.nvim) ─────────────────────────────────────
-- Uncomment once you're ready to add plugins:
--
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.loop.fs_stat(lazypath) then
--   vim.fn.system({ "git", "clone", "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
-- end
-- vim.opt.rtp:prepend(lazypath)
--
-- require("lazy").setup({
--   -- add plugins here
-- })
