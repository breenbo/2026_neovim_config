-- Client HTTP : remplace kulala (extra lazyvim util.rest retire de lazyvim.json).
-- Variables lues dans vars.env (meme format KEY=value que l'ancien .env kulala).
return {
  "jellydn/hurl.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  ft = "hurl",
  opts = {
    mode = "split",
    -- garde le volet de reponse ouvert quand on revient dans le .hurl
    auto_close = false,
    -- hurl.nvim ne cherche que dans le dossier du fichier et son parent :
    -- chemin absolu pour les .hurl plus profonds de API_test/hurl.
    env_file = { "vars.env", "~/Documents/homePad/API_test/hurl/vars.env" },
    formatters = {
      json = { "jq" },
    },
  },
  -- Comme kulala : les captures (token, uuids...) sont gardees sur disque et
  -- rechargees au demarrage, pour que <leader>Rs marche sans relancer le login.
  -- hurl.nvim les garde seulement en memoire (global_vars, rempli apres
  -- history.update_history) ; on les ecrit dans son propre stockage
  -- (variables.json, celui de :HurlManageVariable) au tick suivant.
  config = function(_, opts)
    require("hurl").setup(opts)
    local utils = require("hurl.utils")
    _HURL_GLOBAL_CONFIG.global_vars =
      vim.tbl_extend("force", _HURL_GLOBAL_CONFIG.global_vars or {}, utils.load_persisted_vars())

    local history = require("hurl.history")
    local update_history = history.update_history
    history.update_history = function(data)
      update_history(data)
      vim.schedule(function()
        -- ne pas figer les valeurs de vars.env (HurlManageVariable les y injecte)
        local env = {}
        for _, f in ipairs(_HURL_GLOBAL_CONFIG.find_env_files_in_folders()) do
          if vim.fn.filereadable(f.path) == 1 then
            env = vim.tbl_extend("force", env, utils.parse_env_file(f.path))
          end
        end
        local vars = {}
        for k, v in pairs(_HURL_GLOBAL_CONFIG.global_vars or {}) do
          if env[k] == nil then vars[k] = v end
        end
        utils.save_persisted_vars(vars)
      end)
    end

    -- Gros resultats (ex. GET /lists/furnitures : 5 Mo de JSON sur une ligne,
    -- ~400k lignes apres jq) : treesitter markdown + json injecte +
    -- render-markdown + folds bloquent nvim et font exploser la memoire.
    -- Il faut couper AVANT que hurl ecrive les lignes : apres, le parse a deja
    -- eu lieu. Taille estimee sur le body brut ; le buffer du split est
    -- reutilise, donc on reactive pour les reponses suivantes de taille normale.
    local MAX_BYTES = 200 * 1024
    local last_buf
    local function set_rich(buf, rich)
      vim.api.nvim_buf_call(buf, function()
        if rich then
          pcall(vim.treesitter.start, buf, "markdown")
        else
          vim.treesitter.stop(buf)
          vim.wo.foldmethod = "manual"
          vim.bo.syntax = "OFF"
        end
        local ok, rm = pcall(require, "render-markdown")
        if ok then
          if rich then rm.buf_enable() else rm.buf_disable() end
        end
      end)
    end
    for _, mode in ipairs({ "split", "popup" }) do
      local container = require("hurl." .. mode)
      local show = container.show
      container.show = function(data, ...)
        local big = data and type(data.body) == "string" and #data.body > MAX_BYTES
        if big and last_buf and vim.api.nvim_buf_is_valid(last_buf) then
          set_rich(last_buf, false)
        end
        -- nouveau buffer : FileType ignore => ni treesitter ni render-markdown
        local ei = vim.o.eventignore
        if big then vim.o.eventignore = "FileType" end
        local ok, err = pcall(show, data, ...)
        vim.o.eventignore = ei
        if not ok then error(err) end
        -- split deja monte : hurl ne deplace pas le focus, le buffer courant
        -- est alors le .hurl. On cherche le buffer de reponse (nofile markdown).
        local buf
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          local b = vim.api.nvim_win_get_buf(win)
          if vim.bo[b].buftype == "nofile" and vim.bo[b].filetype == "markdown" then buf = b end
        end
        if not buf then return end
        last_buf = buf
        set_rich(buf, not big)
        if big then
          vim.notify(("hurl: reponse de %d Ko, affichee sans coloration"):format(math.floor(#data.body / 1024)))
        end
      end
    end
  end,
  keys = {
    { "<leader>RA", "<cmd>HurlRunner<CR>", desc = "Run all requests", ft = "hurl" },
    { "<leader>Rs", "<cmd>HurlRunnerAt<CR>", desc = "Run request under cursor", ft = "hurl" },
    { "<leader>Re", "<cmd>HurlRunnerToEntry<CR>", desc = "Run up to entry", ft = "hurl" },
    { "<leader>Rm", "<cmd>HurlToggleMode<CR>", desc = "Toggle popup/split", ft = "hurl" },
    { "<leader>Rv", "<cmd>HurlVerbose<CR>", desc = "Run verbose", ft = "hurl" },
    { "<leader>Rs", ":HurlRunner<CR>", desc = "Run selection", mode = "v", ft = "hurl" },
  },
}
