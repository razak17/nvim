return function()
  local t = rvim.T

  function _G.enhance_jk_move(key)
    vim.cmd [[packadd accelerated-jk]]
    local map = key == "n" and "<Plug>(accelerated_jk_j)" or "<Plug>(accelerated_jk_gk)"
    return t(map)
  end

  local nmap = rvim.nmap
  nmap("n", 'v:lua.enhance_jk_move("n")', { silent = true, expr = true })
  nmap("k", 'v:lua.enhance_jk_move("k")', { silent = true, expr = true })
end
