----------------------------------------------------------------------------------------------------
-- Language servers
----------------------------------------------------------------------------------------------------
local fn, fmt = vim.fn, string.format

local M = {}

local function global_capabilities()
  local ok, cmp_nvim_lsp = rvim.safe_require('cmp_nvim_lsp')
  if ok then cmp_nvim_lsp.default_capabilities() end
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.colorProvider = { dynamicRegistration = true }
  capabilities.textDocument.completion.completionItem.documentationFormat =
    { 'markdown', 'plaintext' }
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
  return capabilities
end

-- This function allows reading a per project "settings.json" file in the `.vim` directory of the project.
---@param client table<string, any>
---@return boolean
local function on_init(client)
  local settings = client.workspace_folders[1].name .. '/.vim/settings.json'

  if fn.filereadable(settings) == 0 then return true end
  local ok, json = pcall(fn.readfile, settings)
  if not ok then return true end

  local overrides = vim.json.decode(table.concat(json, '\n'))

  for name, config in pairs(overrides) do
    if name == client.name then
      client.config = vim.tbl_deep_extend('force', client.config, config)
      client.notify('workspace/didChangeConfiguration')

      vim.schedule(function()
        local path = fn.fnamemodify(settings, ':~:.')
        local msg = fmt('loaded local settings for %s from %s', client.name, path)
        vim.notify_once(msg, 'info', { title = 'LSP Settings' })
      end)
    end
  end
  return true
end

M.servers = {
  astro = true,
  bashls = true,
  clangd = true,
  clojure_lsp = true,
  cmake = true,
  cssls = true,
  dockerls = true,
  html = true,
  marksman = false,
  prismals = true,
  -- quick_lint_js = true,
  sqls = true,
  svelte = true,
  tsserver = true,
  vimls = true,
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
    filetypes = {
      'html',
      'css',
    },
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
  sumneko_lua = function()
    local path = vim.split(package.path, ';')
    table.insert(path, 'lua/?.lua')
    table.insert(path, 'lua/?/init.lua')

    local plugins = ('%s/site/pack/packer'):format(rvim.get_runtime_dir())
    local emmy = ('%s/start/emmylua-nvim'):format(plugins)
    local plenary = ('%s/start/plenary.nvim'):format(plugins)
    local packer = ('%s/opt/packer.nvim'):format(plugins)

    local library = { fn.expand('$VIMRUNTIME/lua') }

    if rvim.plugin_installed('emmylua-nvim') then
      library = { fn.expand('$VIMRUNTIME/lua'), emmy, packer, plenary }
    end

    return {
      settings = {
        Lua = {
          runtime = { path = path, version = 'LuaJIT' },
          hint = { enable = true, arrayIndex = 'Disable', setType = true },
          format = { enable = false },
          diagnostics = {
            globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'packer_plugins' },
          },
          workspace = {
            library = library,
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

function M.setup(name)
  local config = M.servers[name]
  if not config then return end
  local t = type(config)
  if t == 'boolean' then config = {} end
  if t == 'function' then config = config() end
  config.on_init = on_init
  config.capabilities = global_capabilities()
  return config
end

return M
