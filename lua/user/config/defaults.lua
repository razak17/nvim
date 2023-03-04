rvim.path = { mason = join_paths(vim.call('stdpath', 'data'), 'mason') }

rvim.ui = {
  tw = {},
  winbar = { enable = true, use_relative_path = true, use_file_icon = true },
}

rvim.editor = { auto_save = true }

rvim.lang = { format_on_save = true }

rvim.util = {
  disabled_builtins = {
    '2html_plugin',
    'gzip',
    'matchit',
    'rrhelper',
    'netrw',
    'netrwPlugin',
    'netrwSettings',
    'netrwFileHandlers',
    'zip',
    'zipPlugin',
    'tar',
    'tarPlugin',
    'getscript',
    'getscriptPlugin',
    'vimball',
    'vimballPlugin',
    'logipat',
    'spellfile_plugin',
  },
}
