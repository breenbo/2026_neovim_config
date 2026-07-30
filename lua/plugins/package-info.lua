-- Versions des dépendances npm affichées inline dans package.json
-- (version installée, mises à jour dispo) + actions update/delete.
return {
  "vuki656/package-info.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  -- Chargement uniquement à l'ouverture d'un package.json
  event = { "BufRead package.json" },
  config = function()
    require("package-info").setup()
  end,
}
