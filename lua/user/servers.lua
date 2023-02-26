----------------------------------------------------------------------------------------------------
-- Language servers
----------------------------------------------------------------------------------------------------
local fn = vim.fn

local M = {}

local function global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.colorProvider = { dynamicRegistration = true }
  capabilities.textDocument.completion.completionItem.documentationFormat =
    { 'markdown', 'plaintext' }
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }
  capabilities.textDocument.codeAction = {
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
  }
  capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  local ok, cmp_nvim_lsp = rvim.safe_require('cmp_nvim_lsp')
  if ok then cmp_nvim_lsp.default_capabilities(capabilities) end
  return capabilities
end

M.servers = {
  astro = {},
  bashls = {},
  clangd = {},
  clojure_lsp = {},
  cmake = {},
  cssls = {},
  dockerls = {},
  html = {},
  marksman = {},
  prismals = {},
  quick_lint_js = {},
  sqls = {},
  svelte = {},
  tsserver = {
    -- NOTE: Apparently setting this to false improves performance
    -- https://github.com/sublimelsp/LSP-typescript/issues/129#issuecomment-1281643371
    initializationOptions = {
      preferences = {
        includeCompletionsForModuleExports = false,
      },
    },
  },
  vimls = {},
  prosemd_lsp = {
    root_dir = function(fname) return require('lspconfig/util').root_pattern('README.md')(fname) end,
    single_file_support = false,
  },
  rust_analyzer = {
    root_dir = function(fname) return require('lspconfig/util').root_pattern('Cargo.toml')(fname) end,
    single_file_support = false,
  },
  denols = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('deno.json', 'deno.jsonc')(fname)
    end,
    single_file_support = false,
  },
  emmet_ls = {
    filetypes = { 'astro', 'html', 'css', 'sass', 'scss', 'typescriptreact', 'javascriptreact' },
    root_dir = function(fname) return require('lspconfig/util').root_pattern('package.json')(fname) end,
    single_file_support = false,
  },
  --- https://github.com/golang/tools/blob/master/gopls/doc/settings.md
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        codelenses = {
          generate = true,
          gc_details = false,
          test = true,
          tidy = true,
        },
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
        analyses = {
          unusedparams = true,
          loopclosure = true,
        },
        usePlaceholders = true,
        completeUnimported = true,
        staticcheck = true,
        directoryFilters = { '-node_modules' },
      },
    },
  },
  graphql = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern(
        '.graphqlrc*',
        '.graphql.config.*',
        'graphql.config.*'
      )(fname)
    end,
    single_file_support = false,
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
    single_file_support = false,
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
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern(
        'tailwind.config.js',
        'tailwind.config.cjs',
        'tailwind.js',
        'tailwind.cjs'
      )(fname)
    end,
    single_file_support = false,
  },
  vuels = {
    setup = {
      root_dir = function(fname)
        return require('lspconfig/util').root_pattern('package.json', 'vue.config.js')(fname)
      end,
      init_options = {
        config = {
          vetur = {
            completion = {
              autoImport = true,
              tagCasing = 'kebab',
              useScaffoldSnippets = true,
            },
            useWorkspaceDependencies = true,
            validation = {
              script = true,
              style = true,
              template = true,
            },
          },
        },
      },
    },
  },
  yamlls = {
    settings = {
      yaml = {
        hover = true,
        completion = true,
        validate = true,
        customTags = {
          '!reference sequence', -- necessary for gitlab-ci.yaml files
        },
        schemaStore = {
          enable = true,
          url = 'https://www.schemastore.org/api/json/catalog.json',
        },
        schemas = {
          kubernetes = {
            'daemon.{yml,yaml}',
            'manager.{yml,yaml}',
            'restapi.{yml,yaml}',
            'role.{yml,yaml}',
            'role_binding.{yml,yaml}',
            '*onfigma*.{yml,yaml}',
            '*ngres*.{yml,yaml}',
            '*ecre*.{yml,yaml}',
            '*eployment*.{yml,yaml}',
            '*ervic*.{yml,yaml}',
            'kubectl-edit*.yaml',
          },
        },
      },
    },
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
function M.setup(name)
  local config = name and M.servers[name] or {}
  if not config then return end
  if type(config) == 'function' then config = config() end
  config.capabilities = global_capabilities()
  return config
end

return M
