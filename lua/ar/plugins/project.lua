return {
  {
    'Rics-Dev/project-explorer.nvim',
    cond = not ar.plugins.minimal and ar_config.picker.variant == 'telescope',
    -- stylua: ignore
    keys = {
      { '<leader>fF', '<Cmd>ProjectExplorer<CR>', desc = 'project-explorer: open' },
    },
    opts = {
      paths = { vim.g.dotfiles, vim.g.projects_dir },
      newProjectPath = vim.g.projects_dir,
      file_explorer = function(dir)
        vim.cmd('Neotree close')
        vim.cmd('Neotree ' .. dir)
      end,
    },
    config = function(_, opts) require('project_explorer').setup(opts) end,
    dependencies = { 'nvim-telescope/telescope.nvim' },
  },
}
