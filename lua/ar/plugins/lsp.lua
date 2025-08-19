local fn = vim.fn
local cwd = fn.getcwd()
local fmt = string.format
local border = ar.ui.current.border
local minimal = ar.plugins.minimal
local lsp_override = ar_config.lsp.override
local ar_lsp = ar_config.lsp.lang

local server_langs = {
  ts_ls = 'typescript',
  ['typescript-tools'] = 'typescript',
  tsgo = 'typescript',
  vtsls = 'typescript',
  ty = 'python',
  ruff = 'python',
  pyright = 'python',
  basedpyright = 'python',
  jedi_language_server = 'python',
  pyrefly = 'python',
  tailwindcss = 'tailwind',
  ['tailwind-tools'] = 'tailwind',
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

local function get_servers()
  local ar_servers = require('ar.servers')
  local servers = ar_servers.names()
  local enabled_servers = vim
    .iter(servers)
    :filter(is_enabled)
    :map(function(name)
      local config = ar_servers.get(name)
      if not config then return nil end -- skip if config missing
      vim.lsp.config(name, config)
      return name
    end)
    :filter(function(x) return x ~= nil end)
    :totable()
  return enabled_servers
end

return {
  {
    {
      'mason-org/mason.nvim',
      cond = function() return not minimal or ar.lsp.enable end,
      event = { 'BufReadPre', 'BufNewFile' },
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
        'MasonLog', 'MasonUpdate', 'MasonUpdateAll', -- this cmd is provided by mason-extra-cmds
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
      dependencies = { 'Zeioth/mason-extra-cmds', opts = {} },
    },
    {
      'williamboman/mason-lspconfig.nvim',
      cond = ar.lsp.enable,
      event = { 'BufReadPre' },
      config = function()
        require('mason-lspconfig').setup({ automatic_enable = get_servers() })
        local manual_servers = require('ar.servers').names({ manual = true })
        vim.iter(manual_servers):filter(is_enabled):each(function(name)
          local config = require('ar.servers').get(name, { manual = true })
          if config then
            vim.lsp.config(name, config)
            vim.lsp.enable(name)
          end
        end)
      end,
      dependencies = {
        {
          'neovim/nvim-lspconfig',
          cond = ar.lsp.enable,
          config = function()
            require('lspconfig.ui.windows').default_options.border = border
            if ar_config.lsp.semantic_tokens.enable then
              local lspconfig = require('lspconfig')
              lspconfig.util.default_config =
                vim.tbl_extend('force', lspconfig.util.default_config, {
                  on_attach = function(client)
                    client.server_capabilities.semanticTokensProvider = nil
                  end,
                })
            end
          end,
          dependencies = {
            {
              'folke/lazydev.nvim',
              cond = ar.lsp.enable and false,
              ft = 'lua',
              cmd = 'LazyDev',
              opts = {
                library = {
                  'lazy.nvim',
                  { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
                },
              },
            },
            {
              'folke/neoconf.nvim',
              cond = ar.lsp.enable and false,
              cmd = { 'Neoconf' },
              opts = {
                local_settings = '.nvim.json',
                global_settings = 'nvim.json',
              },
            },
            { 'mfussenegger/nvim-jdtls', cond = ar.lsp.enable },
          },
        },
      },
    },
  },
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
    cond = ar.lsp.enable,
    event = 'LspAttach',
    opts = {},
  },
}
