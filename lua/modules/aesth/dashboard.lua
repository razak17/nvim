local join = function(k, v, c) return {k .. string.rep(" ", c) .. v} end

vim.g.dashboard_custom_header = rvim.dashboard.custom_header
vim.g.dashboard_default_executive = rvim.dashboard.default_executive
vim.g.dashboard_disable_statusline = rvim.dashboard.disable_statusline
vim.g.dashboard_session_directory = rvim.dashboard.session_directory
vim.g.dashboard_custom_section = {
  a = {description = join('  Find Files', '<leader>ff', 13), command = 'Telescope find_files'},
  b = {description = join("  Last session", "<leader>Sl", 11), command = "SessionLoad"},
  c = {
  description = join('  Default config', '<leader>fC', 9),
  command = ":e " .. rvim.__vim_path .. "/lua/rvim/defaults.lua",
  },
  d = {description = join('  Find word', '<leader>flg', 14), command = 'Telescope live_grep'},
  e = {
    description = join('  Nvim files', '<leader>frc', 13),
    command = 'Telescope nvim_files files',
  },
  f = {description = join('  Recent files', '<leader>frr', 11), command = 'Telescope oldfiles'},
}

rvim.augroup("TelescopeSession", {
  events = {"VimLeavePre"},
  targets = "*",
  command = "lua rvim.dashboard.save_session()",
})

rvim.augroup("DashboardMode", {
  {
    events = {"FileType"},
    targets = {"dashboard"},
    command = "set laststatus=0 | autocmd BufLeave <buffer> set laststatus=2",
  },
})

