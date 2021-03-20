local api = vim.api
local saga = require 'lspsaga'
local utils = require 'modules.completion.lsp.utils'
local lspconf = require 'modules.completion.lsp.conf'
local hl_cmds = utils.hl_cmds
local global_cmd = utils.global_cmd
local document_highlight = utils.document_highlight
local buf_map = utils.buf_map
local leader_buf_map = utils.leader_buf_map

function _G.reload_lsp()
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    vim.cmd [[edit]]
end

function _G.open_lsp_log()
    local path = vim.lsp.get_log_path()
    vim.cmd("edit " .. path)
end

function _G.lsp_formatting()
    vim.lsp.buf.formatting()
end

function _G.lsp_toggle_virtual_text()
    local virtual_text = {}
    virtual_text.show = true
    virtual_text.show = not virtual_text.show
    vim.lsp.diagnostic.display(vim.lsp.diagnostic.get(0, 1), 0, 1,
                               {virtual_text = virtual_text.show})
end

function _G.lsp_before_save()
    local defs = {}
    local ext = vim.fn.expand('%:e')
    table.insert(defs, {
        "BufWritePre", '*.' .. ext, "lua vim.lsp.buf.formatting_sync(nil,1000)"
    })
    api.nvim_command('augroup lsp_before_save')
    api.nvim_command('autocmd!')
    for _, def in ipairs(defs) do
        local command = table.concat(vim.tbl_flatten {'autocmd', def}, ' ')
        api.nvim_command(command)
    end
    api.nvim_command('augroup END')
end

global_cmd("LspLog", "open_lsp_log")
global_cmd("LspRestart", "reload_lsp")
global_cmd("LspToggleVirtualText", "lsp_toggle_virtual_text")

vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        underline = true,
        update_in_insert = true,
        virtual_text = {spacing = 4},
        signs = {enable = true, priority = 20}
    })

local enhance_attach = function(client, bufnr)
    require('lspkind').init()

    api.nvim_exec(hl_cmds, false)

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
    -- api.nvim_command("au CursorMoved * lua require 'modules.completion.lsp.utils'.show_lsp_diagnostics()")

    if client.resolved_capabilities.document_formatting then
        global_cmd("LspBeforeSave", "lsp_before_save")
        global_cmd("LspFormatting", "lsp_formatting")
        vim.cmd [[ LspBeforeSave ]]
    end

    if client.config.flags then
        client.config.flags.allow_incremental_sync = true
    end

    if client.resolved_capabilities.document_highlight then
        document_highlight()
    end

    api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

lspconf.setup(enhance_attach)

