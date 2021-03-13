local api = vim.api
local M = {}

function M.get_cursor_pos() return {vim.fn.line('.'), vim.fn.col('.')} end

function M.mapper(key, command)
  local options = { noremap=true, silent=true }
  api.nvim_buf_set_keymap(0, 'n', key, command, options)
end

function M.leader_buf_map(bufnr, key, command, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  api.nvim_buf_set_keymap(bufnr, 'n', '<leader>' .. key, "<cmd>lua " .. command .. "<CR>", opts)
end

function M.format()
  local defs = {}
  local ext = vim.fn.expand('%:e')
  table.insert(defs,{"BufWritePre", '*.'..ext ,
  "lua vim.lsp.buf.formatting_sync(nil,1000)"})
  api.nvim_command('augroup lsp_before_save')
  api.nvim_command('autocmd!')
  for _, def in ipairs(defs) do
  local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
  api.nvim_command(command)
  end
  api.nvim_command('augroup END')
end

function M.debounce(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then vim.fn.timer_stop(timer_id) end
    local args = {...}

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

M.show_lsp_diagnostics = (function()
  local debounced =
    M.debounce(require'lspsaga.diagnostic'.show_line_diagnostics, 300)
  local cursorpos = M.get_cursor_pos()
  return function()
    local new_cursor = M.get_cursor_pos()
    if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
      (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
      cursorpos = new_cursor
      debounced()
    end
  end
end)()

return M
