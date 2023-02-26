local icons = rvim.ui.icons
local highlight = rvim.highlight

return {
  'nvim-neo-tree/neo-tree.nvim',
  cmd = { 'Neotree' },
  branch = 'main',
  keys = {
    { '<c-n>', '<cmd>Neotree toggle reveal<CR>', desc = 'toggle tree' },
  },
  config = function()
    highlight.plugin('NeoTree', {
      theme = {
        ['zephyr'] = {
          { NeoTreeNormal = { link = 'PanelBackground' } },
          { NeoTreeNormalNC = { link = 'PanelBackground' } },
          { NeoTreeRootName = { bold = false, italic = false } },
          { NeoTreeStatusLine = { link = 'PanelBackground' } },
          { NeoTreeTabActive = { bg = { from = 'PanelBackground' } } },
          {
            NeoTreeTabSeparatorInactive = {
              inherit = 'NeoTreeTabInactive',
              fg = { from = 'PanelDarkBackground', attr = 'bg' },
            },
          },
          {
            NeoTreeTabSeparatorActive = {
              inherit = 'PanelBackground',
              fg = { from = 'Comment' },
            },
          },
        },
      },
    })

    vim.g.neo_tree_remove_legacy_commands = 1

    require('neo-tree').setup({
      sources = { 'filesystem', 'buffers', 'git_status', 'diagnostics' },
      source_selector = { winbar = true, separator_active = ' ' },
      enable_git_status = true,
      git_status_async = true,
      event_handlers = {
        {
          event = 'neo_tree_buffer_enter',
          handler = function() highlight.set('Cursor', { blend = 100 }) end,
        },
        {
          event = 'neo_tree_buffer_leave',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
      },
      filesystem = {
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
        icon = { folder_empty = icons.documents.open_folder },
        modified = { symbol = icons.misc.circle .. ' ' },
        git_status = {
          symbols = {
            added = icons.git.add,
            deleted = icons.git.remove,
            modified = icons.git.mod,
            renamed = icons.git.rename,
            untracked = icons.git.untracked,
            ignored = icons.git.ignore,
            unstaged = icons.git.staged,
            staged = icons.git.unstaged,
            conflict = icons.git.conflict,
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
        width = 30,
        mappings = {
          ['<esc>'] = 'revert_preview',
          ['<CR>'] = 'open_with_window_picker',
          ['<c-s>'] = 'split_with_window_picker',
          ['l'] = 'open',
          ['o'] = 'toggle_node',
          ['P'] = { 'toggle_preview', config = { use_float = true } },
          ['v'] = 'vsplit_with_window_picker',
          ['Z'] = 'expand_all_nodes',
        },
      },
    })
  end,
  dependencies = {
    's1n7ax/nvim-window-picker',
    'mrbjarksen/neo-tree-diagnostics.nvim',
    version = 'v1.*',
    config = function()
      require('window-picker').setup({
        autoselect_one = true,
        include_current = false,
        filter_rules = {
          bo = {
            filetype = { 'neo-tree-popup', 'quickfix', 'incline' },
            buftype = { 'terminal', 'quickfix', 'nofile' },
          },
        },
        other_win_hl_color = highlight.get('Visual', 'bg'),
      })
    end,
  },
}
