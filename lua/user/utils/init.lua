local fn = vim.fn
local uv = vim.loop
local api = vim.api
local fmt = string.format

local utils = {}

function utils.open_link()
  local file = fn.expand "<cfile>"
  if fn.isdirectory(file) > 0 then
    vim.cmd("edit " .. file)
  else
    fn.jobstart({ rvim.open_command, file }, { detach = true })
  end
end

function utils.color_my_pencils()
  vim.cmd [[ hi! ColorColumn guibg=#aeacec ]]
  vim.cmd [[ hi! Normal ctermbg=none guibg=none ]]
  vim.cmd [[ hi! SignColumn ctermbg=none guibg=none ]]
  vim.cmd [[ hi! LineNr guifg=#4dd2dc ]]
  vim.cmd [[ hi! CursorLineNr guifg=#f0c674 ]]
  vim.cmd [[ hi! TelescopeBorder guifg=#ffff00 guibg=#ff0000 ]]
  vim.cmd [[ hi! WhichKeyGroup guifg=#4dd2dc ]]
  vim.cmd [[ hi! WhichKeyDesc guifg=#4dd2dc  ]]
end

function utils.empty_registers()
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

function utils.open_terminal()
  vim.cmd "split term://zsh"
  vim.cmd "resize 10"
end

function utils.turn_on_guides()
  vim.wo.number = true
  vim.wo.relativenumber = true
  vim.wo.signcolumn = "auto:2-4"
  vim.wo.colorcolumn = "+1"
  vim.o.laststatus = 2
  vim.o.showtabline = 2
end

function utils.turn_off_guides()
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.colorcolumn = ""
  vim.o.laststatus = 0
  vim.o.showtabline = 0
end

-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function utils.rename(name)
  local curfilepath = vim.fn.expand "%:p:h"
  local newname = curfilepath .. "/" .. name
  vim.api.nvim_command(" saveas " .. newname)
end

function utils.load_conf(dir, name)
  local module_dir = fmt("user.modules.%s", dir)
  if dir == "user" then
    return require(string.format(dir .. ".%s", name))
  end

  return require(fmt(module_dir .. ".%s", name))
end

function utils.enable_transparent_mode()
  vim.cmd "au ColorScheme * hi Normal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi SignColumn ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NormalNC ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi MsgArea ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none"
  vim.cmd "au ColorScheme * hi EndOfBuffer ctermbg=none guibg=none"
  vim.cmd "let &fcs='eob: '"
end

--- Checks whether a given path exists and is a directory
--@param path (string) path to check
--@returns (bool)
function utils.is_directory(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == "directory" or false
end

---Write data to a file
---@param path string can be full or relative to `cwd`
---@param txt string|table text to be written, uses `vim.inspect` internally for tables
---@param flag string used to determine access mode, common flags: "w" for `overwrite` or "a" for `append`
function utils.write_file(path, txt, flag)
  local data = type(txt) == "string" and txt or vim.inspect(txt)
  uv.fs_open(path, flag, 438, function(open_err, fd)
    assert(not open_err, open_err)
    uv.fs_write(fd, data, -1, function(write_err)
      assert(not write_err, write_err)
      uv.fs_close(fd, function(close_err)
        assert(not close_err, close_err)
      end)
    end)
  end)
end

-- Auto resize Vim splits to active split to 70% -
-- https://stackoverflow.com/questions/11634804/vim-auto-resize-focused-window
utils.auto_resize = function()
  local auto_resize_on = false
  return function(args)
    if not auto_resize_on then
      local factor = args and tonumber(args) or 70
      local fraction = factor / 10
      -- NOTE: mutating &winheight/&winwidth are key to how
      -- this functionality works, the API fn equivalents do
      -- not work the same way
      vim.cmd(fmt("let &winheight=&lines * %d / 10 ", fraction))
      vim.cmd(fmt("let &winwidth=&columns * %d / 10 ", fraction))
      auto_resize_on = true
      vim.notify "Auto resize ON"
    else
      vim.cmd "let &winheight=30"
      vim.cmd "let &winwidth=30"
      vim.cmd "wincmd ="
      auto_resize_on = false
      vim.notify "Auto resize OFF"
    end
  end
end
-- TLDR: Conditionally modify character at end of line
-- Description:
-- This function takes a delimiter character and:
--   * removes that character from the end of the line if the character at the end
--     of the line is that character
--   * removes the character at the end of the line if that character is a
--     delimiter that is not the input character and appends that character to
--     the end of the line
--   * adds that character to the end of the line if the line does not end with
--     a delimiter
-- Delimiters:
-- - ","
-- - ";"
---@param character string
---@return function
function utils.modify_line_end_delimiter(character)
  local delimiters = { ",", ";" }
  return function()
    local line = api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      api.nvim_set_current_line(line:sub(1, #line - 1))
    elseif vim.tbl_contains(delimiters, last_char) then
      api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
    else
      api.nvim_set_current_line(line .. character)
    end
  end
end

return utils
