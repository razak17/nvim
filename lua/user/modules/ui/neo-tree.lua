local M = {
  'nvim-neo-tree/neo-tree.nvim',
  cmd = { 'Neotree' },
  branch = 'main',
  dependencies = {
    's1n7ax/nvim-window-picker',
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
        other_win_hl_color = require('user.utils.highlights').get('Visual', 'bg'),
      })
    end,
  },
}

function M.init()
  rvim.nnoremap('<c-n>', '<cmd>Neotree toggle reveal<CR>', 'toggle tree', 'neo-tree.nvim')
end

function M.config()
  local icons = rvim.style.icons
  local hl = require('user.utils.highlights')

  -- TODO: get working
  hl.plugin('NeoTree', {
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
    source_selector = { winbar = true, separator_active = ' ' },
    enable_git_status = true,
    git_status_async = true,
    filesystem = {
      hijack_netrw_behavior = 'open_current',
      use_libuv_file_watcher = true,
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        never_show = {
          '.DS_Store',
        },
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
        folder_empty = icons.documents.open_folder,
      },
      modified = {
        symbol = icons.misc.circle .. ' ',
      },
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
        ['o'] = 'toggle_node',
        ['l'] = 'open',
        ['<CR>'] = 'open_with_window_picker',
        ['<c-s>'] = 'split_with_window_picker',
        ['<c-v>'] = 'vsplit_with_window_picker',
        ['<esc>'] = 'revert_preview',
        ['P'] = { 'toggle_preview', config = { use_float = true } },
      },
    },
  })
end

return M
