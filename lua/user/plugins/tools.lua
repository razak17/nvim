local fn, ui, hl = vim.fn, rvim.ui, rvim.highlight
local border = ui.current.border

return {
  {
    'jose-elias-alvarez/null-ls.nvim',
    keys = {
      {
        '<leader>ln',
        function() require('null-ls.info').show_window({ border = border }) end,
        desc = 'null-ls: info',
      },
    },
  },
  {
    'jay-babu/mason-null-ls.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require('mason-null-ls').setup({
        automatic_setup = true,
        automatic_installation = {},
      -- stylua: ignore
        ensure_installed = {
          'goimports', 'golangci_lint', 'stylua', 'prettier', 'zsh', 'flake8', 'shellcheck', 'black',
          'shfmt',
        },
      })
      require('null-ls').setup({
        on_attach = function(client, bufnr)
          local lfm_ok, lsp_format_modifications = rvim.require('lsp-format-modifications')
          if lfm_ok and vim.tbl_contains({ 'clangd', 'tsserver', 'null-ls' }, client.name) then
            lsp_format_modifications.attach(client, bufnr, { format_on_save = false })
          end
        end,
      })
      require('mason-null-ls').setup_handlers()
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
      datapath = rvim.get_runtime_dir(),
    },
  },
  { 'turbio/bracey.vim', ft = 'html', build = 'npm install --prefix server' },
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
      hl.plugin('lab', {
        theme = {
          ['zephyr'] = {
            { LabCodeRun = { link = 'DiagnosticVirtualTextInfo' } },
          },
        },
      })
      require('lab').setup({
        runnerconf_path = join_paths(rvim.get_runtime_dir(), 'lab', 'runnerconf'),
      })
    end,
  },
  {
    'razak17/package-info.nvim',
    event = 'BufRead package.json',
    dependencies = { 'MunifTanjim/nui.nvim' },
    opts = { autostart = false, package_manager = 'yarn' },
  },
  {
    'Saecki/crates.nvim',
    event = 'BufRead Cargo.toml',
    opts = {
      popup = {
        autofocus = true,
        style = 'minimal',
        border = border,
        show_version_date = false,
        show_dependency_version = true,
        max_height = 30,
        min_width = 20,
        padding = 1,
      },
      null_ls = { enabled = true, name = 'crates.nvim' },
    },
  },
  {
    'NTBBloodbath/rest.nvim',
    ft = { 'http', 'json' },
    keys = {
      { '<localleader>rs', '<Plug>RestNvim', desc = 'rest: run' },
      { '<localleader>rp', '<Plug>RestNvimPreview', desc = 'rest: preview' },
      { '<localleader>rl', '<Plug>RestNvimLast', desc = 'rest: run last' },
    },
    opts = { skip_ssl_verification = true },
  },
}
