local config = {}
local api =  vim.api

function config.RunPython()
  api.nvim_command('exec "! python %"')
end

function config.RunTS()
  api.nvim_command('exec "! ts-node %"')
end

function config.RunJS()
  api.nvim_command('exec "! node %"')
end

function config.RunEX()
  api.nvim_command('exec "! elixir %"')
end

return config
