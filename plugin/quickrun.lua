function _G.RunC()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    let noex = shellescape(expand("%<"), 1)
    enew|silent execute ".!gcc " . file . " -o " . noex . " && ./" . noex
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function _G.RunCPP()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    let noex = shellescape(expand("%<"), 1)
    enew|silent execute ".!g++ " . file . " -o " . noex . " && ./" . noex
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function _G.RunTS()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!ts-node " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function _G.RunJS()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!node " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function _G.RunGo()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!go run " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

function _G.RunPython()
  vim.api.nvim_exec([[
    let file = shellescape(expand("%"), 1)
    enew|silent execute ".!python " . file
    setlocal buftype=nofile bufhidden=wipe noswapfile nowrap nonumber norelativenumber nocursorline
    setlocal nobuflisted
  ]], true)
end

core.command {
  "QuickRun",
  function()
    if vim.bo.filetype == 'c' then
      vim.cmd [[call v:lua.RunC()]]
    elseif vim.bo.filetype == 'cpp' then
      vim.cmd [[call v:lua.RunCPP()]]
    elseif vim.bo.filetype == 'typescript' then
      vim.cmd [[call v:lua.RunTS()]]
    elseif vim.bo.filetype == 'javascript' then
      vim.cmd [[call v:lua.RunJS()]]
    elseif vim.bo.filetype == 'go' then
      vim.cmd [[call v:lua.RunGo()]]
    elseif vim.bo.filetype == 'python' then
      vim.cmd [[call v:lua.RunPython()]]
    end
  end,
}
