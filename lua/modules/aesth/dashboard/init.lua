local g = vim.g
local G = require 'core.global'

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
  "                                                       ",
}
g.dashboard_footer_icon = ''
g.dashboard_preview_file_height = 12
g.dashboard_preview_file_width = 70
g.dashboard_default_executive = 'telescope'
g.dashboard_session_directory = G.cache_dir .. 'sessions'
vim.g.dashboard_custom_section = {
  all_sessions = {
    description = join("  Last session", "<leader>Sl", 11),
    command = "SessionLoad",
  },
  find_history = {
    description = join('  Recent files', '<leader>frr', 11),
    command = 'Telescope oldfiles',
  },
  find_file = {
    description = join('  Find Files', '<leader>ff', 13),
    command = 'Telescope find_files',
  },
  find_word = {
    description = join('  Find word', '<leader>flg', 14),
    command = 'Telescope live_grep',
  },
  -- find_dotfiles = {
  --   description = join('  Nvim config files', '<leader>frc', 6),
  --   command = 'Telescope nvim_files files'
  -- }
}
