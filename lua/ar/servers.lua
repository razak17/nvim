---@diagnostic disable: missing-fields
--------------------------------------------------------------------------------
-- Language servers
--------------------------------------------------------------------------------
local function get_clangd_cmd()
  local cmd = ar.is_available('mason.nvim')
      and vim.fn.expand('$MASON') .. '/bin/clangd'
    or 'clangd'
  -- stylua: ignore
  return {
    cmd, '--all-scopes-completion', '--background-index',
    '--cross-file-rename', '--header-insertion=never',
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

local ts_code_action_sources = {
  add_missing_imports = 'source.addMissingImports.ts',
  organize_imports = 'source.organizeImports',
  remove_unused = 'source.removeUnused',
}

local function create_ts_action(source, description)
  return {
    function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { source },
          diagnostics = {},
        },
      })
    end,
    description = description,
  }
end

---@type lspconfig.Config
local servers = {
  astro = {},
  biome = {},
  clangd = { cmd = get_clangd_cmd() },
  cmake = {},
  cssls = {},
  dockerls = {},
  -- golangci_lint_ls = {},
  marksman = {},
  prismals = {},
  prosemd_lsp = {},
  svelte = {},
  taplo = {},
  yamlls = {},
  vimls = {},
  vue_ls = {},
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
    root_dir = require('lspconfig.util').root_pattern(
      'deno.json',
      'deno.jsonc'
    ),
  },
  docker_compose_language_service = function()
    return {
      root_markers = { 'docker-compose.yaml', 'docker-compose.yml' },
      filetypes = { 'yaml', 'dockerfile' },
    }
  end,
  eslint = {
    settings = {
      -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      workingDirectories = { mode = 'auto' },
    },
  },
  elixirls = {},
  emmet_ls = {
    root_dir = function(fname)
      return require('lspconfig.util').root_pattern('package.json')(fname)
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
    root_dir = require('lspconfig.util').root_pattern(
      '.graphqlrc*',
      '.graphql.config.*',
      'graphql.config.*'
    ),
  },
  -- jdtls = {},
  jedi_language_server = {},
  jsonls = {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas({
          extra = {
            {
              description = 'ArConfig',
              fileMatch = { '.rvim.json' },
              name = '.rvim.json',
              url = 'https://raw.githubusercontent.com/razak17/nvim/refs/heads/main/rvim.schema.json',
              -- url = 'file:///home/razak/.config/rvim/rvim.schema.json',
            },
          },
        }),
        validate = { enable = true },
      },
    },
  },
  lemminx = {
    filetypes = { 'xml', 'xsl', 'xslt', 'svg', 'ant' },
    single_file_support = true,
    init_options = {
      settings = {
        xml = {
          format = {
            enabled = true,
            maxLineWidth = 280,
            splitAttributes = 'preserve', -- 'preserve' | 'alignWithFirst' | 'alignWithFirstAndIndent' | 'alignWithFirstAttr'
            joinContentLines = true,
            preservedNewlines = 1,
            insertSpaces = true,
            tabSize = 4,
          },
        },
        xslt = {
          format = {
            enabled = true,
            splitAttributes = 'preserve',
            maxLineWidth = 280,
          },
        },
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
      settings = {
        logLevel = 'error',
        lint = {
          ignore = { 'D100' }, -- ignore missing module docstring
        },
      },
    },
  },
  sqls = {},
  tailwindcss = {},
  tinymist = {
    settings = {
      formatterMode = 'typstyle',
      exportPdf = 'onType',
      semanticTokens = 'disable',
    },
  },
  ts_ls = {
    init_options = { documentFormatting = false, hostInfo = 'neovim' },
    commands = {
      AddMissingImports = create_ts_action(
        ts_code_action_sources.add_missing_imports,
        'Add Missing Imports'
      ),
      OrganizeImports = create_ts_action(
        ts_code_action_sources.organize_imports,
        'Organize Imports'
      ),
      RemoveUnused = create_ts_action(
        ts_code_action_sources.remove_unused,
        'Remove Unused Imports'
      ),
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
  ty = {},
  pyrefly = {},
  vtsls = {
    single_file_support = false,
    experimental = {
      completion = { enableServerSideFuzzyMatch = true, entriesLimit = 50 },
    },
    settings = {
      -- NOTE: only works with vtsls
      -- TODO: figure out how to do this with typescript-tools
      complete_function_calls = true,
      ['js/ts'] = {
        implicitProjectConfig = { checkJs = true },
      },
      javascript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = { completeFunctionCalls = true },
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
      typescript = {
        updateImportsOnFileMove = { enabled = 'always' },
        suggest = { completeFunctionCalls = true },
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
      vtsls = {
        enableMoveToFileCodeAction = true,
        autoUseWorkspaceTsdk = true,
        experimental = {
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
    },
  },
}

local manual_servers = {
  tsgo = {
    cmd = { 'tsgo', '--lsp', '--stdio' },
    filetypes = {
      'javascript',
      'javascriptreact',
      'javascript.jsx',
      'typescript',
      'typescriptreact',
      'typescript.tsx',
    },
    root_markers = {
      'tsconfig.json',
      'jsconfig.json',
      'package.json',
      '.git',
      'tsconfig.base.json',
    },
  },
}

---@param name string
---@param config lspconfig.Config?
---@return lspconfig.Config
local function capabilities(name, config)
  config = config or {}
  local has_cmp, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
  local has_blink, blink = pcall(require, 'blink.cmp')
  config.capabilities = vim.tbl_deep_extend(
    'force',
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_cmp and cmp_nvim_lsp.default_capabilities() or {},
    has_blink and blink.get_lsp_capabilities() or {},
    config.capabilities or {}
  )
  if name == 'clangd' then
    vim.tbl_deep_extend('force', config.capabilities, {
      offsetEncoding = { 'utf-16' },
      general = { positionEncodings = { 'utf-16' } },
    })
  end
  local lsp_flags = { debounce_text_changes = 150 }
  if config.flags then
    config.flags = vim.tbl_deep_extend('keep', config.flags, lsp_flags)
  else
    config.flags = lsp_flags
  end
  return config
end

---Get the configuration for a specific language server
---@param name string?
---@param opts? { manual?: boolean }
---@return table<string, any>?
local function get(name, opts)
  opts = opts or {}
  local config = servers[name]
  if opts.manual then config = manual_servers[name] end
  if not config then return {} end
  if type(config) == 'function' then config = config() end
  return capabilities(name, config)
end

---Get the list of language servers
---@param opts? { manual?: boolean }
---@return string[]
local function names(opts)
  opts = opts or {}
  local lsp_servers = opts.manual and manual_servers or servers
  return vim.tbl_keys(lsp_servers)
end

return {
  list = servers,
  capabilities = capabilities,
  get = get,
  names = names,
}
