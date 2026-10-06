if not ar.get_plugin_cond('mini.surround') then return end

vim.pack.add({
  'https://github.com/nvim-mini/mini.surround',
}, { confirm = false })
require('mini.surround').setup({
  n_lines = 50,
  mappings = {
    add = 'gsa', -- Add surrounding in Normal and Visual modes
    delete = 'gsd', -- Delete surrounding
    find = 'gsf', -- Find surrounding (to the right)
    find_left = 'gsF', -- Find surrounding (to the left)
    highlight = 'gsh', -- Highlight surrounding
    replace = 'gsr', -- Replace surrounding
    update_n_lines = 'gsn', -- Update `n_lines`
  },
  custom_surroundings = {
    -- rename tag while keeping attributes https://github.com/nvim-mini/mini.nvim/issues/1293#issuecomment-2423827325
    T = {
      input = { '<(%w+)[^<>]->.-</%1>', '^<()%w+().*</()%w+()>$' },
      output = function()
        local tag_name = MiniSurround.user_input('Tag name')
        if tag_name == nil then return nil end
        return { left = tag_name, right = tag_name }
      end,
    },
  },
})
