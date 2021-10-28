return function()
  local utils = require "utils"

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
    session_directory = utils.join_paths(get_cache_dir(), "sessions", "dashboard"),
  }

  vim.g.dashboard_disable_at_vimenter = rvim.dashboard.disable_at_vim_enter
  vim.g.dashboard_custom_header = rvim.dashboard.custom_header
  vim.g.dashboard_default_executive = rvim.dashboard.default_executive
  vim.g.dashboard_disable_statusline = rvim.dashboard.disable_statusline
  vim.g.dashboard_session_directory = rvim.dashboard.session_directory

  local join = function(k, v, c)
    return { k .. string.rep(" ", c) .. v }
  end

  vim.g.dashboard_custom_section = {
    a = { description = join("  Find Files", "<leader>ff", 13), command = "Telescope find_files" },
    b = {
      description = join("  Default config", "<leader>fC", 9),
      command = ":e " .. get_config_dir() .. "/lua/core/config.lua",
    },
    c = { description = join("  Recent files", "<leader>frr", 11), command = "Telescope oldfiles" },
    d = { description = join("  Find word", "<leader>flg", 14), command = "Telescope live_grep" },
    e = { description = join("  Recent Projects", "<leader>fee", 8), command = "Telescope projects" },
  }

  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/*", "*", 0, 1)
  vim.g.dashboard_custom_footer = { "  Neovim loaded " .. num_plugins_loaded .. " plugins" }

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
