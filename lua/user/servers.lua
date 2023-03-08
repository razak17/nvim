----------------------------------------------------------------------------------------------------
-- Language servers
----------------------------------------------------------------------------------------------------
local fn = vim.fn

local servers = {
  astro = {},
  bashls = {},
  clangd = {},
  clojure_lsp = {},
  cmake = {},
  cssls = {},
  dockerls = {},
  marksman = {},
  prismals = {},
  quick_lint_js = {},
  sqls = {},
  svelte = {},
  eslint = {},
  yamlls = {},
  tsserver = {
    on_attach = function(client)
      client.server_capabilities.documentFormattingProvider = false -- 0.8 and later
    end,
    -- NOTE: Apparently setting this to false improves performance
    -- https://github.com/sublimelsp/LSP-typescript/issues/129#issuecomment-1281643371
    initializationOptions = {
      preferences = { includeCompletionsForModuleExports = false },
    },
  },
  vimls = {},
  prosemd_lsp = {
    root_dir = function(fname) return require('lspconfig/util').root_pattern('README.md')(fname) end,
  },
  rust_analyzer = {},
  denols = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('deno.json', 'deno.jsonc')(fname)
    end,
  },
  emmet_ls = {
    filetypes = { 'astro', 'html', 'css', 'sass', 'scss', 'typescriptreact', 'javascriptreact' },
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
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { '-node_modules' },
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
  jsonls = {
    init_options = { provideFormatter = false },
    settings = {
      json = {
        validate = { enable = true },
        schemas = require('schemastore').json.schemas(),
      },
    },
    root_dir = function(fname) return require('lspconfig/util').root_pattern('package.json')(fname) end,
  },
  pyright = {
    python = {
      analysis = {
        typeCheckingMode = 'off',
        autoSearchPaths = true,
        diagnosticMode = 'workspace',
        useLibraryCodeForTypes = true,
        diagnosticSeverityOverrides = { reportUndefinedVariable = 'none' },
      },
    },
  },
  lua_ls = function()
    return {
      settings = {
        Lua = {
          runtime = {
            special = { reload = 'require' },
            version = 'LuaJIT',
          },
          hint = { enable = true, arrayIndex = 'Disable', setType = true },
          format = { enable = false },
          diagnostics = { globals = { 'vim', 'describe', 'it', 'before_each', 'after_each' } },
          workspace = {
            library = {
              fn.expand('$VIMRUNTIME/lua'),
              require('neodev.config').types(),
            },
            checkThirdParty = false,
          },
          telemetry = { enable = false },
        },
      },
    }
  end,
  tailwindcss = {
    -- cmd = { '/home/razak/.bun/bin/tailwindcss-language-server', '--stdio' },
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('tailwind.config.js', 'tailwind.config.cjs')(
        fname
      )
    end,
  },
  vuels = {
    setup = {
      root_dir = function(fname)
        return require('lspconfig/util').root_pattern('vue.config.js', 'package.json')(fname)
      end,
      init_options = {
        config = {
          vetur = {
            useWorkspaceDependencies = true,
            completion = { autoImport = true, tagCasing = 'kebab', useScaffoldSnippets = true },
            validation = { script = true, style = true, template = true },
          },
        },
      },
    },
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
return function(name)
  local config = servers[name]
  if not config then return false end
  if type(config) == 'function' then config = config() end
  local ok, cmp_nvim_lsp = rvim.require('cmp_nvim_lsp')
  if ok then config.capabilities = cmp_nvim_lsp.default_capabilities() end
  config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
    textDocument = {
      colorProvider = { dynamicRegistration = true },
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
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
