local fn = vim.fn
local cwd = fn.getcwd()
local border = ar.ui.current.border.default
local ar_lsp = ar.config.lsp.lang
local minimal = ar.plugins.minimal
local enabled = not minimal and ar.lsp.enable

local server_langs = {
  rustaceanvim = 'rust',
  rust_analyzer = 'rust',
  bacon_ls = 'rust',
  ts_ls = 'typescript',
  ['typescript-tools'] = 'typescript',
  tsc = 'typescript',
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
  oxlint = 'web',
}

local function is_enabled(name)
  local ai_cmp = ar.config.ai.completion.variant
  if name == 'copilot' and (not ar.ai.enable or ai_cmp ~= 'native') then
    return false
  end
  local disabled = ar.lsp_disabled(name)
  local override = ar.config.lsp.override
  if vim.tbl_contains(override, name) and not disabled then return true end
  if not ar.falsy(override) then return vim.tbl_contains(override, name) end
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

ar.pack.add({
  {
    src = 'https://github.com/williamboman/mason-lspconfig.nvim',
    cond = ar.get_plugin_cond('mason.nvim', ar.lsp.enable),
    lazy = false, -- Don't lazy load. Causes highlight issues on :restart
    setup = function()
      require('lspconfig.ui.windows').default_options.border = border
      require('mason-lspconfig').setup({ automatic_enable = get_servers() })
      if ar.config.completion.variant == 'cmp' then
        ar.cmp_opts = vim.g.cmp_add_source(ar.cmp_opts, {
          source = {
            name = 'nvim_lsp',
            priority = 1000,
            group_index = 1,
          },
          menu = { nvim_lsp = '[LSP]' },
        })
      end
    end,
    dependencies = {
      { src = 'https://github.com/mason-org/mason.nvim' },
      { src = 'https://github.com/neovim/nvim-lspconfig' },
    },
  },
  {
    src = 'https://github.com/antosha417/nvim-lsp-file-operations',
    cond = ar.get_plugin_cond(
      'nvim-lsp-file-operations',
      not ar.plugins.minimal and enabled
    ),
    event = { 'LspAttach' },
    setup = function() require('lsp-file-operations').setup() end,
  },
})
