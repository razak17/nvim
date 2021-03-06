local g = vim.g
local config = {}

function config.tagalong()
  g.tagalong_filetypes = { 'html', 'xml', 'jsx', 'eruby', 'ejs', 'eco', 'php', 'htmldjango', 'javascriptreact', 'typescriptreact', 'javascript' }
  g.tagalong_verbose = 1
end

function config.far()
  local function conf( key, value)
    g[key] = value
  end

  conf('far#source', 'rgnvim')
  conf('far#window_width', 50)

  -- Use %:p with buffer option only
  conf('far#file_mask_favorites', { '%:p', '**/*.*', '**/*.js', '**/*.py', '**/*.lua', '**/*.css', '**/*.ts', '**/*.vim', '**/*.cpp', '**/*.c', '**/*.h', })
  conf('far#window_min_content_width', 30)
  conf('far#enable_undo', 1)
end

function config.rooter()
  g.rooter_change_directory_for_non_project_files = 'current'
  g.rooter_patterns = {'=src', '.git', 'Makefile', '*.sln', 'build/env.sh'}
  g.rooter_manual_only = 1
  g.rooter_silent_chdir = 1
  g.rooter_resolve_links = 1
end

function config.autopairs()
  require('nvim-autopairs').setup({
    pairs_map = {
      ["'"] = "'",
      ['"'] = '"',
      ['('] = ')',
      ['['] = ']',
      ['{'] = '}',
      ['`'] = '`',
    },
    disable_filetype = { "TelescopePrompt" , "vim" },
  })
end

function config.floaterm()
  g.floaterm_borderchars = {'─', '│', '─', '│', '╭', '╮', '╯', '╰'}
  -- vim.g.floaterm_borderchars = {'═', '║', '═', '║', '╔', '╗', '╝', '╚'}

  -- Set floaterm window's background to black
  vim.cmd("hi FloatermBorder guifg=#7ec0ee")
  vim.cmd("autocmd FileType floaterm setlocal winblend=0")

  -- vim.g.floaterm_wintype='normal'
  g.floaterm_keymap_new    = '<F7>'
  g.floaterm_keymap_prev   = '<F8>'
  g.floaterm_keymap_next   = '<F9>'
  -- vim.g.floaterm_keymap_kill   = '<F10>'
  g.floaterm_keymap_toggle = '<F12>'

  -- Floaterm
  g.floaterm_gitcommit='floaterm'
  g.floaterm_autoinsert=1
  g.floaterm_width=0.8
  g.floaterm_height=0.8
  g.floaterm_wintitle=''
  g.floaterm_autoclose=1
end

return config

