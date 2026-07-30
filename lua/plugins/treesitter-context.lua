-- Bandeau collant en haut du buffer : montre le contexte courant
-- (fonction / bloc <template> / composant) dans les gros fichiers .vue.
return {
  "nvim-treesitter/nvim-treesitter-context",
  event = "LazyFile",
  opts = {
    max_lines = 3,
    multiline_threshold = 1,
  },
}
