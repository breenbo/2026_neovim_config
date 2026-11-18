-- Deux serveurs TypeScript s'attachaient au même buffer (vtsls + tsgo), tous les
-- deux fournisseurs d'inlay hints. Les hints en double tombent sur le bug
-- neovim 0.12 de runtime/lua/vim/lsp/inlay_hint.lua : nvim_buf_set_extmark est
-- appelé avec une colonne périmée, d'où le spam
-- `Invalid 'col': out of range` du decoration provider `nvim.lsp.inlayhint`.
-- Upstream : https://github.com/neovim/neovim/issues/36318
return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = { tsgo = { enabled = false } },
    inlay_hints = { enabled = false },
  },
}
