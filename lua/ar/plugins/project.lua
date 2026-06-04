local picker_variant = ar.config.picker.variant

return {
  {
    'DrKJeff16/project.nvim',
    cond = ar.get_plugin_cond('project.nvim'),
    cmd = { 'Project' },
    opts = {
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
      lsp = { ignore = { 'null-ls' } },
      history = { save_dir = vim.fn.stdpath('data') },
      fzf_lua = { enabled = picker_variant == 'fzf-lua' },
      snacks = { enabled = picker_variant == 'snacks' },
      telescope = { disable_file_picker = picker_variant ~= 'telescope' },
    },
    keys = function()
      local keys = {}
      if ar.config.picker.variant == 'snacks' then
        table.insert(keys, {
          '<leader>fp',
          function() require('project.extensions.snacks').pick() end,
          desc = 'projects',
        })
      end
      if ar.config.picker.variant == 'fzf-lua' then
        table.insert(
          keys,
          { '<leader>fp', '<Cmd>Project fzf-lua<CR>', desc = 'projects' }
        )
      end
      if ar.config.picker.variant == 'telescope' then
        table.insert(keys, {
          '<leader>fp',
          function()
            require('telescope').extensions.projects.projects(
              ar.telescope.minimal_ui()
            )
          end,
          desc = 'projects',
        })
      end
      return keys
    end,
    specs = {
      'nvim-telescope/telescope.nvim',
      optional = true,
      opts = function(_, opts)
        vim.g.telescope_add_extension({ 'projects' }, opts)
      end,
    },
  },
}
