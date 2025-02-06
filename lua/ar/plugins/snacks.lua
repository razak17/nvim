local api, fn = vim.api, vim.fn
local fmt = string.format
local border = ar.ui.current.border
local codicons = ar.ui.codicons
local diag_icons = ar.ui.codicons.lsp

---@param opts? table
---@return function
local function p(source, opts)
  opts = opts or {}
  return function() Snacks.picker[source](opts) end
end

local function find_files()
  p('files', {
    matcher = {
      cwd_bonus = true, -- boost cwd matches
      frecency = true, -- use frecency boosting
      sort_empty = true, -- sort even when the filter is empty
    },
    finder = 'files',
    format = 'file',
    show_empty = true,
    supports_live = true,
    layout = 'telescope',
  })()
end

local function buffers()
  p('buffers', {
    on_show = function() vim.cmd.stopinsert() end,
    current = true,
    finder = 'buffers',
    format = 'buffer',
    hidden = false,
    unloaded = true,
    sort_lastused = true,
    layout = { preview = false, preset = 'select' },
    win = {
      input = {
        keys = {
          ['d'] = 'bufdelete',
        },
      },
      list = { keys = { ['d'] = 'bufdelete' } },
    },
  })()
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    keys = function()
      local mappings = {
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
        -- stylua: ignore end
      }

      if ar_config.picker.files == 'snacks' then
        table.insert(
          mappings,
          { '<C-p>', find_files, desc = 'snacks: find files' }
        )
      end
      if ar_config.picker.variant == 'snacks' then
        local picker_mappings = {
          -- stylua: ignore start
          { '<M-space>', buffers, desc = 'snacks: buffers' },
          { '<leader>fc', p('files', { cwd = vim.fn.stdpath('config') }), desc = 'find config file' },
          { '<leader>ff', p('files'), desc = 'Find Files' },
          { '<leader>fgd', p('git_diff'), desc = 'git diff (hunks)' },
          { '<leader>fgf', p('git_log_file'), desc = 'git log file' },
          { '<leader>fgg', p('git_files'), desc = 'find git files' },
          { '<leader>fgl', p('git_log'), desc = 'git log' },
          { '<leader>fgL', p('git_log_line'), desc = 'git log line' },
          { '<leader>fgs', p('git_status'), desc = 'git status' },
          { '<leader>fgS', p('git_stash'), desc = 'git stash' },
          { '<leader>fh', p('help'), desc = 'help pages' },
          { '<leader>fk', p('keymaps'), desc = 'keymaps' },
          { '<leader>fK', p('colorschemes'), desc = 'colorschemes' },
          -- { '<leader>fl', p('lazy'), desc = 'search for plugin spec' },
          { '<leader>fL', p('lines'), desc = 'buffer lines' },
          { '<leader>fm', p('man'), desc = 'man pages' },
          { '<leader>fn', p('notifications'), desc = 'notification history' },
          { '<leader>fo', p('recent'), desc = 'recent' },
          { '<leader>fp', p('projects'), desc = 'projects' },
          { '<leader>fr', p('resume'), desc = 'resume' },
          { '<leader>fs', p('grep'), desc = 'grep' },
          { '<leader>fS', p('grep_buffers'), desc = 'grep open buffers' },
          { '<leader>fql', p('loclist'), desc = 'location list' },
          { '<leader>fqq', p('qflist'), desc = 'quickfix List' },
          { '<leader>fu', p('undo'), desc = 'undo history' },
          { '<leader>fva', p('autocmds'), desc = 'autocmds' },
          { '<leader>fvc', p('commands'), desc = 'commands' },
          { '<leader>fvC', p('command_history'), desc = 'command history' },
          { '<leader>fvh', p('highlights'), desc = 'highlights' },
          { '<leader>fvi', p('icons'), desc = 'icons' },
          { '<leader>fvj', p('jumps'), desc = 'jumps' },
          { '<leader>fvm', p('marks'), desc = 'marks' },
          { '<leader>fvr', p('registers'), desc = 'registers' },
          { '<leader>fvs', p('search_history'), desc = 'search history' },
          { '<leader>fw', p('grep_word'), desc = 'visual selection or word', mode = { 'n', 'x' } },
          -- lsp
          { '<leader>le', p('diagnostics_buffer'), desc = 'snacks: buffer diagnostics' },
          { '<leader>lw', p('diagnostics'), desc = 'snacks: diagnostics' },
          { '<leader>lR', p('lsp_references'), nowait = true, desc = 'snacks: references' },
          { '<leader>lI', p('lsp_implementations'), desc = 'snacks: goto implementation' },
          { '<leader>ly', p('lsp_type_definitions'), desc = 'snacks: goto t[y]pe definition' },
          { '<leader>ld', p('lsp_symbols'), desc = 'snacks: lsp symbols' },
          { '<leader>lw', p('lsp_workspace_symbols'), desc = 'snacks: lsp workspace symbols' },
          -- explorer
          { "<leader>fe", function() Snacks.explorer() end, desc = "explorer" },
          -- stylua: ignore end
        }
        vim
          .iter(picker_mappings)
          :each(function(m) table.insert(mappings, m) end)
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
      picker = {
        prompt = fmt(' %s ', ar.ui.icons.misc.chevron_right),
        sources = {
          files = { hidden = true, ignored = true },
        },
        debug = { scores = true },
        matcher = { frecency = true },
        win = {
          input = {
            keys = {
              ['<Esc>'] = { 'close', mode = { 'n', 'i' } },
              ['<C-h>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
              ['<A-d>'] = { 'preview_scroll_down', mode = { 'i', 'n' } },
              ['<A-u>'] = { 'preview_scroll_up', mode = { 'i', 'n' } },
              ['<A-h>'] = { 'preview_scroll_left', mode = { 'i', 'n' } },
              ['<A-l>'] = { 'preview_scroll_right', mode = { 'i', 'n' } },
            },
          },
        },
      },
      profiler = {
        pick = { picker = 'telescope' },
      },
      dim = {},
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
      if
        ar_config.lsp.progress.enable
        and ar_config.lsp.progress.variant == 'snacks'
      then
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
        enabled = ar_config.dashboard.enable
          and ar_config.dashboard.variant == 'snacks',
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

      local default_layout = {
        layout = {
          box = 'horizontal',
          width = 0.8,
          min_width = 120,
          height = 0.8,
          {
            box = 'vertical',
            border = 'single',
            title = '{title} {live} {flags}',
            { win = 'input', height = 1, border = 'bottom' },
            { win = 'list', border = 'none' },
          },
          {
            win = 'preview',
            title = '{preview}',
            border = 'single',
            width = 0.6,
          },
        },
      }

      local telescope_layout = {
        reverse = false,
        layout = {
          box = 'horizontal',
          backdrop = false,
          width = 0.8,
          height = 0.9,
          border = 'none',
          {
            box = 'vertical',
            {
              win = 'list',
              title = ' Results ',
              title_pos = 'center',
              border = 'single',
            },
            {
              win = 'input',
              height = 1,
              border = 'rounded',
              title = '{title} {live} {flags}',
              title_pos = 'center',
            },
          },
          {
            win = 'preview',
            title = '{preview:Preview}',
            width = 0.6,
            border = 'single',
            title_pos = 'center',
          },
        },
      }

      opts.picker.layouts = {
        telescope = telescope_layout,
        default = default_layout,
      }

      require('snacks').setup(opts)
    end,
  },
}
