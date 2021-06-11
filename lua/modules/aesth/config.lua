local config = {}

function config.galaxyline() require('modules.aesth.statusline') end

function config.nvim_bufferline() require('modules.aesth.bufferline') end

function config.dashboard() require('modules.aesth.dashboard') end

function config.gitsigns() require('modules.aesth.git_signs') end

function config.nvim_tree() require('modules.aesth.nvim_tree') end

function config.indent_blankline() require('modules.aesth.indent_blankline') end

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

