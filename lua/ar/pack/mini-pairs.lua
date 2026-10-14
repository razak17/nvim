if not ar.get_plugin_cond('mini.pairs', ar.plugins.coding) then return true end

ar.pack.add({
  src = 'https://github.com/nvim-mini/mini.pairs',
  event = 'VeryLazy',
  setup = function()
    require('mini.pairs').setup({
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { 'string' },
      skip_unbalanced = true,
      markdown = true,
      mappings = {
        ['`'] = {
          action = 'closeopen',
          pair = '``',
          neigh_pattern = '[^\\`].',
          register = { cr = false },
        },
      },
    })

    local function toggle_minipairs()
      if not ar.plugin_available('mini.pairs') then return end
      vim.g.minipairs_disable = not vim.g.minipairs_disable
      if vim.g.minipairs_disable then
        vim.notify('Disabled auto pairs', 'warn', { title = 'Option' })
      else
        vim.notify('Enabled auto pairs', 'info', { title = 'Option' })
      end
    end

    ar.add_to_select(
      'command_palette',
      { ['Toggle Minipairs'] = toggle_minipairs }
    )
  end,
})
