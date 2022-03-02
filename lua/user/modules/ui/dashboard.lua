return function()
  local join = function(k, v, c)
    return { k .. string.rep(" ", c) .. v }
  end

  local num_plugins_loaded = #vim.fn.globpath(
    rvim.get_runtime_dir() .. "/site/pack/packer/*",
    "*",
    0,
    1
  )

  rvim.dashboard = {
    custom_header = {
      [[ _______             ____   ____.__         ]],
      [[ \      \   ____  ___\   \ /   /|__| _____  ]],
      [[ /   |   \_/ __ \/  _ \   Y   / |  |/     \ ]],
      [[/    |    \  ___(  <_> )     /  |  |  Y Y  \]],
      [[\____|__  /\___  >____/ \___/   |__|__|_|  /]],
      [[        \/     \/                        \/ ]],
    },
    default_executive = "telescope",
    disable_at_vimenter = 0,
    disable_statusline = 0,
    custom_section = {
      a = {
        description = join("  Find File", "<c-p>      ", 14),
        command = "Telescope find_files",
      },
      b = {
        description = join("  New File", "<leader>nf", 15),
        command = ":ene!",
      },
      c = {
        description = join("  Recent projects", "<leader>fp", 8),
        command = "Telescope projects",
      },
      d = {
        description = join("  Recent files", "<leader>fr", 11),
        command = "Telescope oldfiles",
      },
      e = {
        description = join("  Find word", "<leader>fg", 14),
        command = "Telescope live_grep",
      },
      f = {
        description = join("  Config file", "<leader>Lc", 12),
        command = ":e " .. rvim.get_user_dir() .. "/config/init.lua",
      },
    },
    custom_footer = { "  Neovim loaded " .. num_plugins_loaded .. " plugins" },
    preview_file_height = 20,
  }

  for opt, val in pairs(rvim.dashboard) do
    vim.g["dashboard_" .. opt] = val
  end

  rvim.augroup("DashboardSession", {
    events = { "VimLeavePre" },
    targets = "*",
    command = function()
      vim.cmd "SessionSave"
    end,
  })

  rvim.augroup("DashboardReady", {
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell nolist nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= ",
    },
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "set laststatus=0 | autocmd BufLeave <buffer> set laststatus=2",
    },
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "set showtabline=0 | autocmd BufLeave <buffer> set showtabline="
        .. vim.opt.showtabline._value,
    },
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "nnoremap <silent> <buffer> q :q<CR>",
    },
  })
end
