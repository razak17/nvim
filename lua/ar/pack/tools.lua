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
    function() return vim.fn.json_decode(ret).inferredParser end
  )
  return ok and parser and parser ~= vim.NIL
end

local function ts_formatter_cond(which)
  if ar.lsp.enable and ar.lsp_enabled('web', 'biome') then return false end
  return ar.config.formatter.typescript[which]
end

has_config = ar.memoize(has_config)
has_parser = ar.memoize(has_parser)

ar.pack.add({
  {
    src = 'https://github.com/stevearc/conform.nvim',
    cond = function()
      return ar.get_plugin_cond(
        'conform.nvim',
        ar.plugins.coding and not ar.config.lsp.null_ls.enable
      )
    end,
    cmd = { 'ConformInfo' },
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { '<localleader>lC', '<Cmd>ConformInfo<CR>', desc = 'conform info' },
      {
        '<localleader>lF',
        function() require('conform').format({ formatters = { 'injected' } }) end,
        desc = 'conform: format injected langs',
      },
    },
    setup = function()
      vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

      local opts = {
        formatters = {
          injected = { options = { ignore_errors = true } }, -- format treesitter injected languages.
          ['markdown-toc'] = {
            condition = function(_, ctx)
              for _, line in
                ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false))
              do
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
                and ts_formatter_cond('prettier')
            end,
          },
          biome = {
            condition = function() return ts_formatter_cond('biome') end,
            require_cwd = true,
          },
          ['biome-check'] = {
            condition = function() return ts_formatter_cond('biome-check') end,
            require_cwd = true,
          },
          -- https://github.com/mistweaverco/kulala-fmt
          ['kulala-fmt'] = {
            command = 'kulala-fmt',
            args = { 'format', '$FILENAME' },
            stdin = false,
          },
          oxfmt = {
            condition = function() return ts_formatter_cond('oxfmt') end,
            require_cwd = false,
          },
        },
        formatters_by_ft = {
          ['markdown'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
          lua = { 'stylua' },
          go = { 'goimports', 'goimports-reviser' },
          rust = { 'rustfmt' },
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
      }

      vim.g.async_format_filetypes = opts.user_async_format_filetypes

      opts.formatters_by_ft = opts.formatters_by_ft or {}

      for _, ft in ipairs(prettier_ft) do
        if ts_formatter_cond('prettier') then
          opts.formatters_by_ft[ft] = { 'prettier' }
        elseif ts_formatter_cond('biome') then
          opts.formatters_by_ft[ft] = { 'biome' }
        elseif ts_formatter_cond('biome-check') then
          opts.formatters_by_ft[ft] = { 'biome-check' }
        elseif ts_formatter_cond('oxfmt') then
          opts.formatters_by_ft[ft] = { 'oxfmt' }
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
    src = 'https://github.com/mfussenegger/nvim-lint',
    cond = function()
      return ar.get_plugin_cond(
        'nvim-lint',
        ar.plugins.coding and ar.lsp.enable and not ar.config.lsp.null_ls.enable
      )
    end,
    -- stylua: ignore
    ft = {
      'javascript', 'javascript.jsx', 'javascriptreact', 'lua', 'python', 'rst',
      'sh', 'typescript', 'typescript.tsx', 'typescriptreact', 'vim', 'yaml', 'go',
      'rust',
    },
    setup = function()
      local opts = {
        linters_by_ft = {
          sh = { 'shellcheck' },
          vim = { 'vint' },
          yaml = { 'yamllint' },
          go = { 'golangcilint' },
          python = ar.lsp_disabled('ruff') and { 'mypy' } or {},
        },
        linters = {},
      }

      local lint = require('lint')
      for _, ft in ipairs(sql_ft) do
        opts.linters_by_ft[ft] = { 'sqruff' }
      end
      lint.linters_by_ft = opts.linters_by_ft
      for k, v in pairs(opts.linters) do
        lint.linters[k] = v
      end
      local timer = assert(vim.uv.new_timer())
      local DEBOUNCE_MS = 500
      local aug = vim.api.nvim_create_augroup('Lint', { clear = true })
      vim.api.nvim_create_autocmd(
        { 'BufWritePost', 'TextChanged', 'InsertLeave' },
        {
          group = aug,
          callback = function()
            local bufnr = vim.api.nvim_get_current_buf()
            timer:stop()
            timer:start(
              DEBOUNCE_MS,
              0,
              vim.schedule_wrap(function()
                if vim.api.nvim_buf_is_valid(bufnr) then
                  vim.api.nvim_buf_call(
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
})
