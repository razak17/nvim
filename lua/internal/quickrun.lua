local config = {}
local api = vim.api

function config.RunTS()
  api.nvim_command('exec "! ts-node %"')
end

function config.RunJS()
  api.nvim_command('exec "! node %"')
end
function config.RunGo()
  api.nvim_command('exec "! go run %"')
end

function config.RunEX()
  api.nvim_command('exec "! elixir %"')
end

return config
