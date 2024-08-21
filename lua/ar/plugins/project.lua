return {
  {
    'Rics-Dev/project-explorer.nvim',
    -- stylua: ignore
    keys = {
      { '<leader>fF', '<Cmd>ProjectExplorer<CR>', desc = 'project-explorer: open' },
    },
    lazy = false,
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
