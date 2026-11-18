-- LSP tailwindcss uniquement sur html et vue : remplace le setup de l'extra
-- `lang.tailwind`, qui ajoute toute la liste par defaut de lspconfig (js, ts,
-- css, markdown...) et demarre donc le serveur (~110 Mo de node) partout.
return {
  "neovim/nvim-lspconfig",
  opts = {
    setup = {
      tailwindcss = function(_, opts)
        opts.filetypes = { "html", "vue" }
      end,
    },
  },
}
