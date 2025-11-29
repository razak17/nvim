-- https://github.com/yutkat/wb-only-current-line.nvim

local enabled = ar.config.plugin.custom.wb_current_line.enable

if not ar or ar.none or not enabled then return end

local fn = vim.fn

local ignored_filetypes = {
  'NeogitCommitMessage',
  'gitcommit',
  'qf'
}

local function motion(key, back_key)
  if vim.v.count1 > 1 then
    vim.cmd('normal! ' .. vim.v.count1 .. key)
    return
  end

  local initial_line = fn.line('.')
  vim.cmd('normal! ' .. key)
  local new_line = fn.line('.')

  if initial_line ~= new_line then vim.cmd('normal! ' .. back_key) end
end

---@param mode string
---@param key string
---@param back_key string
---@param bufnr number
local function set_keymap(mode, key, back_key, bufnr)
  map(
    mode,
    key,
    function() motion(key, back_key) end,
    { noremap = true, expr = false, silent = false, buffer = bufnr }
  )
end

ar.augroup('wbCurrentLine', {
  event = { 'FileType' },
  command = function(args)
    if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then return end
    set_keymap('n', 'w', 'k$', args.buf)
    set_keymap('v', 'w', 'k$', args.buf)
    set_keymap('n', 'W', 'k$', args.buf)
    set_keymap('v', 'W', 'k$', args.buf)
    set_keymap('n', 'b', 'j^', args.buf)
    set_keymap('v', 'b', 'j^', args.buf)
    set_keymap('n', 'B', 'j^', args.buf)
    set_keymap('v', 'B', 'j^', args.buf)
  end,
})
