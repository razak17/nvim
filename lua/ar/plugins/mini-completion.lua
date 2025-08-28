local minimal = ar.plugins.minimal

return {
  {
    'nvim-mini/mini.completion',
    cond = function()
      local condition = minimal
        or ar_config.completion.variant == 'mini.completion'
      return ar.get_plugin_cond('mini.completion', condition)
    end,
    event = { 'InsertEnter', 'BufEnter' },
    opts = {},
    config = function(_, opts)
      require('mini.completion').setup(opts)

      ar.augroup('MiniCompletionDisable', {
        event = { 'FileType' },
        desc = 'Disable completion for certain files',
        command = function()
          local ignored_filetypes = {
            'TelescopePrompt',
            'minifiles',
            'snacks_picker_input',
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.minicompletion_disable = true
          end
        end,
      })
    end,
  },
}
