local fn, L = vim.fn, vim.log.levels

local is_cmp = ar.config.completion.variant == 'cmp'

return {
  'folke/noice.nvim',
  cond = function()
    local condition = ar.config.ui.cmdline.variant == 'noice'
    return ar.get_plugin_cond('noice.nvim', condition)
  end,
  event = 'VeryLazy',
  -- lazy = false,
  init = function()
    vim.g.whichkey_add_spec({ '<leader><leader>n', group = 'Noice' })
  end,
  -- stylua: ignore
  keys = function(_, keys)
    keys = keys or {}
    ar.list_insert(keys, {
      { mode = 'c', '<S-Enter>', function() require('noice').redirect(fn.getcmdline()) end, desc = 'Redirect Cmdline' },
      { '<leader><leader>nl', function() require('noice').cmd('last') end, desc = 'noice last message' },
      { '<leader><leader>na', function() require('noice').cmd('all') end, desc = 'noice all' },
      { '<leader><leader>nd', function() require('noice').cmd('dismiss') end, desc = 'dismiss all' },
      { mode = {'i', 'n', 's'}, '<c-f>', function() if not require('noice.lsp').scroll(4) then return '<c-f>' end end, silent = true, expr = true, desc = 'scroll forward' },
      { mode = {'i', 'n', 's'}, '<c-b>', function() if not require('noice.lsp').scroll(-4) then return '<c-b>' end end, silent = true, expr = true, desc = 'scroll backward' },
    })
    if ar.config.notifier.variant == 'noice' then
      ar.list_insert(keys, {
        { '<leader>nh', function() require('noice').cmd('history') end, desc = 'noice history' },
      })
    end
  end,
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
      opts = {
        win_options = { concealcursor = '', conceallevel = 0 },
      },
    },
    messages = {
      enabled = true,
      view = 'mini', -- minimise pattern not found messages
    },
    popupmenu = {
      enabled = ar.config.completion.variant ~= 'mini.completion',
      backend = 'nui',
    },
    notify = {
      enabled = ar.config.notifier.variant == 'noice',
      view = 'notify',
    },
    lsp = {
      documentation = {
        enabled = is_cmp,
        opts = {
          border = { style = vim.o.winborder },
          position = { row = 2 },
        },
      },
      signature = {
        enabled = true,
        opts = {
          position = { row = 2 },
        },
      },
      hover = { enabled = true, silent = true },
      progress = {
        enabled = ar.config.lsp.progress.enable
          and ar.config.lsp.progress.variant == 'noice'
          and false,
        throttle = 1000 / 1000,
      },
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
        ['vim.lsp.util.stylize_markdown'] = false,
        ['cmp.entry.get_documentation'] = is_cmp,
      },
    },
    views = {
      mini = {
        position = { row = 1, col = '100%' },
        win_options = { winblend = 0 },
      },
      vsplit = {
        size = { width = 'auto' },
        win_options = { winblend = 0 },
      },
      split = {
        win_options = {
          winblend = 0,
          winhighlight = { Normal = 'Normal' },
        },
      },
      popup = {
        border = {
          style = vim.o.winborder,
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
        win_options = { winblend = 0 },
      },
      cmdline_popup = {
        position = { row = 5, col = '50%' },
        size = { width = 'auto', height = 'auto' },
        border = {
          style = vim.o.winborder,
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
        win_options = { winblend = 0 },
      },
      confirm = {
        position = { row = 20 },
        border = {
          style = vim.o.winborder,
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
          text = { top = '' },
        },
        win_options = { winblend = 0 },
      },
      popupmenu = {
        relative = 'editor',
        position = { row = 9, col = '50%' },
        size = { width = 60, height = 10 },
        border = {
          style = vim.o.winborder,
          padding = {
            top = 0,
            bottom = 0,
            left = 1,
            right = 1,
          },
        },
        win_options = {
          winblend = 0,
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
        view = 'mini',
        opts = { title = '', skip = true },
        filter = { kind = { 'echo', 'echomsg' } },
      },
      {
        view = 'notify',
        opts = { title = '' },
        filter = { kind = { 'emsg' } },
      },
      {
        filter = {
          event = 'msg_show',
          any = {
            { find = '%d+L, %d+B' },
            { find = '; after #%d+' },
            { find = '; before #%d+' },
          },
        },
        view = 'mini',
      },
      -- ts-node-action spams a lot
      {
        filter = {
          event = 'notify',
          kind = 'info',
          any = {
            { find = 'No node found at cursor' },
          },
        },
        opts = { skip = true },
      },
      {
        filter = {
          event = 'lsp',
          kind = 'progress',
          cond = function(message)
            local client = vim.tbl_get(message.opts, 'progress', 'client')
            -- skip validation messages from jdtls
            if client == 'jdtls' then
              local content = vim.tbl_get(message.opts, 'progress', 'message')
              return content == 'Validate documents'
            end
            -- skip diagnosing messages from lua_ls
            if client == 'lua_ls' then
              local content = vim.tbl_get(message.opts, 'progress', 'message')
              if content == nil then return false end
              local is_processing = string.match(content, '^lua/(.-)%.lua$')
                ~= nil
              if content ~= nil and not is_processing then
                return content ~= nil and not is_processing
              else
                -- print('content=' .. vim.inspect(content))
                return true
              end
            end

            return false
          end,
        },
        opts = { skip = true },
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
    -- https://github.com/LazyVim/LazyVim/blob/eb8ddea8c9438c34e71db097eb77a44185dd1093/lua/lazyvim/plugins/ui.lua?plain=1#L233
    -- HACK: noice shows messages from before it was enabled,
    -- but this is not ideal when Lazy is installing plugins,
    -- so clear the messages in this case.
    if vim.o.filetype == 'lazy' then vim.cmd([[messages clear]]) end

    local bg = vim.api.nvim_get_option_value('background', { scope = 'global' })
    local variant = ar.config.colorscheme.variant

    -- stylua: ignore
    local overrides = {
      { NoiceMini = { link = 'Type' } },
      { NoicePopupBorder = { link = 'FloatTitle' } },
      { NoiceCmdlinePopupTitleInput = { link = 'FloatTitle' } },
      { NoiceCmdlinePopupTitleCmdline = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupBorderCalculator = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleHelp = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleFilter = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleSearch = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleIncRename = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleSubstitute = { link = 'NoiceCmdlinePopupTitleInput' } },
      { NoiceCmdlinePopupTitleCalculator = { link = 'NoiceCmdlinePopupTitleInput' } },
    }

    if variant == 'fill' then
      ar.list_insert(overrides, {
        {
          NoicePopupBaseGroup = {
            bg = { from = 'Normal', alter = bg == 'dark' and 0.45 or -0.1 },
            fg = { from = 'Normal', attr = 'bg' },
          },
        },
      })
    end

    if variant == 'outline' then
      ar.list_insert(overrides, {
        { NoicePopupBaseGroup = { link = 'FloatBorder' } },
      })
    end

    -- stylua: ignore
    ar.list_insert(overrides, {
      { NoicePopupWarnBaseGroup = { link = 'NoicePopupBaseGroup' } },
      { NoicePopupInfoBaseGroup = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopup = { inherit = 'NoicePopupBaseGroup', fg = { from = 'Normal' } } },
      { NoiceCmdlinePopupBorder = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupTitle = { link = 'FloatTitle' } },
      { NoiceCmdlinePopupBorderCmdline = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderSearch = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderFilter = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderHelp = { link = 'NoicePopupInfoBaseGroup' } },
      { NoiceCmdlinePopupBorderSubstitute = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderIncRename = { link = 'NoicePopupWarnBaseGroup' } },
      { NoiceCmdlinePopupBorderInput = { link = 'NoicePopupBaseGroup' } },
      { NoiceCmdlinePopupBorderLua = { link = 'NoicePopupBaseGroup' } },
    })

    ar.highlight.plugin('noice', overrides)

    require('noice').setup(opts)

    map(
      'c',
      '<M-CR>',
      function() require('noice').redirect(fn.getcmdline()) end,
      { desc = 'redirect cmdline' }
    )
  end,
  dependencies = { 'MunifTanjim/nui.nvim' },
}
