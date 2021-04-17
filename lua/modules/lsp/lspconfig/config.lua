local api = vim.api
local config = {}

local function get_cursor_pos()
  return {vim.fn.line('.'), vim.fn.col('.')}
end

local function debounce(func, timeout)
  local timer_id = nil
  return function(...)
    if timer_id ~= nil then
      vim.fn.timer_stop(timer_id)
    end
    local args = {...}

    timer_id = vim.fn.timer_start(timeout, function()
      func(args)
      timer_id = nil
    end)
  end
end

function config.global_cmd(name, func)
  vim.cmd('command! -nargs=0 ' .. name .. ' call v:lua.' .. func .. '()')
end

function config.map(bufnr, mode, key, command, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  api.nvim_buf_set_keymap(bufnr, mode, key, command, options)
end

function config.buf_map(bufnr, key, command, opts)
  config.map(bufnr, 'n', key, "<cmd>lua " .. command .. "<CR>", opts)
end

function config.leader_buf_map(bufnr, key, command, opts)
  config.map(bufnr, 'n', '<leader>' .. key, "<cmd>lua " .. command .. "<CR>",
             opts)
end

function config.nvim_create_augroup(group_name, definitions)
  vim.api.nvim_command('augroup ' .. group_name)
  vim.api.nvim_command('autocmd!')
  for _, def in ipairs(definitions) do
    local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
    vim.api.nvim_command(command)
  end
  vim.api.nvim_command('augroup END')
end

config.show_lsp_diagnostics = (function()
  local debounced = debounce(require'lspsaga.diagnostic'.show_line_diagnostics,
                             300)
  local cursorpos = get_cursor_pos()
  return function()
    local new_cursor = get_cursor_pos()
    if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
        (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
      cursorpos = new_cursor
      debounced()
    end
  end
end)()

config.hl_cmds = [[
  highlight! LSPCurlyUnderline gui=undercurl
  highlight! LSPUnderline gui=underline
  highlight! LspDiagnosticsUnderlineHint gui=undercurl
  highlight! LspDiagnosticsUnderlineInformation gui=undercurl
  highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow
  highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red

  highlight! LspDiagnosticsSignHint guifg=cyan
  highlight! LspDiagnosticsSignInformation guifg=lightblue
  highlight! LspDiagnosticsSignWarning guifg=darkyellow
  highlight! LspDiagnosticsSignError guifg=red
]]

return config
