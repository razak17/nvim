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
    dependencies = { 'nvim-lua/plenary.nvim' },
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
