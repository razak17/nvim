local config = {}

function config.galaxyline()
  require('modules.aesth.statusline')
end

function config.nvim_bufferline()
  require('modules.aesth.bufferline')
end

function config.dashboard()
  require('modules.aesth.dashboard')
end

function config.gitsigns()
  require('modules.aesth.git_signs')
end

function config.nvim_tree()
  require('modules.aesth.nvim_tree')
end

function config.indent_blankline()
  require('modules.aesth.indent_blankline')
end

function config.vim_cursorwod()
  vim.api.nvim_command('augroup user_plugin_cursorword')
  vim.api.nvim_command('autocmd!')
  vim.api.nvim_command(
      'autocmd FileType NvimTree,lspsagafinder,dashboard,vista let b:cursorword = 0')
  vim.api.nvim_command(
      'autocmd WinEnter * if &diff || &pvw | let b:cursorword = 0 | endif')
  vim.api.nvim_command('autocmd InsertEnter * let b:cursorword = 0')
  vim.api.nvim_command('autocmd InsertLeave * let b:cursorword = 1')
  vim.api.nvim_command('augroup END')
end

function config.bg()
  vim.cmd [[ colo zephyr ]]
  vim.cmd [[ autocmd ColorScheme * highlight clear SignColumn ]]
  -- vim.cmd [[ autocmd ColorScheme * highlight Normal ctermbg=NONE guibg=NONE ]]
  vim.cmd [[ hi ColorColumn ctermbg=lightgrey ]]
  vim.cmd [[ hi LineNr ctermbg=NONE guibg=NONE ]]
  vim.cmd [[ hi Comment cterm=italic ]]
end

function config.ColorMyPencils()
  vim.cmd [[ hi ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi Normal guibg=none ]]
  vim.cmd [[ hi LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi TelescopeBorder guifg=#aeacec ]]
  vim.cmd [[ hi FloatermBorder guifg= #aeacec ]]
  vim.cmd [[ hi WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi WhichKeyDesc guifg=#4dd2dc  ]]
end

return config

