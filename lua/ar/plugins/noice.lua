local fn, L = vim.fn, vim.log.levels

return {
  'folke/noice.nvim',
  cond = not rvim.plugins.minimal and not rvim.plugin_disabled('noice.nvim'),
  event = 'VeryLazy',
  opts = {
    cmdline = {
      format = {
        IncRename = { title = 'Rename' },
        cmdline = { pattern = '^:', icon = '>', lang = 'vim' },
        substitute = {
          pattern = '^:%%?s/',
          icon = ' ',
          ft = 'regex',
          title = '',
        },
        input = {
          icon = ' ',
          lang = 'text',
          view = 'cmdline_popup',
          title = '',
        },
      },
    },
    messages = {
      enabled = true,
      view = 'mini', -- minimise pattern not found messages
    },
    popupmenu = { backend = 'nui' },
    lsp = {
      documentation = {
        opts = {
          border = { style = 'single' },
          position = { row = 2 },
        },
      },
      signature = {
        enabled = true,
        opts = {
          position = { row = 2 },
        },
      },
      hover = {
        enabled = true,
        silent = true,
      },
      progress = {
        enabled = true,
        throttle = 1000 / 800,
      },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
        ['vim.lsp.util.stylize_markdown'] = false,
        ['cmp.entry.get_documentation'] = true,
      },
    },
    views = {
      mini = {
        position = { row = 1, col = '100%' },
      },
      vsplit = { size = { width = 'auto' } },
      split = { win_options = { winhighlight = { Normal = 'Normal' } } },
      popup = {
        border = {
          style = 'single',
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
      },
      cmdline_popup = {
        position = { row = 5, col = '50%' },
        size = { width = 'auto', height = 'auto' },
        border = {
          style = 'single',
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
      },
      confirm = {
        border = {
          style = 'single',
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
          text = { top = '' },
        },
      },
      popupmenu = {
        relative = 'editor',
        position = { row = 9, col = '50%' },
        size = { width = 60, height = 10 },
        border = {
          style = 'single',
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
        win_options = {
          winhighlight = { Normal = 'NormalFloat', FloatBorder = 'FloatBorder' },
        },
      },
    },
    redirect = { view = 'popup', filter = { event = 'msg_show' } },
    routes = {
      {
        opts = { skip = true },
        filter = {
          any = {
            { event = 'msg_show', find = 'written' },
            { event = 'msg_show', find = '%d+ lines, %d+ bytes' },
            { event = 'msg_show', kind = 'search_count' },
            { event = 'msg_show', find = '%d+L, %d+B' },
            { event = 'msg_show', find = '^Hunk %d+ of %d' },
            { event = 'msg_show', find = '%d+ change' },
            { event = 'msg_show', find = '%d+ line' },
            { event = 'msg_show', find = '%d+ more line' },
            -- TODO: investigate the source of this LSP message and disable it happens in typescript files
            { event = 'notify', find = 'No information available' },
          },
        },
      },
      {
        view = 'vsplit',
        filter = { event = 'msg_show', min_height = 20 },
      },
      {
        view = 'notify',
        filter = {
          any = {
            { event = 'msg_show', min_height = 10 },
            { event = 'msg_show', find = 'Treesitter' },
          },
        },
        opts = { timeout = 10000 },
      },
      {
        view = 'notify',
        filter = { event = 'notify', find = 'Type%-checking' },
        opts = { replace = true, merge = true, title = 'TSC' },
        stop = true,
      },
      {
        view = 'notify',
        filter = {
          any = {
            { event = 'msg_show', find = '^E486:' },
            { event = 'notify', max_height = 1 },
          },
        },
      },
      {
        view = 'notify',
        filter = {
          any = {
            { warning = true },
            { event = 'msg_show', find = '^Warn' },
            { event = 'msg_show', find = '^W%d+:' },
            { event = 'msg_show', find = '^No hunks$' },
          },
        },
        opts = {
          title = 'Warning',
          level = L.WARN,
          merge = false,
          replace = false,
        },
      },
      {
        view = 'notify',
        opts = {
          title = 'Error',
          level = L.ERROR,
          merge = true,
          replace = false,
        },
        filter = {
          any = {
            { error = true },
            { event = 'msg_show', find = '^Error' },
            { event = 'msg_show', find = '^E%d+:' },
          },
        },
      },
      {
        view = 'notify',
        opts = { title = '' },
        filter = { kind = { 'emsg', 'echo', 'echomsg' } },
      },
    },
    commands = {
      history = { view = 'vsplit' },
    },
    presets = {
      inc_rename = true,
      long_message_to_split = true,
      lsp_doc_border = true,
    },
  },
  config = function(_, opts)
    require('noice').setup(opts)

    map({ 'n', 'i', 's' }, '<c-f>', function()
      if not require('noice.lsp').scroll(4) then return '<c-f>' end
    end, { silent = true, expr = true })

    map({ 'n', 'i', 's' }, '<c-b>', function()
      if not require('noice.lsp').scroll(-4) then return '<c-b>' end
    end, { silent = true, expr = true })

    map(
      'c',
      '<M-CR>',
      function() require('noice').redirect(fn.getcmdline()) end,
      { desc = 'redirect Cmdline' }
    )
  end,
}
