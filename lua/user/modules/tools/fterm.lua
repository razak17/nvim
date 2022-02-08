return function()
  function _G.__fterm_cmd(key)
    local term = require "FTerm"
    local cmd = term:new { cmd = "gitui" }
    if key == "node" then
      cmd = term:new { cmd = "node" }
    elseif key == "python" then
      cmd = term:new { cmd = "python" }
    elseif key == "lazygit" then
      cmd = term:new { cmd = "lazygit" }
    elseif key == "ranger" then
      cmd = term:new { cmd = "ranger" }
    end
    cmd:toggle()
  end
end
