return function()
  function _G.__fterm_cmd(key)
    local term = require('FTerm')
    local cmd = term:new({ cmd = 'gitui' })
    if key == 'node' then
      cmd = term:new({ cmd = 'node' })
    elseif key == 'python' then
      cmd = term:new({ cmd = 'python' })
    elseif key == 'lazygit' then
      cmd = term:new({ cmd = 'lazygit' })
    elseif key == 'ranger' then
      cmd = term:new({ cmd = 'ranger' })
    elseif key == 'git_commit' then
      cmd = term:new({ cmd = 'git commit -a' })
    elseif key == 'conf_commit' then
      cmd = term:new({ cmd = 'iconf -ccma' })
    end
    cmd:toggle()
  end
  -- rvim.nnoremap("<F12>", '<cmd>lua require("FTerm").toggle()<CR>')
  rvim.tnoremap('<F12>', '<C-\\><C-n><cmd>lua require("FTerm").toggle()<CR>')

  require('which-key').register({
    ['<F12>'] = {
      '<cmd>lua require("FTerm").toggle()<CR>',
      'toggle term',
    },
    ['<leader>t'] = {
      name = 'Fterm',
      [';'] = { '<cmd>lua require("FTerm").open()<cr>', 'new' },
      l = { ':lua _G.__fterm_cmd("lazygit")<cr>', 'lazygit' },
      n = { ':lua _G.__fterm_cmd("node")<cr>', 'node' },
      p = { ':lua _G.__fterm_cmd("python")<cr>', 'python' },
      R = { ':lua _G.__fterm_cmd("ranger")<cr>', 'ranger' },
    },
  })
end
