---@diagnostic disable: missing-fields
--------------------------------------------------------------------------------
-- Language servers
--------------------------------------------------------------------------------
local function get_clangd_cmd()
  local cmd = ar.has('mason.nvim') and vim.fn.expand('$MASON') .. '/bin/clangd'
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
    reportAttributeAccessIssue = 'warning',
    reportArgumentType = 'warning',
    reportAssignmentType = 'warning',
  },
}

-- https://github.com/LazyVim/LazyVim/blob/3a743f7f853bd90894259cd93432d77c688774b4/lua/lazyvim/plugins/lsp/init.lua?plain=1#L71
---@type table<string, vim.lsp.Config|{mason?:boolean, enabled?:boolean}|boolean>
local servers = {
  astro = {},
  biome = {},
  clangd = { cmd = get_clangd_cmd() },
  cmake = {},
  cssls = {},
  css_variables = {},
  denols = {},
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
  copilot = {
    on_init = function()
      ar_config.ai.completion.status = {} ---@type table<number, "ok" | "error" | "pending">
    end,
    handlers = {
      didChangeStatus = function(err, res, ctx)
        if err then return end
        ar_config.ai.completion.status[ctx.client_id] = res.kind ~= 'Normal'
            and 'error'
          or res.busy and 'pending'
          or 'ok'
        if res.status == 'Error' then
          vim.notify('Please use `:LspCopilotSignIn` to sign in to Copilot')
        end
      end,
    },
    settings = {
      telemetry = { telemetryLevel = 'off' },
    },
  },
  docker_compose_language_service = {
    root_markers = { 'docker-compose.yaml', 'docker-compose.yml' },
    filetypes = { 'yaml', 'dockerfile' },
  },
  eslint = {
    settings = {
      -- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
      workingDirectories = { mode = 'auto' },
    },
  },
  elixirls = {},
  emmet_ls = {
    root_markers = { 'package.json', '.git' },
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
  graphql = {},
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
  rust_analyzer = {},
  sqls = {},
  tailwindcss = {},
  tinymist = {
    single_file_support = true, -- Fixes LSP attachment in non-Git directories
    settings = {
      formatterMode = 'typstyle',
      exportPdf = 'onType',
      semanticTokens = 'disable',
    },
  },
  ts_ls = {
    init_options = { documentFormatting = false, hostInfo = 'neovim' },
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
        suggest = {
          completeFunctionCalls = false, -- keep disabled for performance
        },
        diagnostics = {
          enable = false,
          reportUnusedDisableDirectives = false,
          reportDeprecated = false,
        },
        format = { enable = false },
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
          maxTsServerMemory = 8192,
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
          maxInlayHintLength = 30,
          completion = {
            enableServerSideFuzzyMatch = true,
          },
        },
      },
    },
  },
}

---@type table<string, vim.lsp.Config|{mason?:boolean, enabled?:boolean}|boolean>
local lsp_dir_servers = {
  gh_actions_ls = {},
}

-- mason-lspconfig doesn't enable these by default for some reason.. I have to enable them manually.
---@type table<string, vim.lsp.Config|{mason?:boolean, enabled?:boolean}|boolean>
local manual_servers = {
  tsgo = {},
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
  config.capabilities.textDocument.onTypeFormatting =
    { dynamicRegistration = false }
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

---@alias WhichServers 'default' | 'all' | 'manual' | 'lsp_dir'

---Get the configuration for a specific language server
---@param name string?
---@param which? WhichServers
---@return table<string, any>?
local function get(name, which)
  which = which or 'default'
  if which == 'all' then return capabilities() end
  local config = servers[name]
  if which == 'manual' then config = manual_servers[name] end
  if which == 'lsp_dir' then config = manual_servers[name] end
  if not config then return {} end
  if type(config) == 'function' then config = config() end
  return capabilities(name, config)
end

---Get the list of language servers
---@param which? WhichServers
---@return string[]
local function names(which)
  which = which or 'default'
  local lsp_servers = servers
  if which == 'manual' then lsp_servers = manual_servers end
  if which == 'lsp_dir' then lsp_servers = lsp_dir_servers end
  if which == 'all' then
    local all = vim.tbl_keys(
      vim.tbl_extend('force', servers, manual_servers, lsp_dir_servers)
    )
    table.sort(all)
    return all
  end
  return vim.tbl_keys(lsp_servers)
end

return {
  list = servers,
  capabilities = capabilities,
  get = get,
  names = names,
}
