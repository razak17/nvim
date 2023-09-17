local uv = vim.uv
local prettier = { 'prettierd', 'prettier' }

return {
  {
    'stevearc/conform.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    cmd = 'ConformInfo',
    keys = {
      { '<localleader>lc', '<Cmd>ConformInfo<CR>', desc = 'conform info' },
    },
    opts = {
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
        markdown = { prettier },
        graphql = { prettier },
        lua = { 'stylua' },
        go = { 'goimports', 'gofmt' },
        sh = { 'shfmt' },
        python = { 'isort', 'black', 'yapf' },
      },
      log_level = vim.log.levels.DEBUG,
      format_on_save = function(bufnr)
        local async_format =
          vim.g.async_format_filetypes[vim.bo[bufnr].filetype]
        if
          async_format
          or vim.g.formatting_disabled
          or vim.b[bufnr].formatting_disabled
          or not rvim.lsp.format_on_save.enable
        then
          return
        end
        return { timeout_ms = 500, lsp_fallback = true }
      end,
      format_after_save = function(bufnr)
        local async_format =
          vim.g.async_format_filetypes[vim.bo[bufnr].filetype]
        if
          not async_format
          or vim.g.disable_autoformat
          or vim.b[bufnr].disable_autoformat
        then
          return
        end
        return { lsp_fallback = true }
      end,
      user_async_format_filetypes = {
        python = true,
      },
    },
    config = function(_, opts)
      if vim.g.started_by_firenvim then
        opts.format_on_save = false
        opts.format_after_save = false
      end
      vim.g.async_format_filetypes = opts.user_async_format_filetypes
      require('conform').setup(opts)
    end,
  },
  {
    'mfussenegger/nvim-lint',
    ft = {
      'javascript',
      'javascript.jsx',
      'javascriptreact',
      'lua',
      'python',
      'rst',
      'sh',
      'typescript',
      'typescript.tsx',
      'typescriptreact',
      'vim',
      'yaml',
    },
    opts = {
      linters_by_ft = {
        -- javascript = { 'eslint_d' },
        -- ['javascript.jsx'] = { 'eslint_d' },
        -- javascriptreact = { 'eslint_d' },
        -- typescript = { 'eslint_d' },
        -- ['typescript.tsx'] = { 'eslint_d' },
        -- typescriptreact = { 'eslint_d' },
        lua = { 'luacheck' },
        python = { 'flake8' },
        rst = { 'rstlint' },
        sh = { 'shellcheck' },
        vim = { 'vint' },
        yaml = { 'yamllint' },
        go = { 'golangci_lint' },
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
