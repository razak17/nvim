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
  sqls = {
    -- TODO: overwriting global on_attach
    on_attach = function(client, bufnr) require('sqls').on_attach(client, bufnr) end,
  },
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

rvim.servers = servers

return function(name)
  local config = servers[name]
  if not config then return end
  local t = type(config)
  if t == 'boolean' then config = {} end
  if t == 'function' then config = config() end
  local defaults = rvim.lsp.get_global_opts()
  if not config then return defaults end
  defaults = vim.tbl_deep_extend('force', defaults, config)
  return defaults
end
