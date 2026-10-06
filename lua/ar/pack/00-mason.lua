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
          if
            vim.tbl_contains(l, 'golangcilint') or vim.tbl_contains(l, 'clippy')
          then
            table.insert(linters, 'golangci-lint')
            local others = vim.tbl_filter(
              function(v)
                return not vim.tbl_contains({ 'golangcilint', 'clippy' }, v)
              end,
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
  if not ar.config.lsp.null_ls.enable then
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
        :filter(
          function(f)
            return not vim.tbl_contains({ '', nil, 'injected', 'rustfmt' }, f)
          end
        )
        :totable()
      formatters = ar.unique(formatters)
      vim.list_extend(packages, formatters)
    end
  end
  return packages
end

if ar.get_plugin_cond('mason.nvim') then
  vim.api.nvim_create_autocmd('PackChanged', {
    group = vim.api.nvim_create_augroup('MasonBuild', { clear = true }),
    callback = function(ev)
      local name, kind = ev.data.spec.name, ev.data.kind
      if name == 'mason.nvim' and (kind == 'install' or kind == 'update') then
        vim.cmd('MasonUpdate')
      end
    end,
  })
  vim.pack.add({
    'https://github.com/mason-org/mason.nvim',
  }, { confirm = false })
  require('mason').setup({
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
  })
  map('n', '<leader>lm', '<cmd>Mason<CR>', { desc = 'mason info' })
end

if ar.get_plugin_cond('mason-extra-cmds') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/Zeioth/mason-extra-cmds',
    }, { confirm = false })
    require('mason-extra-cmds').setup({})
    loaded = true
  end
  ar.pack.cmd('MasonUpdateAll', load)
  ar.add_to_select('command_palette', {
    ['Update All Mason Packages'] = 'MasonUpdateAll',
  })
  ar.pack.cmd('MasonUpdateAll', load)
end

if ar.get_plugin_cond('mason-tool-installer.nvim') then
  local loaded = false
  local function load()
    if loaded then return end
    vim.pack.add({
      'https://github.com/mason-tool-installer.nvim',
    }, { confirm = false })
    local opts = {
      run_on_start = false,
      ensure_installed = { 'codelldb' },
    }
    opts.ensure_installed =
      vim.list_extend(opts.ensure_installed or {}, get_all_packages())
    require('mason-tool-installer').setup(opts)
    loaded = true
  end
  ar.pack.cmd({ 'MasonToolsInstall', 'MasonToolsUpdate' }, load)
end
