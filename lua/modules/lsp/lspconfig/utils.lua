local api = vim.api
local utils = require 'internal.utils'
local buf_map, global_cmd, leader_buf_map = utils.buf_map, utils.global_cmd,
                                            utils.leader_buf_map
local M = {}

M.lspkind = function()
  require('lspkind').init()
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
  local function lbuf_map(key, command)
    leader_buf_map(bufnr, key, command)
  end

  lbuf_map("vD", "require'lspsaga.provider'.preview_definition()")
  lbuf_map("vf", "require'lspsaga.provider'.lsp_finder()")
  lbuf_map("va", "require'lspsaga.codeaction'.code_action()")
  lbuf_map("vls", "require'lspsaga.signaturehelp'.signature_help()")
  lbuf_map("vlr", "require'lspsaga.rename'.rename()")
  lbuf_map("vle", "vim.lsp.buf.type_definition()")
  buf_map(bufnr, "gsd", "vim.lsp.buf.document_symbol()")
  buf_map(bufnr, "gsw", "vim.lsp.buf.workspace_symbol()")
  buf_map(bufnr, "gi", "vim.lsp.buf.implementation()")
  buf_map(bufnr, "gr", "vim.lsp.buf.references()")
  buf_map(bufnr, "K", "require'lspsaga.hover'.render_hover_doc()")

  require'lspsaga'.init_lsp_saga(require'modules.completion.config'.saga())
  lbuf_map("vdb", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
  lbuf_map("vdn", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
  lbuf_map('vdl', 'vim.lsp.diagnostic.set_loclist()')
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
