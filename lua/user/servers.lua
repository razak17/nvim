----------------------------------------------------------------------------------------------------
-- Language servers
----------------------------------------------------------------------------------------------------
---@type lspconfig.options
local servers = {
  astro = {},
  bashls = {},
  clangd = {},
  cmake = {},
  cssls = {},
  dockerls = {},
  eslint = {},
  lemminx = {},
  marksman = {},
  prismals = {},
  svelte = {},
  yamlls = {},
  vimls = {},
  volar = {},
  docker_compose_language_service = function()
    local lspconfig = require('lspconfig')
    return {
      root_dir = lspconfig.util.root_pattern('docker-compose.yml'),
      filetypes = { 'yaml', 'dockerfile' },
    }
  end,
  prosemd_lsp = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
  rust_analyzer = {
    ['rust-analyzer'] = {
      lens = { enable = true },
      checkOnSave = { enable = true, command = 'clippy' },
    },
  },
  -- vtsls = {
  --   -- NOTE: only works with vtsls
  --   -- TODO: figure out how to do this with typescript-tools
  --   settings = {
  --     ['js/ts'] = {
  --       implicitProjectConfig = { checkJs = true },
  --     },
  --   },
  -- },
  denols = {
    root_dir = function(fname) return require('lspconfig/util').root_pattern('deno.json', 'deno.jsonc')(fname) end,
  },
  emmet_ls = {
    root_dir = function(fname) return require('lspconfig/util').root_pattern('package.json')(fname) end,
  },
  --- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = { generate = true, gc_details = false, test = true, tidy = true },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = { unusedparams = true, loopclosure = true },
        semanticTokens = true,
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { '-node_modules', '-vendor' },
      },
    },
  },
  graphql = {
    on_attach = function(client)
      -- Disable workspaceSymbolProvider because this prevents
      -- searching for symbols in typescript files which this server
      -- is also enabled for.
      -- @see: https://github.com/nvim-telescope/telescope.nvim/issues/964
      client.server_capabilities.workspaceSymbolProvider = false
    end,
  },
  pyright = {
    settings = {
      pyright = {
        disableLanguageServices = false,
        disableOrganizeImports = false,
      },
      python = {
        analysis = {
          autoImportCompletions = true,
          typeCheckingMode = 'basic',
          autoSearchPaths = true,
          diagnosticMode = 'workspace',
          useLibraryCodeForTypes = true,
          diagnosticSeverityOverrides = { reportUndefinedVariable = 'none' },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        codeLens = { enable = true },
        hint = { enable = true, arrayIndex = 'Disable', setType = false, paramName = 'Disable', paramType = true },
        format = { enable = false },
        diagnostics = { globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'rvim', 'join_paths' } },
        completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  tailwindcss = {
    -- cmd = { '/home/razak/.bun/bin/tailwindcss-language-server', '--stdio' },
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('tailwind.config.js', 'tailwind.config.cjs')(fname)
    end,
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
return function(name)
  local config = servers[name]
  if not config then return nil end
  if type(config) == 'function' then config = config() end
  local ok, cmp_nvim_lsp = rvim.pcall(require, 'cmp_nvim_lsp')
  if ok then config.capabilities = cmp_nvim_lsp.default_capabilities() end
  config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
    textDocument = {
      colorProvider = { dynamicRegistration = true },
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
      completion = { completionItem = { documentationFormat = { 'markdown', 'plaintext' } } },
      codeAction = {
        dynamicRegistration = false,
        codeActionLiteralSupport = {
          codeActionKind = {
            valueSet = (function()
              local res = vim.tbl_values(vim.lsp.protocol.CodeActionKind)
              table.sort(res)
              return res
            end)(),
          },
        },
      },
    },
  })
  return config
end
