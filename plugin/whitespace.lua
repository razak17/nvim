local enabled = ar.config.plugin.main.whitespace.enable

if not ar or ar.none or not enabled then return end

----------------------------------------------------------------------------------
--  Whitespace highlighting
----------------------------------------------------------------------------------
--@source: https://vim.fandom.com/wiki/Highlight_unwanted_spaces (comment at the bottom)
--@implementation: https://github.com/inkarkat/vim-ShowTrailingWhitespace

if not ar then return end

local fn = vim.fn

local config = {
  excluded_fts = {
    'w3m',
  },
}

if not config then return end

local function is_floating_win() return fn.win_gettype() == 'popup' end

local function is_invalid_buf()
  return vim.bo.filetype == '' or vim.bo.buftype ~= '' or not vim.bo.modifiable
end

local function toggle_trailing(mode)
  if is_invalid_buf() or is_floating_win() then
    vim.wo.list = false
    return
  end
  if not vim.wo.list then vim.wo.list = true end
  local pattern = mode == 'i' and [[\s\+\%#\@<!$]] or [[\s\+$]]
  if vim.w.whitespace_match_number then
    fn.matchdelete(vim.w.whitespace_match_number)
    fn.matchadd('ExtraWhitespace', pattern, 10, vim.w.whitespace_match_number)
    return
  end
  vim.w.whitespace_match_number = fn.matchadd('ExtraWhitespace', pattern)
end

local function is_excluded(bufnr)
  return vim.tbl_contains(config.excluded_fts, vim.bo[bufnr].filetype)
end

ar.highlight.set('ExtraWhitespace', { fg = 'red' })

ar.augroup('WhitespaceMatch', {
  event = { 'ColorScheme' },
  desc = 'Add extra whitespace highlight',
  pattern = { '*' },
  command = function() ar.highlight.set('ExtraWhitespace', { fg = 'red' }) end,
}, {
  event = { 'BufEnter', 'FileType', 'InsertLeave' },
  pattern = { '*' },
  desc = 'Show extra whitespace on insert leave, buf enter or filetype',
  command = function(args)
    if is_excluded(args.buf) then return end
    toggle_trailing('n')
  end,
}, {
  event = { 'InsertEnter' },
  desc = 'Show extra whitespace on insert enter',
  pattern = { '*' },
  command = function(args)
    if is_excluded(args.buf) then return end
    toggle_trailing('i')
  end,
})
