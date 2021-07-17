local join = function(k, v, c) return {k .. string.rep(" ", c) .. v} end

vim.g.dashboard_custom_header = core.dashboard.custom_header
vim.g.dashboard_default_executive = core.dashboard.default_executive
vim.g.dashboard_disable_statusline = core.dashboard.disable_statusline
vim.g.dashboard_session_directory = core.dashboard.session_directory
vim.g.dashboard_custom_section = {
  a = {description = join('  Find word', '<leader>flg', 14), command = 'Telescope live_grep'},
  b = {description = join('  Find Files', '<leader>ff', 13), command = 'Telescope find_files'},
  c = {
    description = join('  Nvim files', '<leader>frc', 13),
    command = 'Telescope nvim_files files',
  },
  d = {description = join('  Recent files', '<leader>frr', 11), command = 'Telescope oldfiles'},
  e = {description = join("  Last session", "<leader>Sl", 11), command = "SessionLoad"},
  f = {
    description = join('  Default config', '<leader>fC', 9),
    command = ":e " .. core.__vim_path .. "/lua/core/defaults.lua",
  },
}

core.augroup("TelescopeSession", {
  events = {"VimLeavePre"},
  targets = "*",
  command = "lua core.dashboard.save_session()",
})

core.augroup("DashboardMode", {
  {
    events = {"FileType"},
    targets = {"dashboard"},
    command = "set laststatus=0 | autocmd BufLeave <buffer> set laststatus=2",
  },
})

