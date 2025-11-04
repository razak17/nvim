local api, fn, uv = vim.api, vim.fn, vim.uv
local border = ar.ui.current.border
local minimal = ar.plugins.minimal
local is_biome = ar_config.lsp.lang.web.biome
  or vim.tbl_contains(ar_config.lsp.override, 'biome')

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
  return linters
end

---@alias ConformCtx {buf: number, filename: string, dirname: string}

local prettier_ft = ar.lsp.prettier.supported
local sql_ft = { 'sql', 'mysql', 'plsql', 'psql', 'pgsql' }

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
local function has_config(ctx)
  vim.system({ 'prettier', '--find-config-path', ctx.filename }):wait()
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
---@param ctx ConformCtx
local function has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- default filetypes are always supported
  if vim.tbl_contains(prettier_ft, ft) then return true end
  -- otherwise, check if a parser can be inferred
  local ret =
    vim.system({ 'prettier', '--file-info', ctx.filename }):wait().stdout
  ---@type boolean, string?
  local ok, parser = pcall(
    function() return fn.json_decode(ret).inferredParser end
  )
  return ok and parser and parser ~= vim.NIL
end

has_config = ar.memoize(has_config)
has_parser = ar.memoize(has_parser)

return {
  {
    'nvimtools/none-ls.nvim',
    cond = function()
      local condition = not minimal and ar_config.lsp.null_ls.enable
      return ar.get_plugin_cond('none-ls.nvim', condition)
    end,
    event = { 'VeryLazy' },
    keys = function()
      local mappings = {
        {
          '<leader>ln',
          function()
            require('null-ls.info').show_window({
              height = 0.7,
              border = border,
            })
          end,
          desc = 'null-ls info',
        },
      }
      if not ar.lsp.enable then
        table.insert(mappings, {
          '<leader>lf',
          function() vim.lsp.buf.format() end,
          desc = 'null_ls: format',
        })
      end
      return mappings
    end,
    opts = {
      debug = true,
      sources = {},
    },
    config = function(_, opts)
      -- https://github.com/teto/home/blob/c317bf0e5fce5bf0b79b71c08cb886091cd01741/config/nvim/lua/plugins/none-ls.lua#L19
      local none_ls = require('null-ls')
      vim.list_extend(opts.sources or {}, {
        require('none-ls-shellcheck.diagnostics'),
        require('none-ls-shellcheck.code_actions'),
        none_ls.builtins.diagnostics.markdownlint,
        none_ls.builtins.diagnostics.yamllint,
        none_ls.builtins.diagnostics.zsh,
        none_ls.builtins.formatting.goimports,
        none_ls.builtins.formatting.goimports_reviser,
        -- none_ls.builtins.formatting.markdown_toc,
        none_ls.builtins.formatting.prettier,
        none_ls.builtins.formatting.shfmt,
        none_ls.builtins.formatting.stylua,
        none_ls.builtins.formatting.yamlfmt, -- from google
        none_ls.builtins.formatting.sqlfluff,
      })
      if ar.lsp_disabled('ruff') then
        vim.list_extend(opts.sources, {
          none_ls.builtins.diagnostics.mypy,
          none_ls.builtins.formatting.black,
          none_ls.builtins.formatting.isort,
          none_ls.builtins.diagnostics.sqlfluff,
        })
      elseif not ar.lsp.enable then
        vim.list_extend(opts.sources, {
          none_ls.builtins.formatting.black,
          none_ls.builtins.formatting.yapf,
        })
      end
      none_ls.setup(opts)
    end,
    dependencies = { 'gbprod/none-ls-shellcheck.nvim' },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cond = not minimal and ar.lsp.enable,
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate' },
    opts = function(_, opts)
      local packages = get_lsp_servers()
      if not ar_config.lsp.null_ls.enable then
        local linters = get_linters()
        vim.list_extend(packages, linters)
        local conform_ok, conform = pcall(require, 'conform')
        if conform_ok then
          local formatters = vim
            .iter(pairs(conform.list_all_formatters()))
            :map(function(_, f) return f.command end)
            :filter(
              function(f) return f ~= '' and f ~= nil and f ~= 'injected' end
            )
            :totable()
          vim.list_extend(packages, formatters)
        end
      end
      opts.run_on_start = false
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, packages)
      return opts
    end,
    config = function(_, opts) require('mason-tool-installer').setup(opts) end,
  },
  {
    'stevearc/conform.nvim',
    cond = not minimal and not ar_config.lsp.null_ls.enable,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'ConformInfo',
    keys = {
      { '<localleader>lC', '<Cmd>ConformInfo<CR>', desc = 'conform info' },
      {
        '<localleader>lF',
        function() require('conform').format({ formatters = { 'injected' } }) end,
        mode = { 'n', 'v' },
        desc = 'conform: format injected langs',
      },
    },
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    opts = {
      formatters = {
        injected = { options = { ignore_errors = true } }, -- format treesitter injected languages.
        ['markdown-toc'] = {
          condition = function(_, ctx)
            for _, line in ipairs(api.nvim_buf_get_lines(ctx.buf, 0, -1, false)) do
              if line:find('<!%-%- toc %-%->') then return true end
            end
          end,
        },
        ['markdownlint-cli2'] = {
          condition = function(_, ctx)
            local diag = vim.tbl_filter(
              function(d) return d.source == 'markdownlint' end,
              vim.diagnostic.get(ctx.buf)
            )
            return #diag > 0
          end,
        },
        prettier = {
          condition = function(_, ctx)
            return has_parser(ctx)
              and (ar.lsp.prettier.needs_config ~= true or has_config(ctx))
              and not is_biome
          end,
        },
        biome = {
          condition = function() return not is_biome end,
          require_cwd = true,
        },
        -- https://github.com/mistweaverco/kulala-fmt
        ['kulala-fmt'] = {
          command = 'kulala-fmt',
          args = { 'format', '$FILENAME' },
          stdin = false,
        },
      },
      formatters_by_ft = {
        ['markdown'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        lua = { 'stylua' },
        go = { 'goimports', 'goimports-reviser' },
        sh = { 'shfmt' },
        python = ar.lsp_disabled('ruff') and { 'isort', 'autopep8' }
          or not ar.lsp.enable and { 'black', 'yapf' }
          or {},
        http = { 'kulala-fmt' },
        typst = { 'typstyle', lsp_format = 'prefer' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = false,
      format_after_save = false,
      stop_after_first = false,
    },
    config = function(_, opts)
      vim.g.async_format_filetypes = opts.user_async_format_filetypes

      opts.formatters_by_ft = opts.formatters_by_ft or {}

      for _, ft in ipairs(prettier_ft) do
        if is_biome then
          opts.formatters_by_ft[ft] = { 'biome' }
        else
          opts.formatters_by_ft[ft] = { 'prettier' }
        end
      end

      for _, ft in ipairs(sql_ft) do
        opts.formatters_by_ft[ft] = { 'sql_formatter' }
      end

      local conform = require('conform')
      conform.setup(opts)

      local ignored_server = {
        'kulala',
        'render-markdown',
        'injected',
        'dev-tools',
      }

      ar.augroup('ConformFormat', {
        event = { 'BufEnter' },
        command = function(args)
          local clients = vim.lsp.get_clients({ bufnr = args.buf })
          local filtered_clients = vim.tbl_filter(
            function(c) return not vim.tbl_contains(ignored_server, c.name) end,
            clients
          )
          if #filtered_clients ~= 0 then return end
          local map_opts = { desc = 'conform: format', buffer = args.buf }
          map('n', '<leader>lf', conform.format, map_opts)
        end,
      })
    end,
  },
  {
    'mfussenegger/nvim-lint',
    cond = not minimal and ar.lsp.enable and not ar_config.lsp.null_ls.enable,
    -- stylua: ignore
    ft = {
      'javascript', 'javascript.jsx', 'javascriptreact', 'lua', 'python', 'rst',
      'sh', 'typescript', 'typescript.tsx', 'typescriptreact', 'vim', 'yaml', 'go'
    },
    opts = {
      linters_by_ft = {
        sh = { 'shellcheck' },
        vim = { 'vint' },
        yaml = { 'yamllint' },
        go = { 'golangcilint' },
        python = ar.lsp_disabled('ruff') and { 'mypy' } or {},
      },
      linters = {},
    },
    config = function(_, opts)
      local lint = require('lint')
      for _, ft in ipairs(sql_ft) do
        opts.linters_by_ft[ft] = { 'sqruff' }
      end
      lint.linters_by_ft = opts.linters_by_ft
      for k, v in pairs(opts.linters) do
        lint.linters[k] = v
      end
      local timer = assert(uv.new_timer())
      local DEBOUNCE_MS = 500
      local aug = api.nvim_create_augroup('Lint', { clear = true })
      api.nvim_create_autocmd(
        { 'BufWritePost', 'TextChanged', 'InsertLeave' },
        {
          group = aug,
          callback = function()
            local bufnr = api.nvim_get_current_buf()
            timer:stop()
            timer:start(
              DEBOUNCE_MS,
              0,
              vim.schedule_wrap(function()
                if api.nvim_buf_is_valid(bufnr) then
                  api.nvim_buf_call(
                    bufnr,
                    function() lint.try_lint(nil, { ignore_errors = true }) end
                  )
                end
              end)
            )
          end,
        }
      )
      lint.try_lint(nil, { ignore_errors = true })
    end,
  },
}
