return function()
  require("package-info").setup {
    colors = {
      up_to_date = "#3C4048", -- Text color for up to date package virtual text
      outdated = "#d19a66", -- Text color for outdated package virtual text
    },
    icons = {
      enable = true, -- Whether to display icons
      style = {
        up_to_date = "|  ", -- Icon for up to date packages
        outdated = "|  ", -- Icon for outdated packages
      },
    },
  }

  -- Show package versions
  rvim.nnoremap(
    "<leader>ns",
    ":lua require('package-info').show()<CR>",
    "package-info: show"
  )

  -- Hide package versions
  rvim.nnoremap(
    "<leader>nc",
    ":lua require('package-info').hide()<CR>",
    "package-info: hide"
  )

  -- Update package on line
  rvim.nnoremap(
    "<leader>nu",
    ":lua require('package-info').update()<CR>",
    "package-info: update"
  )

  -- Delete package on line
  rvim.nnoremap(
    "<leader>nd",
    ":lua require('package-info').delete()<CR>",
    "package-info: delete"
  )

  -- Install a new package
  rvim.nnoremap(
    "<leader>ni",
    ":lua require('package-info').install()<CR>",
    "package-info: install"
  )

  -- Reinstall dependencies
  rvim.nnoremap(
    "<leader>nr",
    ":lua require('package-info').reinstall()<CR>",
    "package-info: reinstall"
  )

  -- Install a different package version
  rvim.nnoremap(
    "<leader>np",
    ":lua require('package-info').change_version()<CR>",
    "package-info: change version"
  )
end
