-----------------------------------------------------------------------------//
-- Language servers
-----------------------------------------------------------------------------//
local fn = vim.fn

local function setup_capabilities()
  local snippet = {
    properties = { 'documentation', 'detail', 'additionalTextEdits' },
  }
  local code_action = {
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
  local folding_range = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
  }
  local documentation = { 'markdown', 'plaintext' }
  return snippet, code_action, folding_range, documentation
end

local function global_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local snippet, code_action, folding_range, documentation = setup_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.preselectSupport = true
  capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
  capabilities.textDocument.completion.completionItem.labelDetailsSupport = true
  capabilities.textDocument.completion.completionItem.deprecatedSupport = true
  capabilities.textDocument.completion.completionItem.commitCharactersSupport = true
  capabilities.textDocument.completion.completionItem.tagSupport = { valueSet = { 1 } }
  capabilities.textDocument.completion.completionItem.documentationFormat = documentation
  capabilities.textDocument.completion.completionItem.resolveSupport = snippet
  capabilities.textDocument.codeAction = code_action
  capabilities.textDocument.foldingRange = folding_range
  local ok, cmp_nvim_lsp = rvim.safe_require('cmp_nvim_lsp')
  if ok then cmp_nvim_lsp.update_capabilities(capabilities) end
  return capabilities
end

-- This function allows reading a per project "settings.json" file in the `.vim` directory of the project.
---@param client table<string, any>
---@return boolean
local function on_init(client)
  local path = client.workspace_folders[1].name
  local config_path = path .. '/.vim/settings.json'
  if fn.filereadable(config_path) == 0 then return true end
  local ok, json = pcall(fn.readfile, config_path)
  if not ok then return true end
  local overrides = vim.json.decode(table.concat(json, '\n'))
  for name, config in pairs(overrides) do
    if name == client.name then
      local original = client.config
      client.config = vim.tbl_deep_extend('force', original, config)
      client.notify('workspace/didChangeConfiguration')
    end
  end
  return true
end

local servers = {
  astro = true,
  bashls = true,
  clangd = true,
  clojure_lsp = true,
  cmake = true,
  cssls = true,
  dockerls = true,
  html = true,
  marksman = true,
  prismals = true,
  pyright = true,
  quick_lint_js = true,
  rust_analyzer = true,
  svelte = true,
  tsserver = true,
  vimls = true,
  denols = {
    root_dir = require('lspconfig').util.root_pattern('deno.json', 'deno.jsonc'),
    single_file_support = false,
  },
  emmet_ls = {
    filetypes = {
      'html',
      'css',
      'typescriptreact',
      'typescript.tsx',
      'javascriptreact',
      'javascript.jsx',
    },
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
    root_dir = require('lspconfig').util.root_pattern(
      '.graphqlrc*',
      '.graphql.config.*',
      'graphql.config.*'
    ),
    single_file_support = false,
  },
  jsonls = {
    settings = {
      json = {
        validate = { enable = true },
        schemas = vim.tbl_deep_extend(
          'force',
          require('schemastore').json.schemas(),
          require('nlspsettings.loaders.json').get_default_schemas()
        ),
      },
    },
    setup = {
      commands = {
        Format = {
          function() vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 }) end,
        },
      },
    },
  },
  sqls = true,
  sumneko_lua = {
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
        },
        format = { enable = false },
        diagnostics = {
          globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'packer_plugins' },
        },
        workspace = {
          library = {
            [join_paths(rvim.get_config_dir(), 'lua')] = true,
            [join_paths(rvim.get_runtime_dir(), 'site/pack/packer/start/emmylua-nvim')] = true,
          },
          telemetry = {
            enable = false,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  },
  tailwindcss = {
    root_dir = require('lspconfig').util.root_pattern(
      'tailwind.config.js',
      'tailwind.config.ts',
      'postcss.config.js',
      'postcss.config.ts'
    ),
    single_file_support = false,
  },
  vuels = {
    setup = {
      root_dir = function(fname)
        local util = require('rvim.lspconfig/util')
        return util.root_pattern('package.json')(fname)
          or util.root_pattern('vue.config.js')(fname)
          or vim.fn.getcwd()
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

return function(name)
  local config = servers[name]
  if not config then return end
  local t = type(config)
  if t == 'boolean' then config = {} end
  if t == 'function' then config = config() end
  config.on_init = on_init
  config.capabilities = global_capabilities()
  return config
end
