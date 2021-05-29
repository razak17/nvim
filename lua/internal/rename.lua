-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
local function rename(name)
  local curfilepath = vim.fn.expand("%:p:h")
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

vim.api
    .nvim_command [[command! -nargs=1 Rename :call v:lua.require('internal.rename')(<f-args>) ]]

return rename
