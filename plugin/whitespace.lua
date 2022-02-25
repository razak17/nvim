----------------------------------------------------------------------------------
--  Whitespace highlighting
----------------------------------------------------------------------------------
--@source: https://vim.fandom.com/wiki/Highlight_unwanted_spaces (comment at the bottom)
--@implementation: https://github.com/inkarkat/vim-ShowTrailingWhitespace

local Log = require "user.core.log"

local util = require "zephyr.util"

local fn = vim.fn

local function is_floating_win()
  return vim.fn.win_gettype() == "popup"
end

local function is_invalid_buf()
  return vim.bo.filetype == "" or vim.bo.buftype ~= "" or not vim.bo.modifiable
end

local function toggle_trailing(mode)
  if is_invalid_buf() or is_floating_win() then
    vim.wo.list = false
    return
  end
  if not vim.wo.list then
    vim.wo.list = true
  end
  local pattern = mode == "i" and [[\s\+\%#\@<!$]] or [[\s\+$]]
  if vim.w.whitespace_match_number then
    fn.matchdelete(vim.w.whitespace_match_number)
    fn.matchadd("ExtraWhitespace", pattern, 10, vim.w.whitespace_match_number)
  else
    vim.w.whitespace_match_number = fn.matchadd("ExtraWhitespace", pattern)
  end
end

util.set_hl("ExtraWhitespace", { foreground = "red" })

rvim.augroup("WhitespaceMatch", {
  {
    events = { "ColorScheme" },
    targets = { "*" },
    command = function()
      util.set_hl("ExtraWhitespace", { foreground = "red" })
    end,
  },
  {
    events = { "BufEnter", "FileType", "InsertLeave" },
    targets = { "*" },
    command = function()
      toggle_trailing "n"
    end,
  },
  {
    events = { "InsertEnter" },
    targets = { "*" },
    command = function()
      toggle_trailing "i"
    end,
  },
})
