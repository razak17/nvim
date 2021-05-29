local config = {}

function config.RunC()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    let noex = shellescape(expand("%<"), 1)
    enew|silent execute ".!gcc " . file . " -o " . noex . " && ./" . noex
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function config.RunCPP()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    let noex = shellescape(expand("%<"), 1)
    enew|silent execute ".!g++ " . file . " -o " . noex . " && ./" . noex
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function config.RunTS()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!ts-node " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function config.RunJS()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!node " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function config.RunGo()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!go run " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function config.RunPython()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!python " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

return config
