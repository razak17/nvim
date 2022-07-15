return function()
  local icons = rvim.style.icons
  local highlights = require('zephyr.utils')
  local P = require('zephyr.palette')

  highlights.plugin('NeoTree', {
    NeoTreeIndentMarker = { link = 'Comment' },
    NeoTreeNormal = { link = 'PanelBackground' },
    NeoTreeNormalNC = { link = 'PanelBackground' },
    NeoTreeRootName = { bold = true, italic = false, foreground = P.base6 },
    NeoTreeCursorLine = { link = 'Visual' },
    NeoTreeStatusLine = { link = 'PanelSt' },
  })

  vim.g.neo_tree_remove_legacy_commands = 1

  rvim.nnoremap('<c-n>', '<Cmd>Neotree toggle reveal<CR>')

  require('which-key').register({
    ['<leader>e'] = { '<Cmd>Neotree toggle reveal<CR>', 'toggle tree' },
  })
  require('neo-tree').setup({
    enable_git_status = true,
    git_status_async = true,
    event_handlers = {
      {
        event = 'neo_tree_buffer_enter',
        handler = function() highlights.set_hl('Cursor', { blend = 100 }) end,
      },
      {
        event = 'neo_tree_buffer_leave',
        handler = function() highlights.set_hl('Cursor', { blend = 0 }) end,
      },
    },
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
    },
    default_component_configs = {
      icon = {
        folder_empty = rvim.style.icons.documents.open_folder,
      },
      git_status = {
        symbols = {
          added = icons.git.add,
          deleted = icons.git.remove,
          modified = icons.git.mod,
          renamed = icons.git.rename,
          untracked = '',
          ignored = '',
          unstaged = '',
          staged = '',
          conflict = '',
        },
      },
    },
    window = {
      position = 'right',
      width = 30,
      mappings = {
        o = 'toggle_node',
        l = 'open',
        ['<CR>'] = 'open_with_window_picker',
        ['<c-s>'] = 'split_with_window_picker',
        ['<c-v>'] = 'vsplit_with_window_picker',
      },
    },
  })
end
