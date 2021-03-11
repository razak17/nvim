local utils = require 'modules.completion.lsp.utils'
local saga = require 'lspsaga'

local hl_cmds = [[
  highlight! LSPCurlyUnderline gui=undercurl
  highlight! LSPUnderline gui=underline
  highlight! LspDiagnosticsUnderlineHint gui=undercurl
  highlight! LspDiagnosticsUnderlineInformation gui=undercurl
  highlight! LspDiagnosticsUnderlineWarning gui=undercurl guisp=darkyellow
  highlight! LspDiagnosticsUnderlineError gui=undercurl guisp=red

  highlight! LspDiagnosticsSignHint guifg=yellow
  highlight! LspDiagnosticsSignInformation guifg=lightblue
  highlight! LspDiagnosticsSignWarning guifg=darkyellow
  highlight! LspDiagnosticsSignError guifg=red
]]

local on_attach = function(client, bufnr)
  require('lspkind').init()
  vim.api.nvim_exec(hl_cmds, false)

  local opts = { noremap=true, silent=true }

  local leader_buf_map = utils.leader_buf_map
  -- Binds
  local function buf_map(key, command)
    leader_buf_map(bufnr, key, command, opts)
  end
  buf_map("vD",   "require'lspsaga.provider'.preview_definition()")
  buf_map("vf",   "require'lspsaga.provider'.lsp_finder()")
  buf_map("va",   "require'lspsaga.codeaction'.code_action()")
  buf_map("vlS",  "require'lspsaga.signaturehelp'.signature_help()")
  buf_map("vlR",  "require'lspsaga.rename'.rename()")
  buf_map("vli",  "vim.lsp.buf.implementation()")
  buf_map("vlt",  "vim.lsp.buf.type_definition()")
  buf_map("vlp",  "vim.lsp.buf.peek_definition()")
  buf_map("vlr",  "vim.lsp.buf.references()")
  buf_map("vlsd", "vim.lsp.buf.document_symbol()")
  buf_map("vlsw", "vim.lsp.buf.workspace_symbol()")
  buf_map("vlsh", "require'lspsaga.hover'.render_hover_doc()")
  buf_map("K",    "require'lspsaga.hover'.render_hover_doc()")

  -- Diagnostics
  saga.init_lsp_saga(require 'modules.completion.conf'.saga())
  leader_buf_map(bufnr, "vdb", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()", opts)
  leader_buf_map(bufnr, "vdn", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()", opts)
  leader_buf_map(bufnr, "vdc", "require'lspsaga.diagnostic'.show_line_diagnostics()", opts)
  leader_buf_map(bufnr, 'vdl', 'vim.lsp.diagnostic.set_loclist()', opts)
  vim.api.nvim_command("au CursorMoved * lua require 'modules.completion.lsp.utils'.show_lsp_diagnostics()")

  if client.resolved_capabilities.document_formatting then
    require 'modules.completion.lsp.utils'.format()
  end

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end

  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_command('augroup lsp_aucmds')
    vim.api.nvim_command('au!')
    vim.api.nvim_command('au CursorHold <buffer> lua vim.lsp.buf.document_highlight()')
    vim.api.nvim_command('au CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()')
    vim.api.nvim_command('au CursorMoved <buffer> lua vim.lsp.buf.clear_references()')
    vim.api.nvim_command('augroup END')
  end
end

return on_attach
