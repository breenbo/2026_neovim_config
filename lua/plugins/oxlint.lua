-- Oxlint language server : diagnostics en ligne pour les règles confiées à oxlint
-- (no-unused-vars, no-debugger, no-constant-binary-expression, unicorn/*, ...).
--
-- La config `oxlint` de nvim-lspconfig lance « node_modules/.bin/oxlint --lsp »
-- s'il existe dans le projet (sinon le `oxlint` global), et détecte la racine via
-- .oxlintrc.json. Rien à installer via Mason : on réutilise le binaire local du repo.
--
-- Complète (sans remplacer) les LSP déjà en place : vtsls/Volar pour les types,
-- et eslint pour les templates Vue / TanStack Query.
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      oxlint = {
        -- Pas de paquet Mason : on utilise le binaire local du projet.
        mason = false,
      },
    },
  },
}
