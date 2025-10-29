return {
  {
    'nvim-mini/mini.surround',
    keys = function(_, keys)
      -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/coding/mini-surround.lua#L9
      local opts = ar.opts('mini.surround')
      local mappings = {
        { opts.mappings.add, desc = 'Add Surrounding', mode = { 'n', 'v' } },
        { opts.mappings.delete, desc = 'Delete Surrounding' },
        { opts.mappings.find, desc = 'Find Right Surrounding' },
        { opts.mappings.find_left, desc = 'Find Left Surrounding' },
        { opts.mappings.highlight, desc = 'Highlight Surrounding' },
        { opts.mappings.replace, desc = 'Replace Surrounding' },
        {
          opts.mappings.update_n_lines,
          desc = 'Update `MiniSurround.config.n_lines`',
        },
      }
      mappings = vim.tbl_filter(
        function(m) return m[1] and #m[1] > 0 end,
        mappings
      )
      return vim.list_extend(mappings, keys)
    end,
    opts = {
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
    },
  },
}
