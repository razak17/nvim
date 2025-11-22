local border = ar.ui.current.border.default

local function get_lsp_servers()
  local servers = require('ar.servers').list
  return vim.iter(servers):fold({}, function(acc, key)
    local mason_map = require('mason-lspconfig.mappings').get_mason_map()
    local pkg_name = mason_map.lspconfig_to_package[key]
    table.insert(acc, pkg_name)
    return acc
  end)
end

local function get_linters()
  local linters = {}
  local lint_ok, lint = pcall(require, 'lint')
  if lint_ok then
    vim
      .iter(pairs(lint.linters_by_ft))
      :map(function(_, l)
        if type(l) == 'table' and not ar.falsy(l) then
          if vim.tbl_contains(l, 'golangcilint') then
            table.insert(linters, 'golangci-lint')
            local others = vim.tbl_filter(
              function(v) return v ~= 'golangcilint' end,
              l
            )
            if #others > 0 then
              table.insert(linters, table.concat(others, ','))
            end
          else
            table.insert(linters, table.concat(l, ','))
          end
        end
        if type(l) == 'string' and l ~= '' then table.insert(linters, l) end
      end)
      :totable()
  end
  linters = ar.unique(linters)
  return linters
end

local function get_all_packages()
  local packages = ar.lsp.enable and get_lsp_servers() or {}
  if not ar_config.lsp.null_ls.enable then
    local linters = get_linters()
    vim.list_extend(packages, linters)
    local conform_ok, conform = pcall(require, 'conform')
    if conform_ok then
      local formatters = vim
        .iter(pairs(conform.list_all_formatters()))
        :map(function(_, f)
          if f.name == 'prettier' then return f.name end
          return f.command
        end)
        :filter(function(f) return f ~= '' and f ~= nil and f ~= 'injected' end)
        :totable()
      formatters = ar.unique(formatters)
      vim.list_extend(packages, formatters)
    end
  end
  return packages
end

return {
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
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate' },
    opts = function(_, opts)
      opts.run_on_start = false
      opts.ensure_installed = get_all_packages()
      return opts
    end,
    config = function(_, opts) require('mason-tool-installer').setup(opts) end,
  },
}
