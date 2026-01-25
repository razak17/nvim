local api = vim.api
local should_scroll = ar.config.ui.scroll.enable
  and ar.config.ui.scroll.variant == 'snacks'

return {
  {
    'folke/snacks.nvim',
    cond = function() return ar.get_plugin_cond('snacks.nvim') end,
    priority = 1000,
    lazy = false,
    keys = {
      -- stylua: ignore start
      { '<leader>or', function() Snacks.rename.rename_file() end, desc = 'snacks: rename file' },
      { '<leader>o/', function() Snacks.terminal() end, desc = 'snacks: toggle terminal' },
      { '<leader>ps', function() Snacks.profiler.scratch() end, desc = 'snacks: profiler scratch buffer' },
      { '<leader>pu', function() Snacks.profiler.toggle() end, desc = 'snacks: toggle profiler' },
      { '<leader>qb', function() Snacks.bufdelete.delete() end, desc = 'snacks: delete buffer' },
      { mode = { 'n', 'x' }, '<leader>rL', function() Snacks.debug.run() end, desc = 'snacks: run lua' },
      -- stylua: ignore end
    },
    ---@type snacks.Config
    opts = {
      styles = {
        input = { border = vim.o.winborder },
        snacks_image = { relative = 'editor', col = -1 },
      },
      animate = { enabled = false },
      bigfile = { enabled = false },
      bufdelete = { enabled = true },
      debug = { enabled = true },
      dim = { enabled = true },
      explorer = {},
      image = {
        enabled = ar.config.image.variant == 'snacks',
        doc = {
          inline = false,
          float = true,
          max_width = 60,
          max_height = 30,
        },
      },
      input = {},
      profiler = {
        pick = { picker = 'snacks' },
      },
      quickfile = { enabled = true },
      scroll = { enabled = should_scroll },
      statuscolumn = { enabled = false },
      terminal = {
        enabled = true,
        win = { wo = { winbar = '' } },
      },
      words = { enabled = ar.lsp.enable },
      zen = {},
    },
    config = function(_, opts)
      local notify = vim.notify
      require('snacks').setup(opts)

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

      ar.add_to_select_menu('command_palette', {
        ['Close Other Buffers'] = function() Snacks.bufdelete.other() end,
      })

      ar.add_to_select_menu('toggle', {
        ['Toggle Light/Dark Background'] = function()
          Snacks.toggle.option(
            'background',
            { off = 'light', on = 'dark', name = 'Dark Background' }
          )
        end,
        ['Toggle Dim'] = function()
          if Snacks.dim.enabled then
            Snacks.dim.disable()
          else
            Snacks.dim.enable({ enabled = true })
          end
        end,
        ['Toggle Relative Number'] = function()
          Snacks.toggle.option('relativenumber', { name = 'Relative Number' })
        end,
        ['Toggle Terminal'] = function() Snacks.terminal() end,
        ['Toggle Zoom'] = function() Snacks.zen.zoom() end,
        ['Toggle Zen'] = function() Snacks.zen() end,
        ['Toggle Scratch'] = function() Snacks.scratch() end,
        ['Toggle Scratch Buffer'] = function() Snacks.scratch.select() end,
      })

      if should_scroll then
        ar.add_to_select_menu('toggle', {
          ['Toggle Smooth Scrolling'] = function()
            local state = Snacks.scroll.enabled and 'disable' or 'enable'
            Snacks.scroll[state]()
          end,
        })
      end

      api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          -- Setup some globals for debugging (lazy-loaded)
          _G.dd = function(...) Snacks.debug.inspect(...) end
          _G.bt = function() Snacks.debug.backtrace() end
          vim.print = _G.dd -- Override print to use snacks for `:=` command
        end,
      })

      local function jump(options)
        return ar.jump(function(opt)
          local count = opt.forward and 1 or -1
          Snacks.words.jump(count, true)
        end, options)
      end

      map('n', ']r', jump({ forward = true }), { desc = 'next ref' })
      map('n', '[r', jump({ forward = false }), { desc = 'previous ref' })

      -- https://github.com/LazyVim/LazyVim/blob/66981fe5b2c220286a31292fce3cc82b0e17ae76/lua/lazyvim/plugins/init.lua?plain=1#L24
      -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
      -- this is needed to have early notifications show up in noice history
      if ar.has('noice.nvim') and ar.config.notifier.variant == 'noice' then
        vim.notify = notify
      end
    end,
  },
}
