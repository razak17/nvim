local icons, codicons = rvim.ui.icons, rvim.ui.codicons
local highlight, lsp_hls = rvim.highlight, rvim.ui.lsp.highlights
local lspkind = require('lspkind')

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
          { source = 'git_status' },
          { source = 'document_symbols' },
        },
      },
      enable_git_status = true,
      enable_normal_mode_for_inputs = true,
      git_status_async = true,
      nesting_rules = {
        ['dart'] = { 'freezed.dart', 'g.dart' },
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
      },
      filesystem = {
        hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          never_show = { '.DS_Store' },
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
          ['<c-s>'] = 'split_with_window_picker',
          ['l'] = 'open',
          ['o'] = 'toggle_node',
          ['P'] = { 'toggle_preview', config = { use_float = false } },
          ['v'] = 'vsplit_with_window_picker',
          ['O'] = 'expand_all_nodes',
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
            { NeoTreeTabActive = { bg = { from = 'PanelBackground' } } },
            { NeoTreeTabInactive = { inherit = 'Comment', italic = false } },

            { NeoTreeTabSeparatorInactive = { link = 'WinSeparator' } },
          },
        },
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
    's1n7ax/nvim-window-picker',
    version = '2.*',
    opts = {
      hint = 'floating-big-letter',
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
        function()
          vim.cmd('vsplit | wincmd l | vertical resize 40')
          require('oil').open()
        end,
        desc = 'open parent directory',
      },
      {
        '_',
        function() require('oil').open(vim.fn.getcwd()) end,
        desc = 'Open cwd',
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
}
