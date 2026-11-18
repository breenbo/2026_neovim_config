-- Confort Tailwind : pastilles de couleur inline, tri des classes,
-- repli (conceal) des longues listes de classes, completion enrichie.
-- Complète le LSP tailwindcss fourni par l'extra `lang.tailwind`.
return {
  "luckasRanarison/tailwind-tools.nvim",
  build = ":UpdateRemotePlugins",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  ft = { "html", "vue", "javascriptreact", "typescriptreact" },
  -- override=true rappelle lspconfig.tailwindcss.setup() avec tous les
  -- filetypes par defaut, ce qui annule la restriction html/vue/jsx/tsx de
  -- tailwindcss.lua. Les pastilles/tri passent par LspAttach, pas par ce setup.
  opts = { server = { override = false } },
}
