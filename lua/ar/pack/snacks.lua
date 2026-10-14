if not ar.get_plugin_cond('snacks.nvim') then return end

ar.pack.add({
  src = 'https://github.com/folke/snacks.nvim',
  lazy = false,
  setup = function()
    local api = vim.api
    local should_scroll = ar.config.ui.scroll.enable
      and ar.config.ui.scroll.variant == 'snacks'

    ar.pack.snacks_opts =
      vim.tbl_deep_extend('force', ar.pack.snacks_opts or {}, {
        styles = {
          input = { border = vim.o.winborder },
          snacks_image = { relative = 'editor', col = -1 },
        },
        animate = { enabled = false },
        bigfile = { enabled = false },
        bufdelete = { enabled = true },
        debug = { enabled = true },
        dim = { enabled = true },
        explorer = {
          enabled = ar.config.explorer.variant == 'snacks',
          replace_netrw = false,
        },
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
        words = { enabled = ar.lsp.enable },
        zen = {},
      })

    local notify = vim.notify
    require('snacks').setup(ar.pack.snacks_opts)

    ar.add_to_select('command_palette', {
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

    ar.add_to_select('command_palette', {
      ['Close Other Buffers'] = function() Snacks.bufdelete.other() end,
    })

    ar.add_to_select('toggle', {
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
      ['Toggle Zoom'] = function() Snacks.zen.zoom() end,
      ['Toggle Zen'] = function() Snacks.zen() end,
      ['Toggle Scratch'] = function() Snacks.scratch() end,
      ['Toggle Scratch Buffer'] = function() Snacks.scratch.select() end,
    })

    if should_scroll then
      ar.add_to_select('toggle', {
        ['Toggle Smooth Scrolling'] = function()
          local state = Snacks.scroll.enabled and 'disable' or 'enable'
          Snacks.scroll[state]()
        end,
      })
    end

    local function setup_debug()
      vim.schedule(function()
        if vim.v.exiting ~= vim.NIL then return end
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd
      end)
    end

    if vim.v.vim_did_enter == 1 then
      setup_debug()
    else
      api.nvim_create_autocmd(
        'VimEnter',
        { once = true, callback = setup_debug }
      )
    end

    -- https://github.com/LazyVim/LazyVim/blob/66981fe5b2c220286a31292fce3cc82b0e17ae76/lua/lazyvim/plugins/init.lua?plain=1#L24
    -- HACK: restore vim.notify after snacks setup and let noice.nvim take over
    -- this is needed to have early notifications show up in noice history
    if ar.has('noice.nvim') and ar.config.notifier.variant == 'noice' then
      vim.notify = notify
    end

    local function jump(options)
      return ar.jump(function(opt)
        local count = opt.forward and 1 or -1
        Snacks.words.jump(count, true)
      end, options)
    end

    map('n', ']r', jump({ forward = true }), { desc = 'next ref' })
    map('n', '[r', jump({ forward = false }), { desc = 'previous ref' })

    -- stylua: ignore start
    map('n', '<leader>or', function() Snacks.rename.rename_file() end, { desc = 'snacks: rename file' })
    map('n', '<leader>ps', function() Snacks.profiler.scratch() end, { desc = 'snacks: profiler scratch buffer' })
    map('n', '<leader>pu', function() Snacks.profiler.toggle() end, { desc = 'snacks: toggle profiler' })
    map('n', '<leader>qb', function() Snacks.bufdelete.delete() end, { desc = 'snacks: delete buffer' })
    map('n', '<leader>qi', function() Snacks.bufdelete.invisible() end, { desc = 'snacks: delete invisible buffers' })
    map({ 'n', 'x' }, '<leader>rL', function() Snacks.debug.run() end, { desc = 'snacks: run lua' })
    -- stylua: ignore end
  end,
})
