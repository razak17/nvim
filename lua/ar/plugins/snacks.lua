local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = ar.ui.codicons.lsp

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    -- stylua: ignore
    keys = {
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
    },
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
        enabled = ar.notifier == 'snacks',
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
        ['Toggle Zen'] = function() Snacks.zen.zen() end,
        ['Toggle Scratch'] = function() Snacks.scratch() end,
        ['Toggle Scratch Buffer'] = function() Snacks.scratch.select() end,
      })
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
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
    config = function(_, opts) Snacks.setup(opts) end,
  },
}
