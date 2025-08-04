local minimal = ar.plugins.minimal

return {
  {
    'echasnovski/mini.pairs',
    cond = function() return ar.get_plugin_cond('mini.pairs', minimal) end,
    event = 'VeryLazy',
    init = function()
      local function toggle_minipairs()
        if not ar.plugin_available('mini.pairs') then return end
        vim.g.minipairs_disable = not vim.g.minipairs_disable
        if vim.g.minipairs_disable then
          vim.notify('Disabled auto pairs', 'warn', { title = 'Option' })
        else
          vim.notify('Enabled auto pairs', 'info', { title = 'Option' })
        end
      end

      ar.add_to_select_menu(
        'command_palette',
        { ['Toggle Minipairs'] = toggle_minipairs }
      )
    end,
    opts = {
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
    },
  },
}
