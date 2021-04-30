local api = vim.api
local utils = require 'internal.utils'
local buf_cmd_map, buf_map, global_cmd = utils.buf_cmd_map, utils.buf_map,
                                         utils.global_cmd
local M = {}

M.diagnostics = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = true,
        virtual_text = {spacing = 4, prefix = '»'},
        signs = {enable = true, priority = 20}
      })
}

M.diagnostics_off = {
  ["textDocument/publishDiagnostics"] = vim.lsp.with(
      vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = false,
        update_in_insert = false,
        virtual_text = false,
        signs = false
      })
}

M.lsp_saga = function(bufnr)
  if not packer_plugins['lspsaga.nvim'].loaded then
    vim.cmd [[packadd lspsaga.nvim]]
  end

  local saga = require 'lspsaga'
  saga.init_lsp_saga(require'modules.lang.config'.lsp_saga())

  buf_map(bufnr, "<Leader>vD", "Lspsaga preview_definition")
  buf_map(bufnr, "<Leader>vf", "Lspsaga lsp_finder")
  buf_map(bufnr, "<Leader>va", "Lspsaga code_action")
  buf_map(bufnr, "<Leader>va", "Lspsaga range_code_action")
  buf_map(bufnr, "<Leader>vls", "Lspsaga signature_help")
  buf_map(bufnr, "<Leader>vrr", "Lspsaga rename")
  buf_map(bufnr, "<Leader>vdb", "Lspsaga diagnostic_jump_prev")
  buf_map(bufnr, "<Leader>vdn", "Lspsaga diagnostic_jump_next")
  buf_map(bufnr, "<Leader>vdl", "Lspsaga show_line_diagnostics")
  buf_map(bufnr, "K", "Lspsaga hover_doc")
  buf_cmd_map(bufnr, "<C-f>",
              "require('lspsaga.action').smart_scroll_with_saga(1)")
  buf_cmd_map(bufnr, "<c-b>",
              "require('lspsaga.action').smart_scroll_with_saga(-1)")
end

M.lsp_highlight_cmds = function()
  api.nvim_exec([[
    highlight! LSPCurlyUnderline gui=undercurl
    highlight! LSPUnderline gui=underline
    highlight! LspDiagnosticsUnderlineHint gui=undercurl
    highlight! LspDiagnosticsUnderlineInformation gui=undercurl
    highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow
    highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red

    highlight! LspDiagnosticsSignHint guifg=#98be65
    highlight! LspDiagnosticsSignInformation guifg=#51afef
    highlight! LspDiagnosticsSignWarning guifg=darkyellow
    highlight! LspDiagnosticsSignError guifg=red
  ]], false)
end

M.lsp_line_diagnostics = function()
  api.nvim_exec([[
    augroup hover_diagnostics
      autocmd! * <buffer>
      au CursorHold * lua require("modules.lang.lsp.lspconfig.utils").show_lsp_diagnostics()
    augroup END
  ]], false)
end

M.lsp_mappings = function(bufnr)
  buf_cmd_map(bufnr, "gsd", "vim.lsp.buf.document_symbol()")
  buf_cmd_map(bufnr, "gsw", "vim.lsp.buf.workspace_symbol()")
  buf_cmd_map(bufnr, "gi", "vim.lsp.buf.implementation()")
  buf_cmd_map(bufnr, "gr", "vim.lsp.buf.references()")
  buf_cmd_map(bufnr, "<Leader>vle", "vim.lsp.buf.type_definition()")
  buf_cmd_map(bufnr, "<Leader>vll", 'vim.lsp.diagnostic.set_loclist()')
  buf_cmd_map(bufnr, "<Leader>vrn", "vim.lsp.buf.rename()")
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
  if not packer_plugins['lspsaga.nvim'].loaded then
    vim.cmd [[packadd lspsaga.nvim]]
  end

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
