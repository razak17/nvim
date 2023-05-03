local icons = rvim.ui.icons
local codicons = rvim.ui.codicons
local highlight = rvim.highlight

return {
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
          {
            NeoTreeTabSeparatorInactive = {
              inherit = 'NeoTreeTabInactive',
              fg = { from = 'PanelDarkBackground', attr = 'bg' },
            },
          },
          { NeoTreeTabSeparatorActive = { inherit = 'PanelBackground', fg = { from = 'Comment' } } },
        },
      },
    })

    vim.g.neo_tree_remove_legacy_commands = 1

    local symbols = require('lspkind').symbol_map
    local lsp_hls = rvim.ui.lsp.highlights

    require('neo-tree').setup({
      sources = { 'filesystem', 'diagnostics', 'document_symbols' },
      source_selector = {
        winbar = true,
        separator_active = '',
        sources = {
          { source = 'filesystem' },
          { source = 'document_symbols' },
          { source = 'diagnostics', display_name = (' %s Diagnostics '):format(rvim.ui.codicons.lsp.error) },
        },
      },
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
        {
          event = 'neo_tree_window_after_close',
          handler = function() highlight.set('Cursor', { blend = 0 }) end,
        },
      },
      filesystem = {
        hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = true,
        group_empty_dirs = false,
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
    'mrbjarksen/neo-tree-diagnostics.nvim',
    {
      's1n7ax/nvim-window-picker',
      version = '*',
      opts = {
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
      },
    },
  },
}
