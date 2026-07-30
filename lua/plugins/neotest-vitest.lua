-- Adaptateur Vitest pour neotest (l'extra `test.core` fournit neotest lui-même).
-- Lancer / rejouer / watcher les tests unitaires (*.spec.ts) depuis le buffer :
--   <leader>tr run le plus proche · <leader>tt le fichier · <leader>tw watch · <leader>to output
--
-- NB : les tests browser (*.browser.spec.ts, Vitest Browser Mode) se lancent en CLI
-- (npm run test:browser) — l'adaptateur cible le projet unit happy-dom.
return {
  "nvim-neotest/neotest",
  dependencies = { "marilari88/neotest-vitest" },
  opts = {
    adapters = {
      ["neotest-vitest"] = {},
    },
  },
}
