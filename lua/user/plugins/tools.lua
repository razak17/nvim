local fn, ui, highlight = vim.fn, rvim.ui, rvim.highlight
local border = ui.current.border

return {
  { 'turbio/bracey.vim', ft = 'html', build = 'npm install --prefix server' },
  {
    'razak17/null-ls.nvim',
    keys = {
      {
        '<leader>ln',
        function() require('null-ls.info').show_window({ height = 0.7, border = border }) end,
        desc = 'null-ls info',
      },
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-null-ls').setup({
        automatic_setup = true,
        ensure_installed = { 'goimports', 'golangci_lint', 'stylua', 'prettierd', 'zsh', 'flake8', 'black' },
        automatic_installation = false,
        handlers = {},
      })
      require('null-ls').setup({
        debug = rvim.debug.enable,
        on_attach = function(client, bufnr)
          local lfm_ok, lsp_format_modifications = rvim.pcall(require, 'lsp-format-modifications')
          if lfm_ok and vim.tbl_contains({ 'clangd', 'vtsls', 'null-ls' }, client.name) then
            lsp_format_modifications.attach(client, bufnr, { format_on_save = false })
          end
        end,
      })
    end,
  },
  {
    'ahmedkhalf/project.nvim',
    event = 'LspAttach',
    name = 'project_nvim',
    opts = {
      detection_methods = { 'pattern', 'lsp' },
      ignore_lsp = { 'null-ls' },
      patterns = { '.git' },
    },
  },
  {
    'iamcco/markdown-preview.nvim',
    build = function() fn['mkdp#util#install']() end,
    ft = 'markdown',
    config = function()
      vim.g.mkdp_auto_start = 0
      vim.g.mkdp_auto_close = 1
    end,
  },
  {
    'razak17/lab.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    keys = {
      { '<leader>rl', ':Lab code run<CR>', desc = 'lab: run' },
      { '<leader>rx', ':Lab code stop<CR>', desc = 'lab: stop' },
      { '<leader>rp', ':Lab code panel<CR>', desc = 'lab: panel' },
    },
    build = 'cd js && npm ci',
    config = function()
      highlight.plugin('lab', {
        theme = {
          ['onedark'] = { { LabCodeRun = { link = 'DiagnosticVirtualTextInfo' } } },
        },
      })
      require('lab').setup()
    end,
  },
  {
    'razak17/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    config = function()
      highlight.plugin('package-info', {
        theme = {
          ['onedark'] = {
            { PackageInfoUpToDateVersion = { link = 'DiagnosticVirtualTextInfo' } },
            { PackageInfoOutdatedVersion = { link = 'DiagnosticVirtualTextWarn' } },
          },
        },
      })
      require('package-info').setup({
        autostart = false,
        hide_up_to_date = true,
      })
    end,
  },
  {
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = { autofocus = true, border = border },
      null_ls = { enabled = true, name = 'crates' },
    },
    config = function(_, opts)
      rvim.augroup('CmpSourceCargo', {
        event = 'BufRead',
        pattern = 'Cargo.toml',
        command = function()
          require('cmp').setup.buffer({
            sources = { { name = 'crates', priority = 3, group_index = 1 } },
          })
        end,
      })
      require('crates').setup(opts)
    end,
  },
  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    keys = {
      { '<leader>rS', '<Plug>RestNvim', desc = 'rest: run' },
      { '<leader>rP', '<Plug>RestNvimPreview', desc = 'rest: preview' },
      { '<leader>rL', '<Plug>RestNvimLast', desc = 'rest: run last' },
    },
    opts = { skip_ssl_verification = true },
  },
}
