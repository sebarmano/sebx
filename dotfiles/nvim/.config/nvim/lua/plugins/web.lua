-- Frontend stack: TypeScript / React / Next.js (scribe-fe-v2) with pnpm + tailwind.
return {
  -- Ensure the TS/web toolchain is installed via Mason.
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "typescript-language-server",
        "eslint-lsp",
        "tailwindcss-language-server",
        "json-lsp",
        "prettier",
      })
    end,
  },
}
