local icons, codicons = ar.ui.icons, ar.ui.codicons
local copy = ar.copy_to_clipboard
local highlight, lsp_hls = ar.highlight, ar.ui.lsp.highlights
local api, fn = vim.api, vim.fn
local utils = require('ar.utils.fs')
local ar_icons = ar_config.icons.variant

---@param from string
---@param to string
local function on_rename(from, to)
  if ar_config.explorer.rename == 'local' then
    utils.on_rename_file(from, to)
  end
  if ar_config.explorer.rename == 'snacks' then
    local snacks_ok, snacks = pcall(require, 'snacks')
    if not snacks_ok then return end
    snacks.rename.on_rename_file(from, to)
  end
end

return {
  {
    'A7Lavinraj/fyler.nvim',
    cond = function() return ar_config.explorer.variant == 'fyler' end,
    branch = 'stable',
    cmd = { 'Fyler' },
    keys = {
      { '<c-n>', '<cmd>Fyler kind=split:rightmost<CR>', desc = 'toggle tree' },
    },
    opts = {
      icon_provider = ar_icons == 'mini.icons' and 'mini-icons'
        or 'nvim-web-devicons',
      hooks = {
        on_rename = function(src_path, dst_path) on_rename(src_path, dst_path) end,
      },
      views = {
        explorer = {
          confirm_simple = true,
          default_explorer = true,
          git_status = false,
          win = {
            win_opts = {
              number = false,
              relativenumber = false,
              cursorline = true,
            },
          },
          width = 0.2,
          height = 0.8,
          kind = 'float',
          border = 'single',
        },
      },
    },
    config = function(_, opts)
      require('fyler').setup(opts)

      ar.augroup('FylerEnter', {
        event = { 'BufEnter', 'FocusGained' },
        pattern = '*',
        command = function(args)
          if vim.bo[args.buf].ft == 'fyler' then
            vim.cmd('wincmd L | vertical resize 40')
          end
        end,
      })
    end,
    dependencies = { 'nvim-mini/mini.icons' },
  },
  {
    'nvim-neo-tree/neo-tree.nvim',
    cond = function() return ar_config.explorer.variant == 'neo-tree' end,
    branch = 'v3.x',
    cmd = { 'Neotree' },
    keys = {
      { '<c-n>', '<cmd>Neotree toggle reveal<CR>', desc = 'toggle tree' },
    },
    opts = function()
      local lspkind = require('lspkind')
      local events = require('neo-tree.events')

      local function on_move(data) on_rename(data.source, data.destination) end

      local function disable_autosave()
        ar_config.autosave.current = ar_config.autosave.enable
        if ar_config.autosave.current then ar_config.autosave.enable = false end
      end

      local function custom_open_with_window_picker(state)
        local visible_bufs = {}
        vim.iter(api.nvim_list_wins()):each(function(w)
          local buf = api.nvim_win_get_buf(w)
          if vim.bo[buf].ft ~= 'neo-tree' then
            table.insert(visible_bufs, buf)
          end
        end)
        local commands = require('neo-tree.sources.common.commands')
        if #visible_bufs == 1 then
          commands.open(state)
        else
          commands.open_with_window_picker(state)
        end
      end

      local function image_preview(state)
        local width = state.window.width + 1
        local node = state.tree:get_node()
        if not ar.has('image.nvim') then
          ar.snacks_show_image(node:get_id())
          return
        end
        ar.show_image(node:get_id(), { col = width })
      end

      return {
        close_if_last_window = true,
        sources = { 'filesystem', 'git_status', 'document_symbols' },
        enable_opened_markers = true,
        source_selector = {
          winbar = true,
          separator_active = '',
          tabs_layout = 'center',
          sources = {
            { source = 'filesystem' },
            -- { source = 'git_status' },
            { source = 'document_symbols' },
          },
        },
        enable_git_status = false,
        enable_diagnostics = false,
        git_status_async = false,
        nesting_rules = {
          ['dart'] = { 'freezed.dart', 'g.dart' },
          ['go'] = {
            pattern = '(.*)%.go$',
            files = { '%1_test.go' },
          },
          ['docker'] = {
            pattern = '^dockerfile$',
            ignore_case = true,
            files = { '.dockerignore', 'docker-compose.*', 'dockerfile*' },
          },
        },
        event_handlers = {
          {
            event = events.NEO_TREE_BUFFER_ENTER,
            handler = function() highlight.set('Cursor', { blend = 100 }) end,
          },
          {
            event = events.NEO_TREE_POPUP_BUFFER_ENTER,
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
          {
            event = events.NEO_TREE_BUFFER_LEAVE,
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
          {
            event = events.NEO_TREE_POPUP_BUFFER_LEAVE,
            handler = function() highlight.set('Cursor', { blend = 100 }) end,
          },
          {
            event = events.NEO_TREE_WINDOW_AFTER_CLOSE,
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
          {
            event = events.NEO_TREE_POPUP_INPUT_READY,
            handler = function() vim.cmd('stopinsert') end,
          },
          {
            event = events.BEFORE_FILE_RENAME,
            handler = function() disable_autosave() end,
          },
          {
            event = events.FILE_RENAMED,
            handler = function()
              ar_config.autosave.enable = ar_config.autosave.current
            end,
          },
          {
            event = 'before_file_delete',
            handler = function() disable_autosave() end,
          },
          { event = events.FILE_MOVED, handler = on_move },
          { event = events.FILE_RENAMED, handler = on_move },
        },
        filesystem = {
          hijack_netrw_behavior = 'open_current',
          use_libuv_file_watcher = true,
          follow_current_file = {
            enabled = false,
            leave_dirs_open = true,
          },
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            never_show = { '.DS_Store' },
          },
          -- Adding custom commands for delete and delete_visual
          -- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/202#issuecomment-1428278234
          commands = {
            delete = function(state)
              local inputs = require('neo-tree.ui.inputs')
              local path = state.tree:get_node().path
              local msg = 'Are you sure you want to trash ' .. path
              inputs.confirm(msg, function(confirmed)
                if confirmed then
                  ar.trash_file(fn.fnameescape(path))
                  require('neo-tree.sources.manager').refresh(state.name)
                end
              end)
            end,
            delete_visual = function(state, selected_nodes)
              local inputs = require('neo-tree.ui.inputs')
              local function get_table_len(tbl)
                local len = 0
                for _ in pairs(tbl) do
                  len = len + 1
                end
                return len
              end
              local count = get_table_len(selected_nodes)
              local msg = 'Are you sure you want to trash '
                .. count
                .. ' files?'
              inputs.confirm(msg, function(confirmed)
                if not confirmed then return end
                for _, node in ipairs(selected_nodes) do
                  ar.trash_file(fn.fnameescape(node.path))
                end
                require('neo-tree.sources.manager').refresh(state.name)
              end)
            end,
          },
          window = {
            mappings = {
              ['<space>'] = 'none',
              ['<C-p>'] = function(state)
                local node = state.tree:get_node()
                local cwd = node.path
                if node.type == 'file' then cwd = node._parent_id end
                ar.pick('files', { cwd = cwd })()
              end,
              ['<C-g>'] = function(state)
                local node = state.tree:get_node()
                local cwd = node.path
                if node.type == 'file' then cwd = node._parent_id end
                ar.pick('live_grep', { cwd = cwd })()
              end,
              ['oi'] = function(state)
                api.nvim_input(': ' .. state.tree:get_node().path .. '<Home>')
              end,
              ['<C-o>'] = function(state)
                local node = state.tree:get_node()
                if vim.list_contains(ar.get_media(), node.ext) then
                  ar.open_media(node.path)
                else
                  vim.notify('Not a media file')
                end
              end,
              ['oP'] = function(state) copy(state.tree:get_node().path) end,
              ['oY'] = function(state) copy(state.tree:get_node().name) end,
            },
          },
        },
        default_component_configs = {
          indent = {
            with_markers = false,
            with_expanders = true,
            expander_collapsed = icons.misc.triangle_short_right,
            expander_expanded = icons.misc.triangle_short_down,
          },
          icon = {
            folder_closed = codicons.documents.folder,
            folder_open = codicons.documents.open_folder,
            folder_empty = codicons.documents.empty_folder,
            folder_empty_open = codicons.documents.empty_folder,
            default = codicons.documents.default_file,
            highlight = 'DevIconDefault',
          },
          name = { highlight_opened_files = true },
          document_symbols = {
            follow_cursor = true,
            kinds = vim.iter(lspkind.symbol_map):fold({}, function(acc, k, v)
              acc[k] = { icon = v, hl = lsp_hls[k] }
              return acc
            end),
          },
          modified = { symbol = codicons.misc.circle .. ' ' },
          git_status = {
            symbols = {
              added = codicons.git.added,
              deleted = codicons.git.removed,
              modified = codicons.git.mod,
              renamed = codicons.git.renamed,
              untracked = icons.git.untracked,
              ignored = codicons.git.ignored,
              unstaged = codicons.git.unstaged,
              staged = codicons.git.staged,
              conflict = icons.git.branch,
            },
          },
          file_size = { required_width = 50 },
          diagnostics = {
            highlights = {
              hint = 'DiagnosticHint',
              info = 'DiagnosticInfo',
              warn = 'DiagnosticWarn',
              error = 'DiagnosticError',
            },
          },
        },
        window = {
          position = 'right',
          width = 35,
          mappings = {
            ['<esc>'] = 'revert_preview',
            ['<CR>'] = custom_open_with_window_picker,
            ['<A-CR>'] = 'split_with_window_picker',
            ['l'] = 'open',
            ['o'] = 'toggle_node',
            ['P'] = { 'toggle_preview', config = { use_float = false } },
            ['v'] = 'vsplit_with_window_picker',
            ['O'] = 'expand_all_nodes',
            ['Z'] = 'close_all_nodes',
            ['K'] = image_preview,
          },
        },
      }
    end,
    config = function(_, opts)
      highlight.plugin('NeoTree', {
        theme = {
          ['onedark'] = {
            { NeoTreeNormal = { link = 'PanelBackground' } },
            { NeoTreeNormalNC = { link = 'PanelBackground' } },
            { NeoTreeRootName = { bold = false, italic = false } },
            { NeoTreeStatusLine = { link = 'PanelBackground' } },
            {
              NeoTreeTabActive = {
                bg = ar_config.ui.transparent and 'NONE'
                  or { from = 'FloatTitle' },
              },
            },
          },
        },
      })
      require('neo-tree').setup(opts)
    end,
    dependencies = {
      'MunifTanjim/nui.nvim',
      'nvim-lua/plenary.nvim',
      'razak17/lspkind.nvim',
    },
  },
  {
    'nvim-mini/mini.files',
    cond = ar_config.explorer.variant == 'mini.files',
    keys = {
      {
        '<leader>ee',
        function() require('mini.files').open(api.nvim_buf_get_name(0), true) end,
        desc = 'open mini.files (directory of current file)',
      },
      {
        '<C-n>',
        function()
          local mf = require('mini.files')
          if not mf.close() then
            mf.open(api.nvim_buf_get_name(0))
            mf.reveal_cwd()
          end
        end,
        desc = 'mini.files: full path',
      },
      {
        '<leader>ew',
        function() require('mini.files').open(vim.uv.cwd(), true) end,
        desc = 'open mini.files (cwd)',
      },
    },
    lazy = vim.fn.argc(-1) == 0, -- load early when opening a dir from the cmdline
    opts = {
      windows = { preview = true, width_focus = 30, width_preview = 50 },
      mappings = { reset = ',', reveal_cwd = '.' },
      options = { use_as_default_explorer = true, permanent_delete = false },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      ar.augroup('mini.files', {
        event = { 'User' },
        pattern = 'MiniFilesActionRename',
        command = function(event) on_rename(event.data.from, event.data.to) end,
      }, {
        event = { 'User' },
        pattern = 'MiniFilesBufferCreate',
        command = function(args)
          -- https://www.reddit.com/r/neovim/comments/1exg5ir/integration_minifiles_with_s1n7axnvimwindowpicker/
          local buf_id = args.data.buf_id
          local open_with_window_picker = function()
            local fs_entry = MiniFiles.get_fs_entry()
            if fs_entry ~= nil and fs_entry.fs_type == 'file' then
              vim.defer_fn(function()
                ar.open_with_window_picker(function(picked_window_id)
                  MiniFiles.set_target_window(picked_window_id)
                  MiniFiles.go_in({ close_on_file = true })
                end, false)
              end, 100)
            end
          end

          local get_target_dir = function()
            local fs_entry = MiniFiles.get_fs_entry()
            if not fs_entry then return nil end
            return fs_entry.fs_type == 'file'
                and vim.fn.fnamemodify(fs_entry.path, ':h')
              or fs_entry.path
          end

          local create_picker_fn = function(picker_type)
            return function()
              local cwd = get_target_dir()
              if cwd then
                MiniFiles.close()
                ar.pick(picker_type, { cwd = cwd })()
              end
            end
          end

          local find_in_dir = create_picker_fn('files')
          local grep_in_dir = create_picker_fn('live_grep')

          map('n', '<C-p>', find_in_dir, { buffer = buf_id })
          map('n', '<C-g>', grep_in_dir, { buffer = buf_id })
          map('n', 'W', open_with_window_picker, { buffer = buf_id })
        end,
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    cond = ar_config.explorer.variant == 'oil',
    keys = {
      {
        '<C-n>',
        "<Cmd>lua require('oil').open()<CR>",
        desc = 'oil: open parent directory',
      },
      {
        '-',
        "<Cmd>lua require('oil').open()<CR>",
        desc = 'oil: open parent directory',
      },
      {
        '_',
        function() require('oil').open(vim.fn.getcwd()) end,
        desc = 'oil: open cwd',
      },
      {
        '<leader>oi',
        "<Cmd>lua require('oil').open_float('.')<CR>",
        desc = 'oil: open float',
      },
    },
    opts = {
      default_file_explorer = true,
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      restore_win_options = false,
      prompt_save_on_select_new_entry = false,
      keymaps = {
        ['`'] = 'actions.tcd',
        ['~'] = '<cmd>edit $HOME<CR>',
        ['<leader>q'] = 'actions.close',
        ['<Esc>'] = 'actions.close',
        ['<leader>t'] = 'actions.open_terminal',
        ['<C-g>'] = {
          desc = 'Grep in dir',
          callback = function()
            require('fzf-lua').files({
              cmd = 'fd -t=d',
              cwd = require('oil').get_current_dir(),
            })
          end,
        },
        ['gd'] = {
          desc = 'Toggle detail view',
          callback = function()
            local oil = require('oil')
            local config = require('oil.config')
            if #config.columns == 1 then
              oil.set_columns({ 'icon', 'permissions', 'size', 'mtime' })
            else
              oil.set_columns({ 'icon' })
            end
          end,
        },
      },
      win_options = { wrap = true },
    },
  },
}
