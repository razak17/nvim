local M = { 'numToStr/FTerm.nvim', event = 'VeryLazy' }

function M.init()
  local function new_float(cmd)
    cmd = require('FTerm'):new({ cmd = cmd, dimensions = { height = 0.9, width = 0.9 } }):toggle()
  end
  rvim.nnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
  rvim.tnoremap([[<c-\>]], function() require('FTerm').toggle() end, 'fterm: toggle lazygit')
  rvim.nnoremap('<leader>lg', function() new_float('lazygit') end, 'fterm: toggle lazygit')
  rvim.nnoremap('<leader>ga', function() new_float('git add .') end, 'add all')
  rvim.nnoremap('<leader>gc', function() new_float('git commit -a -v') end, 'commit')
  rvim.nnoremap('<leader>gD', function() new_float('iconf -ccma') end, 'commit dotfiles')
  rvim.nnoremap('<leader>tb', function() new_float('btop') end, 'fterm: btop')
  rvim.nnoremap('<leader>tn', function() new_float('node') end, 'fterm: node')
  rvim.nnoremap('<leader>tr', function() new_float('ranger') end, 'fterm: ranger')
  rvim.nnoremap('<leader>tp', function() new_float('python') end, 'fterm: python')
end

function M.config()
  local fterm = require('FTerm')
  fterm.setup({ dimensions = { height = 0.8, width = 0.9 } })
end

return M
