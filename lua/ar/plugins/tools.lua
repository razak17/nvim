local uv = vim.uv
local prettier = { 'prettierd', 'prettier' }
local border = rvim.ui.current.border

return {
  {
    'nvimtools/none-ls.nvim',
    cond = rvim.lsp.enable and rvim.lsp.null_ls.enable,
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
    cond = rvim.lsp.enable and rvim.lsp.null_ls.enable,
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
      null_ls.setup({ debug = rvim.debug.enable })
    end,
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    cond = rvim.lsp.enable,
    cmd = { 'MasonToolsInstall', 'MasonToolsUpdate' },
    config = function()
      -- Add LSP servers
      local servers = require('ar.servers').list
      local packages = vim.iter(servers):fold({}, function(acc, key)
        local server_mapping = require('mason-lspconfig.mappings.server')
        local pkg_name = server_mapping.lspconfig_to_package[key]
        table.insert(acc, pkg_name)
        return acc
      end)
      -- Add linters (from nvim-lint)
      if not rvim.lsp.null_ls.enable then
        local lint_ok, lint = pcall(require, 'lint')
        if lint_ok then
          vim
            .iter(pairs(lint.linters_by_ft))
            :map(function(_, l)
              if type(l) == 'table' then
                if vim.tbl_contains(l, 'golangcilint') then
                  table.insert(packages, 'golangci-lint')
                  local others = vim.tbl_filter(
                    function(v) return v ~= 'golangcilint' end,
                    l
                  )
                  if #others > 0 then
                    table.insert(packages, table.concat(others, ','))
                  end
                else
                  table.insert(packages, table.concat(l, ','))
                end
              end
              if type(l) == 'string' then table.insert(packages, l) end
            end)
            :totable()
        end
        -- Add formatters (from conform.nvim)
        local conform_ok, conform = pcall(require, 'conform')
        if conform_ok then
          vim
            .iter(pairs(conform.list_all_formatters()))
            :map(function(_, f) table.insert(packages, f.name) end)
            :totable()
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
    cond = rvim.lsp.enable and not rvim.lsp.null_ls.enable,
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'ConformInfo',
    keys = {
      { '<localleader>lC', '<Cmd>ConformInfo<CR>', desc = 'conform info' },
      {
        '<localleader>lF',
        function() require('conform').format({ formatters = { 'injected' } }) end,
        mode = { 'n', 'v' },
        desc = 'Format Injected Langs',
      },
    },
    init = function() vim.o.formatexpr = "v:lua.require'conform'.formatexpr()" end,
    opts = {
      formatters = {
        ['markdown-toc'] = {
          condition = function(_, ctx)
            for _, line in
              ipairs(vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false))
            do
              if line:find('<!%-%- toc %-%->') then return true end
            end
          end,
        },
      },
      formatters_by_ft = {
        javascript = { prettier },
        typescript = { prettier },
        javascriptreact = { prettier },
        typescriptreact = { prettier },
        css = { prettier },
        html = { prettier },
        json = { prettier },
        jsonc = { prettier },
        svelte = { prettier },
        yaml = { prettier },
        ['markdown'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        ['markdown.mdx'] = { 'prettier', 'markdownlint-cli2', 'markdown-toc' },
        graphql = { prettier },
        lua = { 'stylua' },
        go = { 'goimports' },
        sh = { 'shfmt' },
        python = { 'isort', 'black', 'yapf' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = false,
      format_after_save = false,
    },
    config = function(_, opts)
      vim.g.async_format_filetypes = opts.user_async_format_filetypes
      require('conform').setup(opts)
    end,
  },
  {
    'mfussenegger/nvim-lint',
    cond = rvim.lsp.enable and not rvim.lsp.null_ls.enable,
    -- stylua: ignore
    ft = {
      'javascript', 'javascript.jsx', 'javascriptreact', 'lua', 'python', 'rst',
      'sh', 'typescript', 'typescript.tsx', 'typescriptreact', 'vim', 'yaml', 'go'
    },
    opts = {
      linters_by_ft = {
        -- javascript = { 'eslint_d' },
        -- ['javascript.jsx'] = { 'eslint_d' },
        -- javascriptreact = { 'eslint_d' },
        -- typescript = { 'eslint_d' },
        -- ['typescript.tsx'] = { 'eslint_d' },
        -- typescriptreact = { 'eslint_d' },
        -- svelte = { 'eslint_d' },
        -- lua = { 'luacheck' },
        -- python = { 'flake8' },
        sh = { 'shellcheck' },
        vim = { 'vint' },
        yaml = { 'yamllint' },
        go = { 'golangcilint' },
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
}
