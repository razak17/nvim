local fn = vim.fn
local uv = vim.loop

local M = {}

function M.open_link()
  local file = fn.expand "<cfile>"
  if fn.isdirectory(file) > 0 then
    vim.cmd("edit " .. file)
  else
    fn.jobstart({ rvim.open_command, file }, { detach = true })
  end
end

function M.color_my_pencils()
  vim.cmd [[ hi! ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi! Normal ctermbg=none guibg=none ]]
  vim.cmd [[ hi! SignColumn ctermbg=none guibg=none ]]
  vim.cmd [[ hi! LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi! CursorLineNr guifg=#f0c674 ]]
  vim.cmd [[ hi! TelescopeBorder guifg=#ffff00 guibg=#ff0000 ]]
  vim.cmd [[ hi! WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi! WhichKeyDesc guifg=#4dd2dc  ]]
end

function M.empty_registers()
  vim.api.nvim_exec(
    [[
    let regs=split('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [])
    endfor
  ]],
    false
  )
end

function M.open_terminal()
  vim.cmd "split term://zsh"
  vim.cmd "resize 10"
end

function M.turn_on_guides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.cursorline = true
  vim.wo.signcolumn = "yes"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function M.turn_off_guides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.cursorline = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function M.rename(name)
  local curfilepath = vim.fn.expand "%:p:h"
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

function M.load_conf(dir, name)
  local module_dir = string.format("user.modules.%s", dir)
  if dir == "user" then
    return require(string.format(dir .. ".%s", name))
  end

  return require(string.format(module_dir .. ".%s", name))
end

---Join path segments that were passed as input
---@return string
function M.join_paths(...)
  local path_sep = uv.os_uname().version:match "Windows" and "\\" or "/"
  local result = table.concat({ ... }, path_sep)
  return result
end

function M.enable_transparent_mode()
  vim.cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi EndOfBuffer ctermbg=none guibg=none"
  vim.cmd "let &fcs='eob: '"
end

function M.plug_notify(msg)
  vim.notify(msg, nil, { title = "Packer" })
end

return M
