-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Ruby: use standardrb instead of LazyVim's default rubocop for formatting.
-- Must be set here (loads before lazy.nvim) so the lang.ruby extra picks it
-- up before it evaluates. standardrb depends on rubocop under the hood, kept
-- installed via Mason in lua/plugins/ruby.lua.
vim.g.lazyvim_ruby_formatter = "standardrb"
