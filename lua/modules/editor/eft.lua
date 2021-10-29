return function()
  local T = rvim.T

  function _G.enhance_ft_move(key)
    vim.cmd [[packadd vim-eft]]
    local map = {
      f = "<Plug>(eft-f)",
      F = "<Plug>(eft-F)",
      [";"] = "<Plug>(eft-repeat)",
    }
    return T(map[key])
  end

  --config
  vim.g.eft_ignorecase = true
end
