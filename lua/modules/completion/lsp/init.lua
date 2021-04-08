local api = vim.api
local ex = vim.fn.executable
local G = require 'core.global'
local conf = require 'modules.completion.lsp.config'
local rpattern = require'lspconfig.util'.root_pattern
local lspconfig = require 'lspconfig'
local buf_map = conf.buf_map
local global_cmd = conf.global_cmd
local leader_buf_map = conf.leader_buf_map

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

function _G.reload_lsp()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd [[edit]]
end

function _G.open_lsp_log()
  local path = vim.lsp.get_log_path()
  vim.cmd("edit " .. path)
end

function _G.lsp_formatting()
  vim.lsp.buf.formatting(vim.g[string.format("format_options_%s",
                                             vim.bo.filetype)] or {})
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
    "BufWritePre",
    '*.' .. ext,
    "lua vim.lsp.buf.formatting_sync(nil,1000)"
  })
  conf.nvim_create_augroup('lsp_before_save', defs)
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

  api.nvim_exec(conf.hl_cmds, false)

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

  require'lspsaga'.init_lsp_saga(require'modules.completion.config'.saga())
  lbuf_map("vdb", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()")
  lbuf_map("vdn", "require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()")
  lbuf_map("vdc", "require'lspsaga.diagnostic'.show_line_diagnostics()")
  lbuf_map('vdl', 'vim.lsp.diagnostic.set_loclist()')

  api.nvim_exec([[
      augroup hover_diagnostics
        autocmd! * <buffer>
        au CursorHold * lua require 'modules.completion.lsp.config'.show_lsp_diagnostics()
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

  api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
end

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
    on_attach = enhance_attach
  }
end

if ex(G.sumneko_binary) then
  lspconfig.sumneko_lua.setup {
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
    settings = {documentFormatting = false},
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
    root_dir = rpattern('.git', vim.fn.getcwd())
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
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lspconfig.gopls.setup {
    cmd = {"gopls", "--remote=auto"},
    on_attach = enhance_attach,
    capabilities = capabilities,
    init_options = {usePlaceholders = true, completeUnimported = true}
  }
end

if ex("efm-langserver") then
  require'modules.completion.lsp.efm'.setup(enhance_attach)
end

for lsp, exec in pairs(simple_lsp) do
  if ex(exec) then
    lspconfig[lsp].setup {
      on_attach = enhance_attach,
      root_dir = rpattern('.git', '.gitignore', vim.fn.getcwd())
    }
  end
end
