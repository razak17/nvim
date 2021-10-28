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
end
