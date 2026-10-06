local coding = ar.plugins.coding

if not ar.get_plugin_cond('mini.pairs', coding) then return end

local function load()
  vim.schedule(function()
    if vim.v.exiting ~= vim.NIL then return end

    vim.pack.add({
      'https://github.com/nvim-mini/mini.pairs',
    }, { confirm = false })

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
  end)
end

if vim.v.vim_did_enter == 1 then
  load()
else
  vim.api.nvim_create_autocmd('UIEnter', {
    once = true,
    callback = load,
  })
end
