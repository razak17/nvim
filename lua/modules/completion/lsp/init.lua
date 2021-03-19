local api = vim.api
local saga = require 'lspsaga'
local utils = require 'modules.completion.lsp.utils'
local lspconf = require 'modules.completion.lsp.conf'

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd [[edit]]
end

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

vim.cmd('command! -nargs=0 LspLog call v:lua.open_lsp_log()')
vim.cmd('command! -nargs=0 LspRestart call v:lua.reload_lsp()')

vim.lsp.handlers["textDocument/publishDiagnostics"] =
  vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
    underline = true,
    update_in_insert = true,
    virtual_text = {
      spacing = 4,
    },
    signs = {
      enable = true,
      priority = 20
    },
})

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

local enhance_attach = function(client, bufnr)
  require('lspkind').init()
  api.nvim_exec(hl_cmds, false)

  local opts = { noremap=true, silent=true }

  local leader_buf_map = utils.leader_buf_map

  local function buf_map(key, command)
    leader_buf_map(bufnr, key, command, opts)
  end
  buf_map("vD",   "require'lspsaga.provider'.preview_definition()")
  buf_map("vf",   "require'lspsaga.provider'.lsp_finder()")
  buf_map("va",   "require'lspsaga.codeaction'.code_action()")
  buf_map("vlS",  "require'lspsaga.signaturehelp'.signature_help()")
  buf_map("vlR",  "require'lspsaga.rename'.rename()")
  buf_map("vli",  "vim.lsp.buf.implementation()")
  buf_map("vlr",  "vim.lsp.buf.references()")
  buf_map("vlt",  "vim.lsp.buf.type_definition()")
  buf_map("vlsd", "vim.lsp.buf.document_symbol()")
  buf_map("vlsw", "vim.lsp.buf.workspace_symbol()")
  api.nvim_buf_set_keymap(bufnr, 'n', "K", "<cmd>lua require'lspsaga.hover'.render_hover_doc()<CR>", opts)
  api.nvim_buf_set_keymap(bufnr, 'n', "gd", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)

  saga.init_lsp_saga(require 'modules.completion.conf'.saga())
  buf_map("vdb", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
  buf_map("vdn", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
  buf_map("vdc", "require'lspsaga.diagnostic'.show_line_diagnostics()")
  buf_map('vdl', 'vim.lsp.diagnostic.set_loclist()')
  -- api.nvim_command("au CursorMoved * lua require 'modules.completion.lsp.utils'.show_lsp_diagnostics()")

  if client.resolved_capabilities.document_formatting then
    require 'modules.completion.lsp.utils'.format()
  elseif client.resolved_capabilities.document_range_formatting then
    buf_map("vlf", "vim.lsp.buf.range_formatting()")
  end

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end

  if client.resolved_capabilities.document_highlight then
    api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceText cterm=bold ctermbg=red guibg=#464646
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=#464646
      augroup lsp_document_highlight
        autocmd! * <buffer>
        au CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        au CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        au CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end

  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

lspconf.setup(enhance_attach)

