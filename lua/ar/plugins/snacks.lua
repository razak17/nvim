local api, fn = vim.api, vim.fn
local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = ar.ui.codicons.lsp

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    -- stylua: ignore
    keys = function ()
      local mappings = {
        { '<leader>nx', function() Snacks.notifier.hide() end, desc = 'snacks: dismiss all notifications' },
        { '<leader>nh', function() Snacks.notifier.show_history() end, desc = 'snacks: show notification history' },
        { '<leader>gbb', function() Snacks.git.blame_line() end, desc = 'snacks: git blame line' },
        { '<leader>goo', function() Snacks.gitbrowse() end, desc = 'snacks: open current line' },
        { '<leader>gh', function() Snacks.lazygit.log_file() end, desc = 'snacks: log (file)' },
        { '<leader>gH', function() Snacks.lazygit.log() end, desc = 'snacks: log (cwd)' },
        { '<leader>or', function() Snacks.rename.rename_file() end, desc = 'Rename File' },
        { '<leader>o/', function() Snacks.terminal() end, desc = 'snacks: toggle terminal' },
        { '<leader>ps', function() Snacks.profiler.scratch() end, desc = 'snacks: profiler scratch buffer' },
        { '<leader>pu', function() Snacks.profiler.toggle() end, desc = 'snacks: toggle profiler' },
      }

      if ar.picker.variant == 'snacks' then
        table.insert(mappings, { '<C-p>', function() Snacks.picker.files() end, desc = 'snacks: find files' })
        table.insert(mappings, {
          '<M-space>',
          function()
            Snacks.picker.buffers({ current = true, layout = { preview = false, preset = 'select' } })
            vim.cmd.stopinsert()
          end,
          desc = 'snacks: buffers',
        })
      end

      return mappings
    end,
    ---@type snacks.Config
    opts = {
      styles = {
        git = { border = border },
        lazygit = { border = border },
        notification = { border = 'single' },
        ['notification.history'] = { border = border },
      },
      bigfile = { enabled = false },
      bufdelete = { enabled = false },
      quickfile = { enabled = true },
      notifier = {
        border = border,
        enabled = ar.notifier.enable and ar.notifier.variant == 'snacks',
        icons = {
          error = diag_icons.error,
          warn = diag_icons.warn,
          info = diag_icons.info,
          debug = codicons.misc.bug_alt,
          trace = diag_icons.trace,
        },
        style = 'fancy',
        top_down = false,
      },
      picker = {
        prompt = codicons.misc.search_alt,
        sources = {
          files = { hidden = true, ignored = true },
        },
      },
      profiler = {
        pick = { picker = 'telescope' },
      },
      dim = {},
      statuscolumn = { enabled = false },
      words = { enabled = true },
      zen = {},
    },
    init = function()
      ar.add_to_menu('command_palette', {
        ['Neovim News'] = function()
          Snacks.win({
            file = api.nvim_get_runtime_file('doc/news.txt', false)[1],
            width = 0.6,
            height = 0.6,
            wo = {
              spell = false,
              wrap = false,
              signcolumn = 'yes',
              statuscolumn = ' ',
              conceallevel = 3,
            },
          })
        end,
      })
      ar.add_to_menu('toggle', {
        ['Toggle Light/Dark Background'] = function()
          Snacks.toggle.option(
            'background',
            { off = 'light', on = 'dark', name = 'Dark Background' }
          )
        end,
        ['Toggle Relative Number'] = function()
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' })
        end,
        ['Toggle Terminal'] = function() Snacks.terminal() end,
        ['Toggle Dim'] = function()
          if Snacks.dim.enabled then
            Snacks.dim.disable()
          else
            Snacks.dim.enable({ enabled = true })
          end
        end,
        ['Toggle Zoom'] = function() Snacks.zen.zoom() end,
        ['Toggle Zen'] = function() Snacks.zen() end,
        ['Toggle Scratch'] = function() Snacks.scratch() end,
        ['Toggle Scratch Buffer'] = function() Snacks.scratch.select() end,
      })
      api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
        end,
      })
      if ar.lsp.progress.enable and ar.lsp.progress.variant == 'snacks' then
        api.nvim_create_autocmd('LspProgress', {
          ---@param ev {data: {client_id: integer, params: lsp.ProgressParams}}
          callback = function(ev)
            local spinner = {
              '⠋',
              '⠙',
              '⠹',
              '⠸',
              '⠼',
              '⠴',
              '⠦',
              '⠧',
              '⠇',
              '⠏',
            }
            vim.notify(vim.lsp.status(), 'info', {
              id = 'lsp_progress',
              title = 'LSP Progress',
              opts = function(notif)
                notif.icon = ev.data.params.value.kind == 'end' and ' '
                  or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
              end,
            })
          end,
        })
      end
    end,
    config = function(_, opts)
      opts.dashboard = {
        enabled = ar.dashboard.enable and ar.dashboard.variant == 'snacks',
        width = 60,
        row = nil, -- dashboard position. nil for center
        col = nil, -- dashboard position. nil for center
        pane_gap = 4, -- empty columns between vertical panes
        autokeys = '1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ', -- autokey sequence
        -- These settings are used by some built-in sections
        preset = {
          -- Defaults to a picker that supports `fzf-lua`, `telescope.nvim` and `mini.pick`
          ---@type fun(cmd:string, opts:table)|nil
          pick = nil,
          -- Used by the `keys` section to show keymaps.
          -- Set your custom keymaps here.
          -- When using a function, the `items` argument are the default keymaps.
          ---@type snacks.dashboard.Item[]
          keys = {
            {
              icon = ' ',
              key = 's',
              desc = 'Restore Session',
              section = 'session',
            },
            {
              icon = '󰋇 ',
              key = 'p',
              desc = 'Pick Session',
              action = '<Cmd>ListSessions<CR>',
            },
            {
              icon = ' ',
              key = 'r',
              desc = 'Recent Files',
              action = ":lua Snacks.dashboard.pick('oldfiles')",
            },
            {
              icon = ' ',
              key = 'f',
              desc = 'Find File',
              action = ":lua Snacks.dashboard.pick('files')",
            },
            {
              icon = ' ',
              key = 'w',
              desc = 'Find Text',
              action = ":lua Snacks.dashboard.pick('live_grep')",
            },
            -- {
            --   icon = ' ',
            --   key = 'n',
            --   desc = 'New File',
            --   action = ':ene | startinsert',
            -- },
            {
              icon = ' ',
              key = 'c',
              desc = 'Config',
              action = ":lua Snacks.dashboard.pick('files', {cwd = fn.stdpath('config')})",
            },
            {
              icon = '󰒲 ',
              key = 'l',
              desc = 'Lazy',
              action = ':Lazy',
              enabled = package.loaded.lazy ~= nil,
            },
            { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
          },
          -- Used by the `header` section
          header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
        formats = {
          icon = function(item) return { item.icon, width = 2, hl = 'icon' } end,
          footer = { '%s', align = 'center' },
          header = { '%s', align = 'center' },
          file = function(item, ctx)
            local fname = fn.fnamemodify(item.file, ':~')
            fname = ctx.width and #fname > ctx.width and fn.pathshorten(fname)
              or fname
            if #fname > ctx.width then
              local dir = fn.fnamemodify(fname, ':h')
              local file = fn.fnamemodify(fname, ':t')
              if dir and file then
                file = file:sub(-(ctx.width - #dir - 2))
                fname = dir .. '/…' .. file
              end
            end
            local dir, file = fname:match('^(.*)/(.+)$')
            return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } }
              or { { fname, hl = 'file' } }
          end,
        },
        -- item field formatters,
        sections = {
          { section = 'header' },
          { section = 'keys', gap = 1, padding = 1 },
          { section = 'startup' },
        },
      }

      require('snacks').setup(opts)
    end,
  },
}
