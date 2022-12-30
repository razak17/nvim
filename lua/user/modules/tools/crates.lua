local M = { 'Saecki/crates.nvim', event = { 'BufRead Cargo.toml' } }

function M.config()
  require('crates').setup({
    popup = {
      autofocus = true,
      style = 'minimal',
      border = 'single',
      show_version_date = false,
      show_dependency_version = true,
      max_height = 30,
      min_width = 20,
      padding = 1,
    },
    null_ls = {
      enabled = true,
      name = 'crates.nvim',
    },
  })
end

return M
