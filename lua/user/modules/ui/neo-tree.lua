return function()
  if not rvim.plugin_installed('neo-tree.nvim') then return end
  local icons = rvim.style.icons
  local highlights = require('user.utils.highlights')

  highlights.plugin('NeoTree', {
    { NeoTreeTitleBar = { foreground = { from = 'Search' } } },
    { NeoTreeIndentMarker = { link = 'Comment' } },
    { NeoTreeNormal = { link = 'PanelBackground' } },
    { NeoTreeNormalNC = { link = 'PanelBackground' } },
    { NeoTreeRootName = { bold = true, italic = true } },
    { NeoTreeStatusLine = { link = 'PanelBackground' } },
    { NeoTreeTabActive = { bg = { from = 'PanelBackground' } } },
    {
      NeoTreeTabInactive = {
        bg = { from = 'PanelDarkBackground', alter = 15 },
        fg = { from = 'Comment' },
      },
    },
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
  })

  vim.g.neo_tree_remove_legacy_commands = 1

  rvim.nnoremap('<C-N>', '<Cmd>Neotree toggle reveal<CR>')

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
    },
    default_component_configs = {
      icon = {
        folder_empty = rvim.style.icons.documents.open_folder,
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
        ['o'] = 'toggle_node',
        ['/'] = 'noop',
        ['g/'] = 'fuzzy_finder',
        ['l'] = 'open',
        ['<CR>'] = 'open_with_window_picker',
        ['<c-s>'] = 'split_with_window_picker',
        ['<c-v>'] = 'vsplit_with_window_picker',
      },
    },
  })
end
