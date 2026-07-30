-- Preview d'un .svg dans un split sous le code, DANS le terminal.
--
-- resvg lit le buffer sur stdin (la preview suit donc les modifications même
-- non sauvegardées) et écrit un PNG ; snacks.image affiche ce PNG via le
-- protocole graphique kitty.
--
-- Pourquoi ne pas laisser snacks s'en charger : ImageMagick rend « no decode
-- delegate » sur nos icônes à cause de `fill="var(--icon-color,#194DDB)"`.
-- resvg accepte le fichier mais ne résout pas `var()` non plus — on substitue
-- donc la valeur de fallback avant conversion (voir to_png), ce qui rend la
-- vraie couleur.

local M = {}

local dir = vim.fn.stdpath("cache") .. "/svg-preview"
local zoom = "12" -- icônes 24x24 -> PNG 288x288
local height = 20 -- hauteur du split, en lignes
local seq = 0

--- Convertit le contenu du buffer en PNG.
--- Un nom de fichier neuf à chaque rendu : ni snacks ni le terminal ne peuvent
--- alors servir une version en cache à la place de la nouvelle.
---@param buf integer
---@return string? png nil si resvg échoue
local function to_png(buf)
  vim.fn.mkdir(dir, "p")
  seq = seq + 1
  local png = ("%s/%d-%d.png"):format(dir, buf, seq)
  local svg = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
  -- resvg ne sait pas résoudre `var()` et retomberait sur noir. On applique
  -- donc la valeur de fallback nous-mêmes — `var(--icon-color,#194DDB)`
  -- devient `#194DDB` — pour retrouver la vraie couleur, comme la preview
  -- inline des .vue.
  svg = svg:gsub("var%(%s*%-%-[%w%-_]+%s*,%s*([^)]+)%)", "%1")
  local res = vim.system({ "resvg", "-z", zoom, "--background", "white", "-", png }, { stdin = svg }):wait()
  if res.code ~= 0 then
    vim.notify("resvg: " .. (res.stderr or "échec de la conversion"), vim.log.levels.ERROR)
    return nil
  end
  return png
end

--- Preview courante. Volontairement un état de MODULE et non de buffer : il ne
--- doit exister qu'un seul split de preview à l'écran, quel que soit le nombre
--- de .svg ouverts.
---@type { win: integer?, buf: integer?, png: string? }
local state = {}

--- Ferme la preview courante et nettoie derrière elle (buffer + fichier PNG,
--- sinon les deux s'accumulent à chaque changement de fichier).
local function close()
  local win, png = state.win, state.png
  state = {}
  if win and vim.api.nvim_win_is_valid(win) then
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_win_close(win, true)
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  if png then
    os.remove(png)
  end
end

--- Ouvre la preview du buffer .svg sous la fenêtre courante.
---@param buf? integer
function M.render(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  local png = to_png(buf)
  if not png then
    return
  end

  -- On ferme la précédente avant d'ouvrir : elle concerne peut-être un autre
  -- fichier, et elle est peut-être placée sous une autre fenêtre.
  close()

  local from = vim.api.nvim_get_current_win()
  vim.cmd(("belowright %dsplit %s"):format(height, vim.fn.fnameescape(png)))
  state = { win = vim.api.nvim_get_current_win(), buf = buf, png = png }
  vim.api.nvim_set_current_win(from)
end

--- Ouvre la preview du buffer courant, ou la ferme si elle est déjà à l'écran.
---@param buf? integer
function M.toggle(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if state.buf == buf and state.win and vim.api.nvim_win_is_valid(state.win) then
    close()
  else
    M.render(buf)
  end
end

function M.setup()
  vim.api.nvim_create_user_command("SvgPreview", function()
    M.toggle()
  end, { desc = "SVG : preview dans un split (bascule)" })

  local group = vim.api.nvim_create_augroup("svg_preview", { clear = true })

  -- Ouverture automatique sur un vrai fichier .svg (pas les buffers de preview
  -- du picker, ni les scratch buffers).
  -- BufWinEnter et non FileType : FileType ne se redéclenche pas quand on
  -- revient sur un .svg déjà chargé (`:b`, <C-o>), et la preview resterait
  -- alors celle du fichier précédent.
  vim.api.nvim_create_autocmd("BufWinEnter", {
    group = group,
    pattern = "*.svg",
    callback = function(e)
      if vim.bo[e.buf].buftype ~= "" or vim.api.nvim_buf_get_name(e.buf) == "" then
        return
      end
      if state.buf == e.buf and state.win and vim.api.nvim_win_is_valid(state.win) then
        return -- déjà la bonne preview à l'écran
      end
      vim.schedule(function()
        if vim.api.nvim_buf_is_valid(e.buf) and vim.api.nvim_get_current_buf() == e.buf then
          M.render(e.buf)
        end
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.svg",
    callback = function(e)
      if state.buf == e.buf then
        M.render(e.buf)
      end
    end,
  })

  -- Pas de fenêtre de preview orpheline si on ferme le .svg qu'elle illustre.
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    pattern = "*.svg",
    callback = function(e)
      if state.buf == e.buf then
        close()
      end
    end,
  })

  -- Ce module est requis sur VeryLazy, donc APRÈS le FileType du premier
  -- buffer : `nvim icon.svg` ne déclencherait pas l'autocmd ci-dessus.
  if vim.bo.filetype == "svg" then
    M.render(vim.api.nvim_get_current_buf())
  end
end

return M
