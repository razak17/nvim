return {
  {
    'folke/lazydev.nvim',
    cond = function() return ar.get_plugin_cond('lazydev.nvim', ar.lsp.enable) end,
    event = 'BufRead ' .. vim.fn.stdpath('config') .. '**/*.lua',
    cmd = 'LazyDev',
    opts = {
      library = {
        'lazy.nvim',
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'saghen/blink.cmp',
    optional = true,
    opts = function(_, opts)
      local function get_cond()
        return ar.get_plugin_cond('lazydev.nvim', ar.lsp.enable)
      end
      if get_cond() then
        local blink_opts = vim.g.blink_add_source({ 'lazydev' }, {
          lazydev = {
            name = '[LAZYDEV]',
            module = 'lazydev.integrations.blink',
            score_offset = 100, -- show at a higher priority than lsp
          },
        }, opts)
        blink_opts.sources.per_filetype = vim.tbl_deep_extend(
          'force',
          blink_opts.sources.per_filetype or {},
          { lua = { inherit_defaults = true, 'lazydev' } }
        )
        return blink_opts
      end
      return opts
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    optional = true,
    opts = function(_, opts)
      vim.g.cmp_add_source(opts, {
        source = { name = 'lazydev', group_index = 0 },
        menu = { ['lazydev'] = '[LAZYDEV]' },
      })
    end,
  },
}
