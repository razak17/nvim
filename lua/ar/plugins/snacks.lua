local api = vim.api
local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = codicons.lsp
local separators = ar.ui.icons.separators

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = {
      -- stylua: ignore start
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
      { '<leader>qb', function() Snacks.bufdelete.delete() end, desc = 'snacks: delete buffer' },
      -- stylua: ignore end
    },
    ---@type snacks.Config
    opts = {
      styles = {
        blame_line = { border = border },
        git = { border = border },
        input = { border = 'single' },
        lazygit = { border = border },
        notification = { border = 'single' },
        notification_history = {
          border = border,
          wo = {
            winblend = ar_config.ui.transparent.enable and 0 or 5,
            wrap = true,
          },
        },
        snacks_image = { relative = 'editor', col = -1 },
      },
      animate = { enabled = false },
      bigfile = { enabled = false },
      bufdelete = { enabled = true },
      debug = { enabled = true },
      dim = { enabled = true },
      explorer = { enabled = true },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      image = {
        enabled = true,
        doc = {
          inline = false,
          float = true,
          -- max_width = 60,
          max_width = 60,
          max_height = 30,
        },
      },
      indent = {
        enabled = ar_config.ui.indentline.enable
          and ar_config.ui.indentline.variant == 'snacks',
        char = separators.left_thin_block,
      },
      input = {},
      notifier = {
        border = border,
        enabled = ar_config.notifier.enable
          and ar_config.notifier.variant == 'snacks',
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
      quickfile = { enabled = true },
      statuscolumn = { enabled = false },
      terminal = {
        enabled = true,
        win = { wo = { winbar = '' } },
      },
      words = { enabled = true },
      zen = {},
    },
    init = function()
      ar.add_to_select_menu('command_palette', {
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
      ar.add_to_select_menu('toggle', {
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
    end,
    config = function(_, opts)
      local notify = vim.notify
      require('snacks').setup(opts)
      -- https://github.com/LazyVim/LazyVim/blob/66981fe5b2c220286a31292fce3cc82b0e17ae76/lua/lazyvim/plugins/init.lua?plain=1#L24
      -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
      -- this is needed to have early notifications show up in noice history
      if ar.is_available('noice.nvim') then vim.notify = notify end
    end,
  },
}
