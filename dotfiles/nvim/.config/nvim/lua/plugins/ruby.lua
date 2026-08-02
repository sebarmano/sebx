-- Ruby via LazyVim's official lang.ruby extra (lazyvim.json), switched to
-- standardrb instead of the default rubocop (set in config/options.lua).
return {
  -- standard depends on rubocop under the hood; keep both available via Mason.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "standardrb", "rubocop" })
    end,
  },
}
