-- Match the ml-scribe toolchain: pyright (not basedpyright) + ruff + black.
-- CI runs pyright, so we use the same server to keep diagnostics consistent,
-- and black for formatting to match `pyproject.toml`.
return {
  -- Use pyright to match CI instead of LazyVim's default basedpyright.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = { enabled = false },
        pyright = {},
        ruff = {},
      },
    },
  },
  -- Make sure the right tools get installed via Mason.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "pyright", "ruff", "black" })
    end,
  },
  -- Format Python with black (matches pyproject), ruff handles import sorting/lint.
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", "black" },
      },
    },
  },
}
