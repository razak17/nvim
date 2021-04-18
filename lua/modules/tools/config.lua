local config = {}

function config.rnvimr()
  vim.g.rnvimr_ex_enable = 1
  vim.g.rnvimr_draw_border = 1
  vim.g.rnvimr_pick_enable = 1
  vim.g.rnvimr_bw_enable = 1
  vim.g.rnvimr_border_attr = {fg = 12, bg = -1}
end

function config.floaterm()
  vim.g.floaterm_borderchars = {
    '─',
    '│',
    '─',
    '│',
    '╭',
    '╮',
    '╯',
    '╰'
  }

  vim.cmd [[ autocmd FileType floaterm setlocal winblend=0 ]]

  vim.g.floaterm_keymap_new = '<F7>'
  vim.g.floaterm_keymap_prev = '<F8>'
  vim.g.floaterm_keymap_next = '<F9>'
  -- vim.g.floaterm_keymap_kill   = '<F10>'
  vim.g.floaterm_keymap_toggle = '<F12>'

  vim.g.floaterm_gitcommit = 'floaterm'
  vim.g.floaterm_autoinsert = 1
  vim.g.floaterm_width = 0.8
  vim.g.floaterm_height = 0.9
  vim.g.floaterm_wintitle = ''
  vim.g.floaterm_autoclose = 1
end

function config.vim_vista()
  vim.g['vista#renderer#enable_icon'] = 1
  vim.g.vista_icon_indent = [["╰─▸ "], ["├─▸ "]]
  vim.g.vista_disable_statusline = 1
  vim.g.vista_default_executive = 'ctags'
  vim.g.vista_echo_cursor_strategy = 'floating_win'
  vim.g.vista_vimwiki_executive = 'markdown'
  vim.g.vista_executive_for = {
    vimwiki = 'markdown',
    pandoc = 'markdown',
    markdown = 'toc',
    typescript = 'nvim_lsp',
    typescriptreact = 'nvim_lsp'
  }
end

function config.vim_dadbod_ui()
  vim.g.db_ui_show_help = 0
  vim.g.db_ui_win_position = 'left'
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_winwidth = 35
  vim.g.db_ui_save_location = os.getenv("HOME") .. '/.cache/vim/db_ui_queries'
  -- vim.g.dbs = load_dbs()
end

function config.bookmarks()
  vim.g.bookmark_no_default_key_mappings = 1
  vim.g.bookmark_sign = ''
end

function config.rooter()
  vim.g.rooter_patterns = {
    '.git',
    'Makefile',
    '*.sln',
    'build/env.sh',
    '.venv',
    'venv',
    'package.json'
  }
  vim.g.rooter_silent_chdir = 1
  vim.g.rooter_resolve_links = 1
end

function config.bqf()
  require('bqf').setup({
    auto_enable = true,
    preview = {win_height = 12, win_vheight = 12, delay_syntax = 80},
    func_map = {vsplit = '<C-v>', ptogglemode = 'z,', stoggleup = 'z<Tab>'},
    filter = {
      fzf = {
        action_for = {['ctrl-s'] = 'split'},
        extra_opts = {'--bind', 'ctrl-o:toggle-all', '--prompt', '> '}
      }
    }
  })
end

return config

