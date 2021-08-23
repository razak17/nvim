return function()
  function _G.fterm_cmd(key)
    local term = require "FTerm.terminal"
    local cmd = term:new():setup { cmd = "gitui" }
    if key == "node" then
      cmd = term:new():setup { cmd = "node" }
    elseif key == "python" then
      cmd = term:new():setup { cmd = "python" }
    elseif key == "lazygit" then
      cmd = term:new():setup { cmd = "lazygit" }
    elseif key == "ranger" then
      cmd = term:new():setup { cmd = "ranger" }
    end
    cmd:toggle()
  end

  -- config
  require("FTerm").setup()

  -- Mappings
  local nnoremap = rvim.nnoremap
  local tnoremap = rvim.tnoremap
  local map = rvim.map
  nnoremap("<F12>", '<CMD>lua require("FTerm").toggle()<CR>')
  tnoremap("<F12>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  nnoremap("<leader>eN", '<CMD>lua require("FTerm").open()<CR>')
  map("<leader>en", function()
    fterm_cmd "node"
  end)
  map("<leader>eg", function()
    fterm_cmd "gitui"
  end)
  map("<leader>ep", function()
    fterm_cmd "python"
  end)
  map("<leader>er", function()
    fterm_cmd "ranger"
  end)
  map("<leader>el", function()
    fterm_cmd "lazygit"
  end)
end
