return function()
  local join = function(k, v, c)
    return { k .. string.rep(" ", c) .. v }
  end

  rvim.dashboard = {
    custom_header = {
      "                                                       ",
      "                                                       ",
      " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
      " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
      " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
      " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
      " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
      " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
      "                                                       ",
      "                                                       ",
    },
    default_executive = "telescope",
    disable_at_vim_enter = 0,
    disable_statusline = 0,
    save_session = function()
      vim.cmd "SessionSave"
    end,
    session_directory = vim.g.session_dir,
  }

  vim.g.dashboard_disable_at_vimenter = rvim.dashboard.disable_at_vim_enter
  vim.g.dashboard_custom_header = rvim.dashboard.custom_header
  vim.g.dashboard_default_executive = rvim.dashboard.default_executive
  vim.g.dashboard_disable_statusline = rvim.dashboard.disable_statusline
  vim.g.dashboard_custom_section = {
    a = { description = join("  Find Files", "<leader>ff", 13), command = "Telescope find_files" },
    b = { description = join("  Last session", "<leader>Sl", 11), command = "SessionLoad" },
    c = {
      description = join("  Default config", "<leader>fC", 9),
      command = ":e " .. vim.g.vim_path .. "/lua/rvim/defaults.lua",
    },
    d = { description = join("  Find word", "<leader>flg", 14), command = "Telescope live_grep" },
    e = {
      description = join("  Nvim files", "<leader>frc", 13),
      command = "Telescope nvim_files files",
    },
    f = { description = join("  Recent files", "<leader>frr", 11), command = "Telescope oldfiles" },
  }

  vim.cmd 'let g:dashboard_session_directory = "~/.cache/rvim/session/dashboard"'
  vim.cmd "let packages = len(globpath('~/.local/share/rvim/site/pack/packer/*', '*', 0, 1))"

  vim.api.nvim_exec(
    [[
    let g:dashboard_custom_footer = ['  Neovim loaded '..packages..' plugins']
  ]],
    false
  )

  rvim.augroup("TelescopeSession", {
    events = { "VimLeavePre" },
    targets = "*",
    command = "lua rvim.dashboard.save_session()",
  })

  rvim.augroup("DashboardMode", {
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "setlocal nocursorline noswapfile synmaxcol& signcolumn=no norelativenumber nocursorcolumn nospell  nolist  nonumber bufhidden=wipe colorcolumn= foldcolumn=0 matchpairs= ",
    },
    {
      events = { "FileType" },
      targets = { "dashboard" },
      command = "set laststatus=0 | autocmd BufLeave <buffer> set laststatus=2",
    },
  })
end
