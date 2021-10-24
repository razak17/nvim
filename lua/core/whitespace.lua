----------------------------------------------------------------------------------
--  Whitespace highlighting
----------------------------------------------------------------------------------
--@source: https://vim.fandom.com/wiki/Highlight_unwanted_spaces (comment at the bottom)
--@implementation: https://github.com/inkarkat/vim-ShowTrailingWhitespace

local Log = require "core.log"

local status_ok, H = pcall(require, "core.highlights")
if not status_ok then
  Log:debug "Could not load highlights"
  return
end

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

H.set_hl("ExtraWhitespace", { guifg = "red" })

rvim.augroup("WhitespaceMatch", {
  {
    events = { "ColorScheme" },
    targets = { "*" },
    command = function()
      H.set_hl("ExtraWhitespace", { guifg = "red" })
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
