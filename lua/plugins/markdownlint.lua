-- Point markdownlint-cli2 at a global rules file (~/.markdownlint.yaml) so
-- MD013/line-length is off everywhere. Project-level .markdownlint-cli2.*
-- files are still discovered and merged on top of it.
return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", vim.fn.expand("~/.markdownlint.yaml"), "-" },
      },
    },
  },
}
