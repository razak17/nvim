return function()
  local t = rvim.t

  function _G.enhance_ft_move(key)
    vim.cmd [[packadd vim-eft]]
    local map = {
      f = "<Plug>(eft-f)",
      F = "<Plug>(eft-F)",
      [";"] = "<Plug>(eft-repeat)",
    }
    return t(map[key])
  end

  --config
  vim.g.eft_ignorecase = true

  -- Mappings
  local xmap = rvim.xmap
  local nmap = rvim.nmap
  local omap = rvim.omap
  local opts = { expr = true }
  nmap(";", "v:lua.enhance_ft_move(';')", opts)
  xmap(";", "v:lua.enhance_ft_move(';')", opts)
  nmap("f", "v:lua.enhance_ft_move('f')", opts)
  xmap("f", "v:lua.enhance_ft_move('f')", opts)
  omap("f", "v:lua.enhance_ft_move('f')", opts)
  nmap("F", "v:lua.enhance_ft_move('F')", opts)
  xmap("F", "v:lua.enhance_ft_move('F')", opts)
  omap("F", "v:lua.enhance_ft_move('F')", opts)
end
