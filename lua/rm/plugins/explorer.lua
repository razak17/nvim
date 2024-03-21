local icons, codicons, copy = rvim.ui.icons, rvim.ui.codicons, rvim.copy
local highlight, lsp_hls = rvim.highlight, rvim.ui.lsp.highlights
local lspkind = require('lspkind')

---@param from string
---@param to string
local function on_rename(from, to)
  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method('workspace/willRenameFiles') then
      ---@diagnostic disable-next-line: missing-parameter, invisible
      local resp = client.request_sync('workspace/willRenameFiles', {
        files = {
          {
            oldUri = vim.uri_from_fname(from),
            newUri = vim.uri_from_fname(to),
          },
        },
      }, 1000)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end
end

local function find_or_search_in_dir(cwd, find_or_search)
  if not rvim.is_available('telescope.nvim') then
    vim.notify('telescope.nvim is not available')
    return
  end
  if find_or_search == 'find' then
    require('telescope.builtin').find_files({
      cwd = cwd,
      hidden = true,
    })
  elseif find_or_search == 'search' then
    require('telescope.builtin').live_grep({
      cwd = cwd,
      hidden = true,
    })
  end
end

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = { 'Neotree' },
    keys = {
      { '<c-n>', '<cmd>Neotree toggle reveal<CR>', desc = 'toggle tree' },
    },
    opts = {
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
          event = 'neo_tree_buffer_enter',
          handler = function() highlight.set('Cursor', { blend = 100 }) end,
        },
        {
          event = 'neo_tree_popup_buffer_enter',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
        {
          event = 'neo_tree_buffer_leave',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
        {
          event = 'neo_tree_popup_buffer_leave',
          handler = function() highlight.set('Cursor', { blend = 100 }) end,
        },
        {
          event = 'neo_tree_window_after_close',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
        {
          event = 'neo_tree_popup_input_ready',
          handler = function(input) vim.cmd('stopinsert') end,
        },
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
        window = {
          mappings = {
            ['<space>'] = 'none',
            ['<C-p>'] = function(state)
              local node = state.tree:get_node()
              local cwd = node.path
              if node.type == 'file' then cwd = node._parent_id end

              find_or_search_in_dir(cwd, 'find')
            end,
            ['<C-g>'] = function(state)
              local node = state.tree:get_node()
              local cwd = node.path
              if node.type == 'file' then cwd = node._parent_id end

              find_or_search_in_dir(cwd, 'search')
            end,
            ['oi'] = function(state)
              vim.api.nvim_input(': ' .. state.tree:get_node().path .. '<Home>')
            end,
            ['<C-o>'] = function(state)
              local node = state.tree:get_node()
              local media_files = rvim.media_files
              if vim.list_contains(media_files, node.ext) then
                rvim.open_media(node.path)
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
            unstaged = codicons.git.staged,
            staged = codicons.git.unstaged,
            conflict = icons.git.branch,
          },
        },
        file_size = {
          required_width = 50,
        },
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
          ['<CR>'] = 'open_with_window_picker',
          ['l'] = 'open',
          ['o'] = 'toggle_node',
          ['P'] = { 'toggle_preview', config = { use_float = false } },
          ['v'] = 'vsplit_with_window_picker',
          ['O'] = 'expand_all_nodes',
          ['Z'] = 'close_all_nodes',
        },
      },
    },
    config = function(_, opts)
      highlight.plugin('NeoTree', {
        theme = {
          ['onedark'] = {
            { NeoTreeNormal = { link = 'PanelBackground' } },
            { NeoTreeNormalNC = { link = 'PanelBackground' } },
            { NeoTreeRootName = { bold = false, italic = false } },
            { NeoTreeStatusLine = { link = 'PanelBackground' } },
            { NeoTreeTabActive = { bg = { from = 'FloatTitle' } } },
            { NeoTreeTabInactive = { inherit = 'Comment', italic = false } },
            { NeoTreeTabSeparatorInactive = { link = 'WinSeparator' } },
          },
        },
      })

      local function on_move(data) on_rename(data.source, data.destination) end

      local events = require('neo-tree.events')
      opts.event_handlers = opts.event_handlers or {}
      vim.list_extend(opts.event_handlers, {
        { event = events.FILE_MOVED, handler = on_move },
        { event = events.FILE_RENAMED, handler = on_move },
      })
      require('neo-tree').setup(opts)
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    'echasnovski/mini.files',
    keys = {
      {
        '<leader>ee',
        function()
          require('mini.files').open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = 'open mini.files (directory of current file)',
      },
      {
        '<leader>ew',
        function() require('mini.files').open(vim.uv.cwd(), true) end,
        desc = 'open mini.files (cwd)',
      },
    },
    opts = {
      windows = {
        preview = true,
        width_focus = 30,
        width_preview = 30,
      },
      options = {
        -- Whether to use for editing directories
        -- Disabled by default in LazyVim because neo-tree is used for that
        use_as_default_explorer = false,
      },
    },
    config = function(_, opts)
      require('mini.files').setup(opts)

      vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesActionRename',
        callback = function(event) on_rename(event.data.from, event.data.to) end,
      })
    end,
  },
  {
    's1n7ax/nvim-window-picker',
    version = '2.*',
    keys = {
      {
        '<leader>wp',
        function()
          local picked_window_id = require('window-picker').pick_window({
            include_current_win = true,
          }) or vim.api.nvim_get_current_win()
          vim.api.nvim_set_current_win(picked_window_id)
        end,
        desc = 'pick window',
      },
      {
        '<leader>ws',
        function()
          local window = require('window-picker').pick_window({
            include_current_win = false,
          })
          local target_buffer = vim.fn.winbufnr(window)
          vim.api.nvim_win_set_buf(window, 0)
          if target_buffer ~= 0 then
            vim.api.nvim_win_set_buf(0, target_buffer)
          end
        end,
        desc = 'swap window',
      },
    },
    opts = {
      hint = 'floating-big-letter',
      selection_chars = 'OJKLP;IFDSACMRUEWQ',
      filter_rules = {
        autoselect_one = true,
        bo = {
          filetype = { 'neo-tree-popup', 'quickfix' },
          buftype = { 'terminal', 'quickfix', 'nofile' },
        },
      },
    },
  },
  {
    'stevearc/oil.nvim',
    keys = {
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
      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      restore_win_options = false,
      prompt_save_on_select_new_entry = false,
      keymaps = {
        ['`'] = 'actions.tcd',
        ['~'] = '<cmd>edit $HOME<CR>',
        ['<leader>q'] = 'actions.close',
        ['<leader>t'] = 'actions.open_terminal',
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
    },
  },
  {
    'rolv-apneseth/tfm.nvim',
    opts = { file_manager = 'yazi' },
    keys = {
      { '<leader>ej', function() require('tfm').open() end, desc = 'TFM' },
      {
        '<leader>eh',
        function()
          local tfm = require('tfm')
          tfm.open(nil, tfm.OPEN_MODE.split)
        end,
        desc = 'TFM - horizonal split',
      },
      {
        '<leader>ev',
        function()
          local tfm = require('tfm')
          tfm.open(nil, tfm.OPEN_MODE.vsplit)
        end,
        desc = 'TFM - vertical split',
      },
      {
        '<leader>et',
        function()
          local tfm = require('tfm')
          tfm.open(nil, tfm.OPEN_MODE.tabedit)
        end,
        desc = 'TFM - new tab',
      },
    },
  },
}
