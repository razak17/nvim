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
        virtual_text = {spacing = 4},
        signs = {enable = true, priority = 20}
    })

local hl_cmds = [[
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

local enhance_attach = function(client, bufnr)
    require('lspkind').init()

    api.nvim_exec(hl_cmds, false)

    local leader_buf_map = utils.leader_buf_map
    local buf_map = utils.buf_map

    local function lbuf_map(key, command)
        leader_buf_map(bufnr, key, command)
    end

    lbuf_map("vD", "require'lspsaga.provider'.preview_definition()")
    lbuf_map("vf", "require'lspsaga.provider'.lsp_finder()")
    lbuf_map("va", "require'lspsaga.codeaction'.code_action()")
    lbuf_map("vlS", "require'lspsaga.signaturehelp'.signature_help()")
    lbuf_map("vlR", "require'lspsaga.rename'.rename()")
    lbuf_map("vli", "vim.lsp.buf.implementation()")
    lbuf_map("vlr", "vim.lsp.buf.references()")
    lbuf_map("vlt", "vim.lsp.buf.type_definition()")
    lbuf_map("vlsd", "vim.lsp.buf.document_symbol()")
    lbuf_map("vlsw", "vim.lsp.buf.workspace_symbol()")
    buf_map(bufnr, "K", "require'lspsaga.hover'.render_hover_doc()")

    saga.init_lsp_saga(require'modules.completion.conf'.saga())
    lbuf_map("vdb", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
    lbuf_map("vdn", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
    lbuf_map("vdc", "require'lspsaga.diagnostic'.show_line_diagnostics()")
    lbuf_map('vdl', 'vim.lsp.diagnostic.set_loclist()')
    vim.cmd(
        'command! -nargs=0 LspVirtualTextToggle lua require"modules.completion.lsp.utils".toggleVirtualText()')

    -- api.nvim_command("au CursorMoved * lua require 'modules.completion.lsp.utils'.show_lsp_diagnostics()")

    if client.resolved_capabilities.document_formatting then
        utils.lsp_before_save()
    end

    if client.config.flags then
        client.config.flags.allow_incremental_sync = true
    end

    if client.resolved_capabilities.document_highlight then
        utils.document_highlight()
    end

    api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

lspconf.setup(enhance_attach)

