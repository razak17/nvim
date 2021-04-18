local api, ex = vim.api, vim.fn.executable
local G = require 'core.global'
local utils = require 'modules.lsp.lspconfig.utils'
local rpattern = require'lspconfig.util'.root_pattern
local lspconfig = require 'lspconfig'
local buf_map, global_cmd, leader_buf_map = utils.buf_map, utils.global_cmd,
                                            utils.leader_buf_map
require 'modules.lsp.lspconfig.config'

local simple_lsp = {
  jsonls = "vscode-json-languageserver",
  cssls = "css-languageserver",
  dockerls = "docker-langserver",
  graphql = "graphql-lsp",
  html = "html-languageserver",
  svelte = "svelteserver",
  vimls = "vim-language-server",
  yamlls = "yaml-language-server"
}

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

  api.nvim_exec(utils.hl_cmds, false)

  local function lbuf_map(key, command)
    leader_buf_map(bufnr, key, command)
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

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

  api.nvim_exec([[
      augroup hover_diagnostics
        autocmd! * <buffer>
        au CursorHold * lua require 'modules.lsp.lspconfig.utils'.show_lsp_diagnostics()
      augroup END
    ]], false)

  if client.resolved_capabilities.document_formatting then
    global_cmd("LspBeforeSave", "lsp_before_save")
    global_cmd("LspFormatting", "lsp_formatting")
    vim.cmd [[ LspBeforeSave ]]
  end

  if client.config.flags then
    client.config.flags.allow_incremental_sync = true
  end

  if client.resolved_capabilities.document_highlight then
    utils.document_highlight()
  end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.codeAction = utils.code_action

if ex("bash-language-server") then
  lspconfig.bashls.setup {
    cmd_env = {GLOB_PATTERN = "*@(.sh|.zsh|.inc|.bash|.command)"},
    filetypes = {"sh", "zsh"},
    on_attach = enhance_attach
  }
end

if ex(G.elixirls_binary) then
  lspconfig.elixirls.setup {
    cmd = {G.elixirls_root_path .. ".bin/language_server.sh"},
    elixirls = {dialyzerEnabled = false},
    capabilities = capabilities,
    on_attach = enhance_attach
  }
end

if ex(G.sumneko_binary) then
  lspconfig.sumneko_lua.setup {
    capabilities = capabilities,
    on_attach = enhance_attach,
    cmd = {G.sumneko_binary, "-E", G.sumneko_root_path .. "/main.lua"},
    settings = {
      Lua = {
        runtime = {version = "LuaJIT", path = vim.split(package.path, ';')},
        diagnostics = {enable = true, globals = {"vim", "packer_plugins"}},
        workspace = {library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true}}
      }
    }
  }
end

if ex("typescript-language-server") then
  lspconfig.tsserver.setup {
    root_dir = rpattern('tsconfig.json', 'package.json', '.git', vim.fn.getcwd()),
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false
      client.resolved_capabilities.document_highlight = false
      enhance_attach(client, bufnr)
    end
  }
end

if ex("pyright") then
  lspconfig.pyright.setup {
    on_attach = enhance_attach,
    root_dir = rpattern('.git', vim.fn.getcwd()),
    capabilities = capabilities
  }
end

if ex("clangd") then
  lspconfig.clangd.setup {
    cmd = {
      'clangd',
      "--background-index",
      '--clang-tidy',
      '--completion-style=bundled',
      '--header-insertion=iwyu',
      '--suggest-missing-includes',
      '--cross-file-rename'
    },
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true
    },
    capabilities = capabilities,
    on_attach = enhance_attach
  }
end

if ex("rust-analyzer") then
  lspconfig.rust_analyzer.setup {
    checkOnSave = {command = "clippy"},
    on_attach = enhance_attach
  }
end

if ex('gopls') then
  lspconfig.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    capabilities = capabilities,
    on_attach = enhance_attach,
    init_options = {usePlaceholders = true, completeUnimported = true}
  }
end

if ex("efm-langserver") then
  require'modules.lsp.efm'.setup(enhance_attach)
end

for lsp, exec in pairs(simple_lsp) do
  if ex(exec) then
    lspconfig[lsp].setup {
      capabilities = capabilities,
      on_attach = enhance_attach,
      root_dir = rpattern('.gitignore', '.git', vim.fn.getcwd())
    }
  end
end
