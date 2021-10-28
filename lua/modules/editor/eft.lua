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
end
