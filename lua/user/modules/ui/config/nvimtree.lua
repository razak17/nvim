return function()
  local status_ok, nvim_tree = rvim.safe_require('nvim-tree')
  if not status_ok then
    return
  end

  local nvim_tree_config = require('nvim-tree.config')
  local tree_cb = nvim_tree_config.nvim_tree_callback

  rvim.nvimtree = {
    setup = {
      open_on_setup = false,
      auto_close = false,
      open_on_tab = true,
      tree_follow = true,
      hijack_cursor = true,
      disable_netrw = true,
      hijack_netrw = true,
      ignore_ft_on_setup = {
        'startify',
        'dashboard',
      },
      update_focused_file = {
        enable = true,
        update_cwd = true,
      },
      update_to_buf_dir = {
        enable = true,
        auto_open = true,
        ignore_list = {},
      },
      diagnostics = {
        enable = true,
        icons = {
          hint = '',
          info = '',
          warning = '',
          error = '',
        },
      },
      view = {
        width = 30,
        height = 30,
        side = 'right',
        auto_resize = true,
        hide_root_folder = false,
        number = false,
        relativenumber = false,
        mappings = {
          custom_only = false,
        },
      },
      filters = {
        dotfiles = false,
        custom = { '.git', 'node_modules', '.cache' },
      },
      hijack_unnamed_buffer_when_opening = true,
      sort_by = 'name', -- modification_time
      hijack_directories = {
        enable = true,
        auto_open = true,
      },
      system_open = {
        cmd = nil,
        args = {},
      },
      git = {
        enable = true,
        ignore = false,
        timeout = 500,
      },
      hide_dotfiles = false,
      ignore = { '.git', 'node_modules', '.cache', '.DS_Store' },
      actions = {
        change_dir = {
          enable = true,
          global = false,
        },
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = {
            enable = true,
            chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
            exclude = {
              filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
              buftype = { 'nofile', 'terminal', 'help' },
            },
          },
        },
      },
    },
    show_icons = {
      git = 1,
      folders = 1,
      files = 1,
      folder_arrows = 0,
      tree_width = 30,
    },
    git_hl = 1,
    indent_markers = 1,
    root_folder_modifier = ':t',
    icons = {
      default = '',
      symlink = '',
      git = {
        unstaged = '',
        staged = 'S',
        unmerged = '',
        renamed = '➜',
        untracked = 'U',
        deleted = '',
        ignored = '◌',
      },
      folder = {
        arrow_open = '',
        arrow_closed = '',
        default = '',
        open = '',
        empty = '',
        empty_open = '',
        symlink = '',
      },
    },
  }

  for opt, val in pairs(rvim.nvimtree) do
    vim.g['nvim_tree_' .. opt] = val
  end

  -- Implicitly update nvim-tree when project module is active
  if rvim.plugins.tools.project.active then
    rvim.nvimtree.respect_buf_cwd = 1
    rvim.nvimtree.setup.update_cwd = true
    rvim.nvimtree.setup.disable_netrw = false
    rvim.nvimtree.setup.hijack_netrw = false
    vim.g.netrw_banner = false
  end

  if not rvim.nvimtree.setup.view.mappings.list then
    rvim.nvimtree.setup.view.mappings.list = {
      { key = { '<CR>', 'o', '<2-LeftMouse>' }, cb = tree_cb('edit') },
      { key = 'l', cb = tree_cb('edit') },
      { key = 'h', cb = tree_cb('close_node') },
      { key = 'V', cb = tree_cb('vsplit') },
      { key = 'N', cb = tree_cb('last_sibling') },
      { key = 'I', cb = tree_cb('toggle_dotfiles') },
      { key = 'D', cb = tree_cb('dir_up') },
      { key = 'gh', cb = tree_cb('toggle_help') },
      { key = 'cd', cb = tree_cb('cd') },
      {
        key = 'gtf',
        cb = "<cmd>lua require'user.modules.tools.config.telescope.utils'.start_telescope('find_files')<cr>",
      },
      {
        key = 'gtg',
        cb = "<cmd>lua require'user.modules.tools.config.telescope.utils'.start_telescope('live_grep')<cr>",
      },
    }
  end

  require('user.utils.highlights').plugin('NvimTree', {
    NvimTreeIndentMarker = { link = 'Comment' },
    NvimTreeNormal = { link = 'PanelBackground' },
    NvimTreeNormalNC = { link = 'PanelBackground' },
    NvimTreeSignColumn = { link = 'PanelBackground' },
    NvimTreeEndOfBuffer = { link = 'PanelBackground' },
    NvimTreeVertSplit = { link = 'PanelVertSplit' },
    NvimTreeStatusLine = { link = 'PanelSt' },
    NvimTreeStatusLineNC = { link = 'PanelStNC' },
    NvimTreeRootFolder = { bold = true, foreground = 'LightMagenta' },
  })

  nvim_tree.setup(rvim.nvimtree.setup)

  require('which-key').register({
    ['<leader>e'] = { ':NvimTreeToggle<CR>', 'toggle tree' },
  })
end
