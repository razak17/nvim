local fn = vim.fn
local uv = vim.loop
local cmd = vim.cmd
local api = vim.api
local fmt = string.format

local M = {}

function M.open(path)
  fn.jobstart({ rvim.open_command, path }, { detach = true })
  vim.notify(fmt('Opening %s', path))
end

function M.open_link()
  local file = fn.expand('<cfile>')
  if not file or fn.isdirectory(file) > 0 then return vim.cmd.edit(file) end
  if file:match('http[s]?://') then return M.open(file) end

  -- consider anything that looks like string/string a github link
  local plugin_url_regex = '[%a%d%-%.%_]*%/[%a%d%-%.%_]*'
  local link = string.match(file, plugin_url_regex)
  print(link)
  if link then return M.open(fmt('https://www.github.com/%s', link)) end
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
  cmd('split term://zsh')
  cmd('resize 10')
end

-- https://github.com/CalinLeafshade/dots/blob/master/nvim/.config/nvim/lua/leafshade/rename.lua
function M.rename(name)
  local curfilepath = vim.fn.expand('%:p:h')
  local newname = curfilepath .. '/' .. name
  vim.api.nvim_command(' saveas ' .. newname)
end

function M.enable_transparent_mode()
  cmd('au ColorScheme * hi Normal ctermbg=none guibg=none')
  cmd('au ColorScheme * hi SignColumn ctermbg=none guibg=none')
  cmd('au ColorScheme * hi NormalNC ctermbg=none guibg=none')
  cmd('au ColorScheme * hi MsgArea ctermbg=none guibg=none')
  cmd('au ColorScheme * hi TelescopeBorder ctermbg=none guibg=none')
  cmd('au ColorScheme * hi NvimTreeNormal ctermbg=none guibg=none')
  cmd('au ColorScheme * hi EndOfBuffer ctermbg=none guibg=none')
  cmd("let &fcs='eob: '")
end

--- Checks whether a given path exists and is a directory
--@param path (string) path to check
--@returns (bool)
function M.is_directory(path)
  local stat = uv.fs_stat(path)
  return stat and stat.type == 'directory' or false
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
function M.modify_line_end_delimiter(character)
  local delimiters = { ',', ';' }
  return function()
    local line = api.nvim_get_current_line()
    local last_char = line:sub(-1)
    if last_char == character then
      api.nvim_set_current_line(line:sub(1, #line - 1))
      return
    end
    if vim.tbl_contains(delimiters, last_char) then
      api.nvim_set_current_line(line:sub(1, #line - 1) .. character)
      return
    end
    api.nvim_set_current_line(line .. character)
  end
end

function M.smart_quit()
  local bufnr = api.nvim_get_current_buf()
  local modified = api.nvim_buf_get_option(bufnr, 'modified')
  if modified then
    vim.ui.input({
      prompt = 'You have unsaved changes. Quit anyway? (y/n) ',
    }, function(input)
      if input == 'y' then cmd('q!') end
    end)
    return
  end
  cmd('q!')
end

function M.toggle_opt(opt)
  local value = nil
  value = not vim.api.nvim_get_option_value(opt, {})
  vim.opt[opt] = value
  vim.notify(opt .. ' set to ' .. tostring(value), 'info', { title = 'UI Toggles' })
end

---Write data to a file
---@param path string can be full or relative to `cwd`
---@param txt string|table text to be written, uses `vim.inspect` internally for tables
---@param flag string used to determine access mode, common flags: "w" for `overwrite` or "a" for `append`
function M.write_file(path, txt, flag)
  local data = type(txt) == 'string' and txt or vim.inspect(txt)
  uv.fs_open(path, flag, 438, function(open_err, fd)
    assert(not open_err, open_err)
    uv.fs_write(fd, data, -1, function(write_err)
      assert(not write_err, write_err)
      uv.fs_close(fd, function(close_err) assert(not close_err, close_err) end)
    end)
  end)
end

return M
