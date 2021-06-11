r17.dashboard = {}
local join = function(k, v, c) return {k .. string.rep(" ", c) .. v} end
vim.g.dashboard_custom_header = {
  "                                                       ",
  "                                                       ",
  " ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗",
  " ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║",
  " ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║",
  " ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║",
  " ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║",
  " ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝",
  "                                                       ",
  "                                                       "
}

vim.g.dashboard_default_executive = 'telescope'
vim.g.dashboard_disable_statusline = 1
vim.g.dashboard_session_directory = vim.fn.stdpath("data") .. 'session/dashboard'
vim.g.dashboard_custom_section = {
  all_sessions = {
    description = join("  Last session", "<leader>Sl", 11),
    command = "SessionLoad"
  },
  find_history = {
    description = join('  Recent files', '<leader>frr', 11),
    command = 'Telescope oldfiles'
  },
  find_file = {
    description = join('  Project Files', '<leader>ff', 10),
    command = 'Telescope find_files'
  },
  find_word = {
    description = join('  Find word', '<leader>flg', 14),
    command = 'Telescope live_grep'
  },
  find_dotfiles = {
    description = join('  Nvim config files', '<leader>frc', 6),
    command = 'Telescope nvim_files files'
  }
}

function r17.dashboard.save_session() vim.cmd("SessionSave") end

r17.augroup("TelescopeSession",
            {events = {"VimLeavePre"}, targets = "*", command = "lua r17.dashboard.save_session()"})

r17.augroup("DashBoardMode", {
  {events = {"FileType"}, targets = {"dashboard"}, command = "set laststatus=0"},
  {
    events = {"FocusLost", "WinLeave", "BufLeave"},
    targets = {"dashboard"},
    command = "set colorcolumn=0 showtabline=2"
  },
  {
    events = {"FocusGained", "WinEnter", "BufEnter"},
    targets = {"dashboard"},
    command = "setlocal nocursorline showtabline=0 laststatus=0"
  }
})
