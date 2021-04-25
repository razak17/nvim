local api = vim.api
local utils = require 'internal.utils'
local buf_map, leader_buf_map, global_cmd = utils.buf_map, utils.leader_buf_map,
                                            utils.global_cmd

local M = {}

M.lspkind = function()
  require('lspkind').init()
end

M.lsp_saga = function(bufnr)
  require'lspsaga'.init_lsp_saga(require'modules.lsp.config'.lsp_saga())

  leader_buf_map(bufnr, "vD", "require'lspsaga.provider'.preview_definition()")
  leader_buf_map(bufnr, "vf", "require'lspsaga.provider'.lsp_finder()")
  leader_buf_map(bufnr, "va", "require'lspsaga.codeaction'.code_action()")
  leader_buf_map(bufnr, "vls", "require'lspsaga.signaturehelp'.signature_help()")
  leader_buf_map(bufnr, "vrr", "require'lspsaga.rename'.rename()")
  leader_buf_map(bufnr, "vdb",
                 "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
  leader_buf_map(bufnr, "vdn",
                 "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
  leader_buf_map(bufnr, 'vdl', 'vim.lsp.diagnostic.set_loclist()')
  buf_map(bufnr, "K", "require'lspsaga.hover'.render_hover_doc()")
end

M.lsp_highlight_cmds = function()
  api.nvim_exec([[
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
  ]], false)

  api.nvim_exec([[
      augroup hover_diagnostics
        autocmd! * <buffer>
        au CursorHold * lua require 'modules.lsp.lspconfig.utils'.show_lsp_diagnostics()
      augroup END
    ]], false)
end

M.lsp_mappings = function(bufnr)
  leader_buf_map(bufnr, "vle", "vim.lsp.buf.type_definition()")
  buf_map(bufnr, "gsd", "vim.lsp.buf.document_symbol()")
  buf_map(bufnr, "gsw", "vim.lsp.buf.workspace_symbol()")
  buf_map(bufnr, "gi", "vim.lsp.buf.implementation()")
  buf_map(bufnr, "gr", "vim.lsp.buf.references()")
  leader_buf_map(bufnr, "vrn", "vim.lsp.buf.rename()")
end

M.lsp_document_formatting = function(client)
  if client.resolved_capabilities.document_formatting then
    global_cmd("LspBeforeSave", "lsp_before_save")
    global_cmd("LspFormatting", "lsp_formatting")
    vim.cmd [[ LspBeforeSave ]]
  end
end

M.lsp_document_highlight = function(client)
  if client.resolved_capabilities.document_highlight then
    api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#2c323c
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
end

M.show_lsp_diagnostics = (function()
  local debounced = utils.debounce(
                        require'lspsaga.diagnostic'.show_line_diagnostics, 300)
  local cursorpos = utils.get_cursor_pos()
  return function()
    local new_cursor = utils.get_cursor_pos()
    if (new_cursor[1] ~= 1 and new_cursor[2] ~= 1) and
        (new_cursor[1] ~= cursorpos[1] or new_cursor[2] ~= cursorpos[2]) then
      cursorpos = new_cursor
      debounced()
    end
  end
end)()

return M
