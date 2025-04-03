return {
  'echasnovski/mini.pick',
  cond = not ar.plugin_disabled('mini.pick')
    and ar_config.picker.variant == 'mini.pick',
  keys = function()
    local mappings = {}
    if ar_config.picker.files == 'mini.pick' then
      table.insert(
        mappings,
        { '<C-p>', '<Cmd>Pick all_files<CR>', desc = 'pick: open' }
      )
    end
    if ar_config.picker.variant == 'mini.pick' then
      local picker_mappings = {
        { '<C-p>', '<Cmd>Pick all_files<CR>', desc = 'pick: files' },
        { '<M-space>', '<Cmd>Pick buffers<CR>', desc = 'pick: buffers' },
        { '<leader>fw', '<Cmd>Pick grep<CR>', desc = 'pick: grep' },
        { '<leader>fs', '<Cmd>Pick grep_live<CR>', desc = 'pick: live grep' },
      }
      vim.iter(picker_mappings):each(function(m) table.insert(mappings, m) end)
    end
    return mappings
  end,
  event = 'VeryLazy',
  cmd = { 'Pick' },
  opts = {
    delay = { async = 10, busy = 30 },
  },
  config = function(_, opts)
    local picker = require('mini.pick')
    local registry = picker.registry

    if ar_config.picker.variant == 'mini.pick' then
      vim.ui.select = picker.ui_select
    end

    registry.all_files = function()
      picker.builtin.cli({
          -- stylua: ignore start
          command = {
            'rg',
            '--files',
            '--follow',
            '--hidden',
            '--no-ignore',
            '--glob', '!**/.git/**',
            '--glob', '!**/node_modules/**',
            '--glob', '!**/build/**',
            '--glob', '!**/tmp/**',
            '--glob', '!**/.mypy_cache/**',
          },
        -- stylua: ignore end
      }, {
        source = { name = 'All Files' },
      })
    end

    local parsed_matches = function()
      local list = {}
      local matches = picker.get_picker_matches().all

      for _, match in ipairs(matches) do
        if type(match) == 'table' then
          table.insert(list, match)
        else
          local path, lnum, col, search =
            string.match(match, '(.-)%z(%d+)%z(%d+)%z%s*(.+)')
          local text = path
            and string.format('%s [%s:%s]  %s', path, lnum, col, search)
          local filename = path or vim.trim(match):match('%s+(.+)')

          table.insert(list, {
            filename = filename or match,
            lnum = lnum or 1,
            col = col or 1,
            text = text or match,
          })
        end
      end

      return list
    end

    opts.mappings = opts.mappings or {}
    opts.mappings.send_to_qflist = {
      char = '<C-q>',
      func = function()
        vim.fn.setqflist(parsed_matches(), 'r')
        if picker.is_picker_active() then picker.stop() end
        vim.cmd('copen')
      end,
    }
    picker.setup(opts)
  end,
}
