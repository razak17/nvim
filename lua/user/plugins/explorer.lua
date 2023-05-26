local icons = rvim.ui.icons
local codicons = rvim.ui.codicons
local highlight = rvim.highlight

return {
  {
    'nvim-neo-tree/neo-tree.nvim',
    cmd = { 'Neotree' },
    branch = 'v2.x',
    keys = { { '<c-n>', '<cmd>Neotree toggle reveal<CR>', desc = 'toggle tree' } },
    config = function()
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

      vim.g.neo_tree_remove_legacy_commands = 1

      local symbols = require('lspkind').symbol_map
      local lsp_hls = rvim.ui.lsp.highlights

      require('neo-tree').setup({
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
        event_handlers = {
          {
            event = 'neo_tree_buffer_enter',
            handler = function() highlight.set('Cursor', { blend = 100 }) end,
          },
          {
            event = 'neo_tree_buffer_leave',
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
          {
            event = 'neo_tree_window_after_close',
            handler = function() highlight.set('Cursor', { blend = 0 }) end,
          },
        },
        filesystem = {
          follow_current_file = true,
          hijack_netrw_behavior = 'open_current',
          use_libuv_file_watcher = true,
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = true,
            never_show = { '.DS_Store' },
          },
          window = {
            mappings = {
              ['/'] = 'noop',
              ['g/'] = 'fuzzy_finder',
            },
          },
        },
        default_component_configs = {
          indent = {
            with_markers = false,
            with_expanders = true,
            expander_collapsed = icons.misc.triangle_short_down,
            expander_expanded = icons.misc.triangle_short_right,
          },
          icon = {
            folder_empty = codicons.documents.open_folder,
            default = codicons.documents.default_folder,
            highlight = 'DevIconDefault',
          },
          name = { highlight_opened_files = true },
          document_symbols = {
            follow_cursor = true,
            kinds = rvim.fold(function(acc, v, k)
              acc[k] = { icon = v, hl = lsp_hls[k] }
              return acc
            end, symbols),
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
            ['Z'] = 'expand_all_nodes',
          },
        },
      })
    end,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },
  {
    's1n7ax/nvim-window-picker',
    version = '*',
    config = function()
      require('window-picker').setup({
        use_winbar = 'smart',
        autoselect_one = true,
        include_current = false,
        other_win_hl_color = highlight.get('Visual', 'bg'),
        filter_rules = {
          bo = {
            filetype = { 'neo-tree-popup', 'quickfix' },
            buftype = { 'terminal', 'quickfix', 'nofile' },
          },
        },
      })
    end,
  },
  {
    'stevearc/oil.nvim',
    keys = {
      { '-', function() require('oil').open() end, desc = 'open parent directory' },
    },
    opts = { skip_confirm_for_simple_edits = true },
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
