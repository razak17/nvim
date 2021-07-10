local fn = vim.fn

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local function check_back_space()
  local col = fn.col('.') - 1
  if col == 0 or fn.getline('.'):sub(col, col):match('%s') then
    return true
  else
    return false
  end
end

function _G.__tab__complete()
  if fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif fn.call("vsnip#available", {1}) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return fn['compe#complete']()
  end
end

function _G.__s_tab__complete()
  if fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif fn.call("vsnip#jumpable", {-1}) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    return t "<S-Tab>"
  end
end

function _G.__enhance_jk_move(key)
  vim.cmd [[packadd accelerated-jk]]
  local map = key == 'n' and '<Plug>(accelerated_jk_j)' or
                '<Plug>(accelerated_jk_gk)'
  return t(map)
end

function _G.__enhance_ft_move(key)
  if not packer_plugins['vim-eft'] then vim.cmd [[packadd vim-eft]] end
  local map = {
    f = '<Plug>(eft-f)',
    F = '<Plug>(eft-F)',
    [';'] = '<Plug>(eft-repeat)',
  }
  return t(map[key])
end

function _G.__fterm_cmd(key)
  local term = require("FTerm.terminal")
  local cmd = term:new():setup({cmd = "gitui"})
  if key == 'node' then
    cmd = term:new():setup({cmd = "node"})
  elseif key == 'python' then
    cmd = term:new():setup({cmd = "python"})
  elseif key == 'lazygit' then
    cmd = term:new():setup({cmd = "lazygit"})
  elseif key == 'ranger' then
    cmd = term:new():setup({cmd = "ranger"})
  end
  cmd:toggle()
end
