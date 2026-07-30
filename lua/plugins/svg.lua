-- Prévisualisation des SVG
--
-- Les .svg restent volontairement des fichiers TEXTE éditables : on n'ajoute
-- PAS "svg" à snacks `formats`, sinon snacks pose un `BufReadCmd *.svg` qui
-- remplace le buffer par l'image et on perd l'accès au source. En plus, nos
-- icônes utilisent `fill="var(--icon-color,#194DDB)"` que ni ImageMagick
-- (« no decode delegate ») ni resvg (fallback noir) ne savent résoudre.
--
-- La preview passe donc par le navigateur, seul moteur qui sait résoudre
-- `var()` :
--   :PreviewSvg  -> ouvre le SVG du buffer courant (fichier .svg, ou balise
--                   <svg> inline dans un .vue / .tsx / .html)
--
-- À savoir : le plugin réécrit tous les `fill=` en `fill="black"` avant
-- d'envoyer au navigateur. La preview est donc une silhouette noire — c'est
-- assez pour vérifier une forme, pas pour vérifier une couleur.
--
-- snacks.image reste actif pour tout le reste (png/jpg/pdf/…) et pour les
-- images référencées dans les documents markdown / html / vue.
return {
  {
    "folke/snacks.nvim",
    opts = {
      image = { enabled = true },
    },
  },
  {
    "nmassardot/nvim-preview-svg",
    cmd = "PreviewSvg",
    main = "nvim-preview-svg",
    opts = {
      browser = "Google Chrome",
      args = false, -- --args est cassé depuis macOS > Big Sur
    },
  },
}
