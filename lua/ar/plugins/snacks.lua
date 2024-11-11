local minimal = ar.plugins.minimal
local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = ar.ui.codicons.lsp

return {
  {
    'folke/snacks.nvim',
    cond = not minimal,
    priority = 1000,
    lazy = false,
    keys = {
      {
        '<leader>nx',
        function() require('snacks').notifier.hide() end,
        desc = 'snacks: dismiss all notifications',
      },
      {
        '<leader>nh',
        function() require('snacks').notifier.show_history() end,
        desc = 'snacks: show notification history',
      },
      {
        '<leader>gbb',
        function() require('snacks').git.blame_line() end,
        desc = 'snacks: git blame line',
      },
      {
        '<leader>goo',
        function() require('snacks').gitbrowse() end,
        desc = 'snacks: open current line',
      },
      {
        '<leader>gh',
        function() require('snacks').lazygit.log_file() end,
        desc = 'snacks: log (file)',
      },
      {
        '<leader>gH',
        function() require('snacks').lazygit.log() end,
        desc = 'snacks: log (cwd)',
      },
      {
        '<leader>or',
        function() require('snacks').rename.rename_file() end,
        desc = 'Rename File',
      },
      {
        '<leader>o/',
        function() require('snacks').terminal() end,
        desc = 'snacks: toggle terminal',
      },
    },
    opts = {
      styles = {
        git = { border = border },
        lazygit = { border = border },
        notification = { border = 'single' },
        ['notification.history'] = { border = border },
      },
      bufdelete = { enabled = false },
      notifier = {
        enabled = true,
        timeout = 3000,
        top_down = false,
        margin = { top = 0, right = 1, bottom = 1 },
        icons = {
          error = diag_icons.error,
          warn = diag_icons.warn,
          info = diag_icons.info,
          debug = codicons.misc.bug_alt,
          trace = diag_icons.trace,
        },
      },
      statuscolumn = { enabled = false },
      quickfile = { enabled = false },
      words = { enabled = false },
    },
    init = function()
      local snacks = require('snacks')
      ar.add_to_menu('command_palette', {
        ['Neovim News'] = function()
          snacks.win({
            file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
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
          snacks.toggle.option(
            'background',
            { off = 'light', on = 'dark', name = 'Dark Background' }
          )
        end,
        ['Toggle Relative Number'] = function()
          snacks.toggle.option('relativenumber', { name = 'Relative Number' })
        end,
        ['Toggle Terminal'] = function() snacks.terminal() end,
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) snacks.debug.inspect(...) end
          _G.bt = function() snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
        end,
      })
      if ar.lsp.progress.enable and ar.lsp.progress.variant == 'snacks' then
        vim.api.nvim_create_autocmd('LspProgress', {
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
  },
}
