local api = vim.api
local M = {}

function M.get_cursor_pos()
    return {vim.fn.line('.'), vim.fn.col('.')}
end

function M.global_cmd(name, func)
    vim.cmd('command! -nargs=0 ' .. name .. ' call v:lua.' .. func .. '()')
end

function M.map(bufnr, mode, key, command, opts)
    local options = {noremap = true, silent = true}
    if opts then options = vim.tbl_extend('force', options, opts) end
    api.nvim_buf_set_keymap(bufnr, mode, key, command, options)
end

function M.buf_map(bufnr, key, command, opts)
    M.map(bufnr, 'n', key, "<cmd>lua " .. command .. "<CR>", opts)
end

function M.leader_buf_map(bufnr, key, command, opts)
    M.map(bufnr, 'n', '<leader>' .. key, "<cmd>lua " .. command .. "<CR>", opts)
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
    local debounced = M.debounce(
                          require'lspsaga.diagnostic'.show_line_diagnostics, 300)
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

function M.document_highlight()
    api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#2c323c guifg=#e5c07b
      hi LspReferenceText cterm=bold ctermbg=red guibg=#2c323c
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#2c323c
      augroup lsp_document_highlight
        autocmd! * <buffer>
        au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        au CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
end

M.hl_cmds = [[
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

return M
