local M = { 'ahmedkhalf/project.nvim', event = 'VeryLazy' }

function M.config()
  require('project_nvim').setup({
    active = true,
    manual_mode = false,
    detection_methods = { 'pattern', 'lsp' },
    patterns = {
      '.git',
      '.hg',
      '.svn',
      'Makefile',
      'package.json',
      '.luacheckrc',
      '.stylua.toml',
    },
    show_hidden = false,
    silent_chdir = true,
    ignore_lsp = { 'null-ls' },
    datapath = rvim.get_cache_dir(),
  })

  require('telescope').load_extension('projects')
end

return M
