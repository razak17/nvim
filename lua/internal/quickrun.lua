local config = {}

-- TODO: get local variables working
--
function config.RunTS()
  vim.api.nvim_exec([[
    let current_file = expand("%")
    enew|silent execute ".!ts-node " . shellescape(current_file, 1)
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    setlocal nobuflisted
  ]], true)
end

function config.RunJS()
  vim.api.nvim_exec([[
    let current_file = expand("%")
    enew|silent execute ".!node " . shellescape(current_file, 1)
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    setlocal nobuflisted
  ]], true)
end

function config.RunGo()
  vim.api.nvim_exec([[
    let current_file = expand("%")
    enew|silent execute ".!go run " . shellescape(current_file, 1)
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    setlocal nobuflisted
  ]], true)
end

function config.RunPython()
  vim.api.nvim_exec([[
    let current_file = expand("%")
    enew|silent execute ".!python " . shellescape(current_file, 1)
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap
    setlocal nobuflisted
  ]], true)
end

return config
