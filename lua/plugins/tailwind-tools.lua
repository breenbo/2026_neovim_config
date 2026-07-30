-- Confort Tailwind : pastilles de couleur inline, tri des classes,
-- repli (conceal) des longues listes de classes, completion enrichie.
-- Complète le LSP tailwindcss fourni par l'extra `lang.tailwind`.
return {
  "luckasRanarison/tailwind-tools.nvim",
  build = ":UpdateRemotePlugins",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {},
}
