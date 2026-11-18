return {
  "l3aro/omp.nvim",
  version = "*", -- Latest stable release
  -- Disable the default <leader>oa maps; init runs before the plugin loads
  init = function()
    vim.g.omp_nvim_no_keymaps = false
  end,
}
