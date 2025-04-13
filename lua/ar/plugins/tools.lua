local api, fn, uv = vim.api, vim.fn, vim.uv
local border = ar.ui.current.border

local function get_lsp_servers()
  local servers = require('ar.servers').list
  return vim.iter(servers):fold({}, function(acc, key)
    local server_mapping = require('mason-lspconfig.mappings.server')
    local pkg_name = server_mapping.lspconfig_to_package[key]
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

local supported = ar.lsp.prettier.supported

--- Checks if a Prettier config file exists for the given context
---@param ctx ConformCtx
local function has_config(ctx)
  fn.system({ 'prettier', '--find-config-path', ctx.filename })
  return vim.v.shell_error == 0
end

--- Checks if a parser can be inferred for the given context:
---@param ctx ConformCtx
local function has_parser(ctx)
  local ft = vim.bo[ctx.buf].filetype --[[@as string]]
  -- default filetypes are always supported
  if vim.tbl_contains(supported, ft) then return true end
  -- otherwise, check if a parser can be inferred
  local ret = fn.system({ 'prettier', '--file-info', ctx.filename })
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
    cond = ar.lsp.enable and ar_config.lsp.null_ls.enable,
    keys = {
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
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    cond = ar.lsp.enable and ar_config.lsp.null_ls.enable,
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local null_ls = require('null-ls')
      require('mason-null-ls').setup({
        automatic_setup = true,
        automatic_installation = false,
        ensure_installed = {
          'goimports',
          'golangci_lint',
          'stylua',
          'prettierd',
          'zsh',
          'flake8',
          'black',
          'autopep8',
        },
        handlers = {
          black = function()
            null_ls.register(null_ls.builtins.formatting.black.with({
              extra_args = { '--fast' },
            }))
          end,
          -- eslint_d = function()
          --   null_ls.register(
          --     null_ls.builtins.diagnostics.eslint_d.with({ filetypes = { 'svelte' } })
          --   )
          -- end,
          prettier = function() end,
          eslint_d = function() end,
          prettierd = function()
            null_ls.register(null_ls.builtins.formatting.prettierd.with({
              filetypes = {
                'javascript',
                'typescript',
                'typescriptreact',
                'json',
                'yaml',
                'markdown',
                'svelte',
              },
            }))
          end,
          shellcheck = function()
            null_ls.register(null_ls.builtins.diagnostics.shellcheck.with({
              extra_args = { '--severity', 'warning' },
            }))
          end,
        },
      })
      null_ls.setup({ debug = ar_config.debug.enable })
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cond = ar.lsp.enable,
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate' },
    config = function()
      local packages = get_lsp_servers()
      if not ar_config.lsp.null_ls.enable then
        local linters = get_linters()
        vim.list_extend(packages, linters)
        local conform_ok, conform = pcall(require, 'conform')
        if conform_ok then
          local formatters = vim
            .iter(pairs(conform.list_all_formatters()))
            :map(function(_, f) return f.name end)
            :totable()
          vim.list_extend(packages, formatters)
        end
      end

      require('mason-tool-installer').setup({
        ensure_installed = packages,
        run_on_start = false,
      })
    end,
  },
  {
    'stevearc/conform.nvim',
    cond = not ar_config.lsp.null_ls.enable,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'ConformInfo',
    keys = function()
      local mappings = {
        { '<localleader>lC', '<Cmd>ConformInfo<CR>', desc = 'conform info' },
        {
          '<localleader>lF',
          function() require('conform').format({ formatters = { 'injected' } }) end,
          mode = { 'n', 'v' },
          desc = 'conform: format injected langs',
        },
      }
      if not ar.lsp.enable then
        table.insert(mappings, {
          '<leader>lf',
          function() require('conform').format() end,
          desc = 'conform: format',
        })
      end
      return mappings
    end,
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    opts = {
      formatters = {
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
          end,
        },
        -- https://github.com/mistweaverco/kulala-fmt
        kulala = {
          command = 'kulala-fmt',
          args = { '$FILENAME' },
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
        http = { 'kulala' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = false,
      format_after_save = false,
      stop_after_first = false,
    },
    config = function(_, opts)
      vim.g.async_format_filetypes = opts.user_async_format_filetypes

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs(supported) do
        opts.formatters_by_ft[ft] = { 'prettier' }
      end
      require('conform').setup(opts)
    end,
  },
  {
    'mfussenegger/nvim-lint',
    cond = ar.lsp.enable and not ar_config.lsp.null_ls.enable,
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
