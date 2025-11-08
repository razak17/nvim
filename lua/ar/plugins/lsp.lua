local fn = vim.fn
local cwd = fn.getcwd()
local fmt = string.format
local border = ar.ui.current.border
local lsp_override = ar_config.lsp.override
local ar_lsp = ar_config.lsp.lang

local server_langs = {
  ts_ls = 'typescript',
  ['typescript-tools'] = 'typescript',
  tsgo = 'typescript',
  denols = 'typescript',
  vtsls = 'typescript',
  ty = 'python',
  ruff = 'python',
  pyright = 'python',
  basedpyright = 'python',
  jedi_language_server = 'python',
  pyrefly = 'python',
  tailwindcss = 'tailwind',
  ['tailwind-tools'] = 'tailwind',
  biome = 'web',
  eslint = 'web',
  emmet_ls = 'web',
  emmet_language_server = 'web',
}

local function is_enabled(name)
  local disabled = ar.lsp_disabled(name)
  if vim.tbl_contains(lsp_override, name) and not disabled then return true end
  if ar.lsp_override(name) then return false end
  if ar.lsp_disabled(name) then return false end
  if ar.dir_lsp_disabled(cwd) then return false end
  local lang = server_langs[name]
  if lang ~= nil then
    local lang_tbl = ar_lsp[lang]
    if not (lang_tbl and lang_tbl[name]) then return false end
  end
  return true
end

---@param servers string[]
local function get_enabled(servers) return vim.iter(servers):filter(is_enabled) end

local function get_servers()
  local ar_servers = require('ar.servers')
  local default = get_enabled(ar_servers.names())
  local lsp_dir = get_enabled(ar_servers.names('lsp_dir'))
  local manual = get_enabled(ar_servers.names('manual'))
  local enabled_servers = default
    :map(function(name)
      local config = ar_servers.get(name)
      if not config then return nil end -- skip if config missing
      vim.lsp.config(name, config)
      return name
    end)
    :filter(function(x) return x ~= nil end)
    :totable()
  vim.list_extend(enabled_servers, lsp_dir:totable())
  manual:each(function(name) vim.lsp.enable(name) end)
  return enabled_servers
end

return {
  {
    {
      'mason-org/mason.nvim',
      lazy = false,
      keys = { { '<leader>lm', '<cmd>Mason<CR>', desc = 'mason info' } },
      build = ':MasonUpdate',
      init = function()
        ar.add_to_select_menu('command_palette', {
          ['Update All Mason Packages'] = 'MasonUpdateAll',
        })
      end,
      -- stylua: ignore
      cmd = {
        'Mason', 'MasonInstall', 'MasonUninstall', 'MasonUninstallAll',
        'MasonLog', 'MasonUpdate'
      },
      opts = {
        ui = {
          border = border,
          height = 0.8,
          icons = {
            package_pending = ' ',
            package_installed = '󰄳 ',
            package_uninstalled = ' 󰚌',
          },
        },
        registries = {
          'lua:mason-registry.index',
          'github:mason-org/mason-registry',
          'github:nvim-java/mason-registry',
        },
        providers = { 'mason.providers.registry-api', 'mason.providers.client' },
      },
    },
    {
      'Zeioth/mason-extra-cmds',
      cmd = 'MasonUpdateAll', -- this cmd is provided by mason-extra-cmds
      opts = {},
    },
    {
      'williamboman/mason-lspconfig.nvim',
      cond = ar.lsp.enable,
      event = { 'BufReadPre' },
      config = function()
        require('mason-lspconfig').setup({ automatic_enable = get_servers() })
      end,
      dependencies = {
        {
          'neovim/nvim-lspconfig',
          cond = ar.lsp.enable,
          config = function()
            require('lspconfig.ui.windows').default_options.border = border
          end,
          dependencies = {
            {
              'folke/neoconf.nvim',
              cond = function()
                return ar.get_plugin_cond('neoconf.nvim', ar.lsp.enable)
              end,
              cmd = { 'Neoconf' },
              opts = {
                local_settings = '.nvim.json',
                global_settings = 'nvim.json',
              },
            },
          },
        },
      },
    },
    {
      'hrsh7th/nvim-cmp',
      optional = true,
      dependencies = { -- this will only be evaluated if nvim-cmp is enabled
        {
          'hrsh7th/cmp-nvim-lsp',
          cond = ar.lsp.enable,
          specs = {
            {
              'hrsh7th/nvim-cmp',
              optional = true,
              opts = function(_, opts)
                opts = vim.g.cmp_add_source(opts, {
                  source = {
                    name = 'nvim_lsp',
                    priority = 1000,
                    group_index = 1,
                  },
                  menu = { nvim_lsp = '[LSP]' },
                })
              end,
            },
          },
        },
      },
    },
  },
  { 'mfussenegger/nvim-jdtls', ft = 'java', cond = ar.lsp.enable },
  {
    'smjonas/inc-rename.nvim',
    cmd = { 'IncRename' },
    cond = ar.lsp.enable,
    opts = { hl_group = 'Visual', preview_empty_name = true },
    keys = function()
      local mappings = {}
      if ar_config.lsp.rename.variant == 'inc-rename' then
        ar.list_insert(mappings, {
          {
            '<leader>ln',
            function() return fmt(':IncRename %s', fn.expand('<cword>')) end,
            expr = true,
            silent = false,
            desc = 'lsp: incremental rename',
          },
        })
      end
      return mappings
    end,
  },
  {
    'antosha417/nvim-lsp-file-operations',
    cond = function()
      return ar.get_plugin_cond('nvim-lsp-file-operations', ar.lsp.enable)
    end,
    event = 'LspAttach',
    opts = {},
  },
}
