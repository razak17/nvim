return function()
  local utils = require "user.utils"

  local join = function(k, v, c)
    return { k .. string.rep(" ", c) .. v }
  end

  local num_plugins_loaded = #vim.fn.globpath(get_runtime_dir() .. "/site/pack/packer/*", "*", 0, 1)

  rvim.dashboard = {
    custom_header = {
      [[                               __                ]],
      [[  ___     ___    ___   __  __ /\_\    ___ ___    ]],
      [[ / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\  ]],
      [[/\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \ ]],
      [[\ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\]],
      [[ \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/]],
    },
    default_executive = "telescope",
    disable_at_vimenter = 0,
    disable_statusline = 0,
    session_directory = utils.join_paths(get_cache_dir(), "sessions", "dashboard"),
    custom_section = {
      a = {
        description = join("  Find Files", "<leader>ff", 13),
        command = "Telescope find_files",
      },
      b = {
        description = join("  Default config", "<leader>Ic", 9),
        command = ":e " .. get_config_dir() .. "/lua/config/init.lua",
      },
      c = {
        description = join("  Recent files", "<leader>fR", 11),
        command = "Telescope oldfiles",
      },
      d = {
        description = join("  Find in project", "<leader>flg", 8),
        command = "Telescope live_grep",
      },
      e = {
        description = join("  File Browser", "<leader>fb", 11),
        command = "Telescope file_browser",
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
  })
end
