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
  nnoremap("<F12>", '<CMD>lua require("FTerm").toggle()<CR>')
  tnoremap("<F12>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
  nnoremap("<leader>en", '<CMD>lua require("FTerm").open()<CR>')
end
