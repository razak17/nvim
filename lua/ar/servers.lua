---@diagnostic disable: missing-fields
--------------------------------------------------------------------------------
-- Language servers
--------------------------------------------------------------------------------
local fmt = string.format

local function get_clangd_cmd()
  local cmd = 'clangd'
  if ar.is_available('mason.nvim') then
    local clangd = require('mason-registry').get_package('clangd')
    local path = clangd:get_install_path()
    clangd:get_installed_version(function(success, version_or_err)
      if success then
        cmd = fmt('%s/clangd_%s/bin/clangd', path, version_or_err)
      end
    end)
  end
  return {
    cmd,
    '--all-scopes-completion',
    '--background-index',
    '--cross-file-rename',
    '--header-insertion=never',
  }
end

local pyright_analysis = {
  indexing = true,
  autoImportCompletions = true,
  typeCheckingMode = 'basic', -- strict, standard
  autoSearchPaths = true,
  diagnosticMode = 'openFilesOnly', -- workspace
  useLibraryCodeForTypes = true,
  diagnosticSeverityOverrides = {
    -- NOTE: enable to get nvim-lspimport working
    reportUndefinedVariable = 'error',
    reportPropertyTypeMismatch = 'warning',
    reportImportCycles = 'warning',
    reportUnusedFunction = 'warning',
    reportDuplicateImport = 'warning',
    reportPrivateUsage = 'warning',
    reportTypeCommentUsage = 'warning',
    reportConstantRedefinition = 'error',
    reportDeprecated = 'warning',
    reportIncompatibleMethodOverride = 'warning',
    reportIncompatibleVariableOverride = 'error',
    reportInconsistentConstructor = 'error',
    reportOverlappingOverload = 'error',
    reportMissingSuperCall = 'error',
    reportUnititializedInstanceVariable = 'error',
    -- reportUnknownParameterType = 'warning',
    -- reportUnknownArgumentType = 'warning',
    reportUnknownLambdaType = 'warning',
    -- reportUnknownVariableType = 'warning',
    -- reportUnknownMemberType = 'warning',
    reportMissingParameterType = 'warning',
    -- reportMissingTypeArgument = 'warning',
    reportUnnecessaryIsInstance = 'warning',
    reportUnnecessaryCast = 'warning',
    reportUnnecessaryComparison = 'warning',
    reportUnnecessaryContains = 'warning',
    reportAssertAlwaysTrue = 'warning',
    reportSelfClsParameterName = 'error',
    reportImplicitStringConcatenation = 'warning',
    reportUnusedExpression = 'warning',
    reportUnnecessaryTypeIgnoreComment = 'warning',
    reportMatchNotExhaustive = 'error',
    reportShadowedImports = 'error',
  },
}
---@type lspconfig.options
local servers = {
  astro = {},
  clangd = { cmd = get_clangd_cmd() },
  cmake = {},
  cssls = {},
  dockerls = {},
  -- golangci_lint_ls = {},
  lemminx = {},
  marksman = {},
  prismals = {},
  prosemd_lsp = {},
  svelte = {},
  yamlls = {},
  vimls = {},
  volar = {},
  basedpyright = {
    settings = {
      basedpyright = {
        analysis = pyright_analysis,
      },
    },
  },
  bashls = {
    settings = {
      bashIde = {
        -- Disable shellcheck in bash-language-server. It conflicts with linter settings.
        shellcheckPath = '',
      },
    },
  },
  denols = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('deno.json', 'deno.jsonc')(
        fname
      )
    end,
  },
  docker_compose_language_service = function()
    local lspconfig = require('lspconfig')
    return {
      root_dir = lspconfig.util.root_pattern('docker-compose.yml'),
      filetypes = { 'yaml', 'dockerfile' },
    }
  end,
  eslint = {
    settings = {
      -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      workingDirectories = { mode = 'auto' },
    },
  },
  emmet_ls = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern('package.json')(fname)
    end,
  },
  emmet_language_server = {},
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
          assignVariableTypes = false,
          compositeLiteralFields = true,
          constantValues = true,
          parameterNames = true,
          functionTypeParameters = false,
          rangeVariableTypes = false,
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
  jedi_language_server = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        codeLens = { enable = true },
        hint = {
          enable = true,
          arrayIndex = 'Disable',
          setType = false,
          paramName = 'Disable',
          paramType = true,
        },
        format = { enable = false },
        diagnostics = {
          globals = {
            'vim',
            'describe',
            'it',
            'before_each',
            'after_each',
            'ar',
            'join_paths',
          },
        },
        completion = { keywordSnippet = 'Replace', callSnippet = 'Replace' },
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {
    settings = {
      verboseOutput = true,
      autoImportCompletion = true,
      pyright = {
        disableLanguageServices = false,
        disableOrganizeImports = false,
      },
      python = {
        analysis = pyright_analysis,
      },
    },
  },
  ruff = {
    cmd_env = { RUFF_TRACE = 'messages' },
    init_options = {
      settings = { logLevel = 'error' },
    },
  },
  ruff_lsp = {
    settings = {
      args = { '--select', 'ALL', '--ignore', 'D100' },
    },
  },
  tailwindcss = {
    root_dir = function(fname)
      return require('lspconfig/util').root_pattern(
        'tailwind.config.js',
        'tailwind.config.ts',
        'tailwind.config.cjs'
      )(fname)
    end,
  },
  ts_ls = {
    init_options = {
      documentFormatting = false,
      hostInfo = 'neovim',
    },
    commands = {
      OrganizeImports = {
        function()
          vim.lsp.buf.code_action({
            apply = true,
            context = {
              only = { 'source.organizeImports' },
              diagnostics = {},
            },
          })
        end,
        description = 'Organize Imports',
      },
      RemoveUnusedImports = {
        function()
          vim.lsp.buf.code_action({
            apply = true,
            context = {
              ---@diagnostic disable-next-line: assign-type-mismatch
              only = { 'source.removeUnused' },
              diagnostics = {},
            },
          })
        end,
        description = 'organize imports',
      },
    },
    settings = {
      completions = {
        completeFunctionCalls = true,
      },
      javascript = {
        inlayHints = {
          includeInlayParameterNameHints = 'literal', -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = 'literal', -- 'none' | 'literals' | 'all';
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayVariableTypeHintsWhenTypeMatchesName = false,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayVariableTypeHints = true,
          includeInlayFunctionLikeReturnTypeHints = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayEnumMemberValueHints = true,
        },
      },
    },
  },
  vtsls = {
    single_file_support = false,
    settings = {
      -- NOTE: only works with vtsls
      -- TODO: figure out how to do this with typescript-tools
      ['js/ts'] = {
        implicitProjectConfig = { checkJs = true },
      },
      typescript = {
        suggest = {
          completionFunctionCalls = true,
        },
        inlayHints = {
          parameterNames = {
            enabled = 'literals', -- 'none' | 'literals' | 'all'
            suppressWhenArgumentMatchesName = true,
          },
          parameterTypes = { enabled = false },
          variableTypes = { enabled = false },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = false },
          enumMemberValues = { enabled = true },
        },
        tsserver = {
          pluginPaths = { '.' },
          globalPlugins = {
            {
              name = 'typescript-svelte-plugin',
              enableForWorkspaceTypeScriptVersions = true,
            },
          },
        },
      },
      javascript = {
        inlayHints = {
          parameterNames = {
            enabled = 'literals', -- 'none' | 'literals' | 'all'
            suppressWhenArgumentMatchesName = true,
          },
          parameterTypes = { enabled = false },
          variableTypes = { enabled = false },
          propertyDeclarationTypes = { enabled = true },
          functionLikeReturnTypes = { enabled = false },
          enumMemberValues = { enabled = true },
        },
      },
    },
  },
}

---Get the configuration for a specific language server
---@param name string?
---@return table<string, any>?
local function get(name)
  local config = servers[name]
  if not config then return nil end
  if type(config) == 'function' then config = config() end
  local ok, cmp_nvim_lsp = ar.pcall(require, 'cmp_nvim_lsp')
  if ok then config.capabilities = cmp_nvim_lsp.default_capabilities() end
  config.capabilities = vim.tbl_deep_extend('keep', config.capabilities or {}, {
    workspace = {
      didChangeWatchedFiles = { dynamicRegistration = false },
    },
    textDocument = {
      colorProvider = { dynamicRegistration = true },
      foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
      completion = {
        completionItem = { documentationFormat = { 'markdown', 'plaintext' } },
        editsNearCursor = true,
      },
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
  if name == 'clangd' then
    config.capabilities.offsetEncoding = { 'utf-16' }
    config.capabilities.general = {
      positionEncodings = { 'utf-16' },
    }
  end
  local lsp_flags = { debounce_text_changes = 150 }
  if config.flags then
    config.flags = vim.tbl_deep_extend('keep', config.flags, lsp_flags)
  else
    config.flags = lsp_flags
  end
  return config
end

return {
  list = servers,
  get = get,
}
