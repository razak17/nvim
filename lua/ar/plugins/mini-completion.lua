local minimal = ar.plugins.minimal
local coding = ar.plugins.coding
local variant = ar.config.completion.variant
local enabled = (minimal and coding) or variant == 'mini.completion'

return {
  {
    'nvim-mini/mini.completion',
    cond = function() return ar.get_plugin_cond('mini.completion', enabled) end,
    event = { 'VeryLazy' },
    opts = { source_func = 'omnifunc', auto_setup = false },
    config = function(_, opts)
      -- Customize post-processing of LSP responses for a better user experience.
      -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
      local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }
      local process_items = function(items, base)
        return MiniCompletion.default_process_items(
          items,
          base,
          process_items_opts
        )
      end

      opts.process_items = process_items

      require('mini.completion').setup(opts)

      vim.lsp.config(
        '*',
        { capabilities = MiniCompletion.get_lsp_capabilities() }
      )

      ar.augroup('MiniCompletionDisable', {
        event = { 'FileType' },
        desc = 'Disable completion for certain files',
        command = function()
          local ignored_filetypes = {
            'TelescopePrompt',
            'minifiles',
            'snacks_picker_input',
            'fff_input',
          }
          if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
            vim.b.minicompletion_disable = true
          end
        end,
      })
    end,
  },
}
