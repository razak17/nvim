local g, api, fn = vim.g, vim.api, vim.fn

g.which_key_sep = ''
g.which_key_timeout = 100
g.which_key_use_floating_win = 0
g.which_key_display_names = {['<CR>'] = '↵', ['<TAB>'] = '⇆'}

api.nvim_set_keymap('n', '<leader>', ':<c-u> :WhichKey "<space>"<CR>',
  {noremap = true, silent = true})
api.nvim_set_keymap('v', '<leader>', ':<c-u> :WhichKeyVisual "<space>"<CR>',
  {noremap = true, silent = true})
fn['which_key#register']('<space>', 'g:which_key_map')

g.which_key_map = {
  ['='] = 'Balance window',
  [';'] = 'terminal',
  ['.'] = 'Open init.vim',
  [','] = 'Open lua/init.lua',
  ['/'] = 'Comment',
  ['['] = 'Find and Replace all',
  [']'] = 'Find and Replace one',
  ['`'] = 'Wrap backticks',
  ["'"] = 'Wrap single quotes',
  ['"'] = 'Wrap double quotes',
  [')'] = 'Wrap parenthesis',
  ['}'] = 'Wrap curly braces',
  ['_'] = 'Delete current buffer',
  x = 'Quit',
  y = 'Yank',
  a = {
    name = '+Actions',
    ['/'] = 'comment motion default',
    d = 'force delete buffer',
    D = 'delete all',
    e = 'turn off guides',
    f = {
      name = '+Fold',
      l = 'under curosr',
      r = 'recursive cursor',
      o = 'open all',
      x = 'close all',
    },
    F = 'resize 90%',
    h = 'horizontal split',
    n = 'no highlight',
    o = 'turn on guides',
    r = 'rename buffer',
    R = 'empty registers',
    S = 'Toggle Shade',
    v = 'vertical split',
    V = 'select all',
    w = 'where_am_i',
    x = 'save and exit',
    Y = 'yank all',
    z = 'force exit',
  },
  b = {
    name = '+Buffer',
    n = 'move next',
    b = 'move previous',
    d = {name = '+Delete', a = 'all', h = 'to left', x = 'all except current'},

    s = 'word',
  },
  c = {
    name = '+Command',
    a = 'vertical resize 30',
    c = 'Toggle context',
    h = {name = '+Help', w = 'word'},
    f = 'nvim-tree find',
    r = 'nvim-tree refresh',
    s = 'edit snippet',
    v = 'nvim-tree toggle',
  },
  E = 'Inspect token',
  f = {
    name = '+Telescope',
    b = "file browser",
    c = {
      name = '+Builtin',
      a = 'autocmds',
      c = 'commands',
      b = 'buffers',
      f = 'builtin',
      h = 'help',
      H = 'history',
      k = 'keymaps',
      l = 'loclist',
      r = 'registers',
      T = 'treesitter',
      v = 'vim options',
      z = 'current file fuzzy find',
    },
    d = {
      name = '+Dotfiles',
      b = 'branches',
      B = 'bcommits',
      c = 'commits',
      f = 'git files',
      r = 'recent files',
      s = 'status',
    },
    e = {
      name = '+Extensions',
      m = 'media files',
      b = 'change background',
      p = 'project',
    },
    f = 'find files',
    l = {name = '+Live', g = 'grep', w = 'current word', e = 'prompt'},
    r = {
      name = '+Config',
      b = 'branches',
      B = 'bcommits',
      c = 'commits',
      f = 'nvim files',
      r = 'recent files',
      s = 'status',
    },
    v = {
      name = '+Lsp',
      a = 'code action',
      A = 'range code action',
      r = 'references',
      d = 'document_symbol',
      w = 'workspace_symbol',
    },
    g = {
      name = '+Git',
      b = 'branches',
      c = 'commits',
      C = 'bcommits',
      f = 'files',
      s = 'status',
    },
  },
  h = {
    name = '+Gitsigns',
    b = 'blame line',
    e = 'preview hunk',
    r = 'reset hunk',
    s = 'stage hunk',
    t = 'toggle line blame',
    u = 'undo stage hunk',
  },
  I = {
    name = '+Info',
    c = 'check health',
    e = 'ts info',
    m = 'messages',
    u = 'ts update',
    v = 'vsplit vimrc',
  },
  l = {name = "+LocList", i = 'empty', s = 'toggle'},
  L = {name = '+LspUtils', i = 'info', l = 'log', r = 'restart'},
  n = {
    name = "+New",
    f = "open file in same dir",
    s = "create new file in same dir",
  },
  o = {name = '+Toggle'},
  P = {
    name = '+Plug',
    c = 'compile',
    C = 'clean',
    i = 'install',
    s = 'sync',
    U = 'update',
  },
  s = {
    name = '+Tab',
    b = 'previous',
    d = 'close',
    H = 'move left',
    k = 'delete Session',
    K = 'last',
    n = 'next',
    L = 'move right',
    N = 'new',
  },
  S = {name = '+Session', l = 'load Session', s = 'save Session'},
  v = {
    name = '+Code',
    a = 'code action',
    A = 'range code action',
    d = {
      name = '+Diagnostics',
      b = 'goto previous',
      l = 'current line',
      n = 'goto next',
    },
    f = 'format',
    l = 'set loc list',
    o = 'open qflist',
    s = 'Symbols outline',
    v = 'toggle virtual text',
    w = {name = '+Color', m = 'pencils'},
  },
  w = {
    name = "+Orientation",
    h = "change to horizontal",
    v = "change to vertical",
  },
}

if core.plugin.debug.active then
  g.which_key_map.d = {
    name = '+Debug',
    ['?'] = 'centered float ui',
    a = 'attach',
    A = 'attach remote',
    b = 'toggle breakpoint',
    B = 'set breakpoint',
    c = 'continue',
    e = 'toggle ui',
    E = 'toggle repl',
    i = "inspect",
    k = 'up',
    l = 'osv launch',
    L = 'run last',
    n = 'down',
    r = 'open repl in vsplit',
    s = {name = "+Step", i = 'step into', o = 'step out', v = 'step over'},
    S = 'stop',
    x = 'disconnect',
  }
end

if core.plugin.fterm.active then
  g.which_key_map.e = {
    name = '+Fterm',
    g = 'gitui',
    l = 'lazygit',
    n = 'node',
    N = 'new',
    p = 'python',
    r = 'ranger',
    v = 'open vimrc in vertical split',
  }
end

if core.plugin.far.active then
  g.which_key_map.F = {
    name = '+Far',
    f = 'replace in File',
    d = 'do',
    i = 'search iteratively',
    r = 'replace in Project',
    z = 'undo',
  }
end

if core.plugin.fugitive then
  g.which_key_map.g = {
    name = '+Git',
    a = 'fetch all',
    b = 'branches',
    A = 'blame',
    c = {name = '+Commit', a = 'amend', m = 'message'},
    C = 'checkout',
    d = 'diff',
    D = 'diff split',
    h = 'diffget',
    i = 'init',
    k = 'diffget',
    l = 'log',
    e = 'push',
    p = 'poosh',
    P = 'pull',
    r = 'remove',
    s = 'status',
  }
end

if core.plugin.bookmarks.active then
  g.which_key_map.m = {
    name = '+Mark',
    e = 'toggle',
    b = 'previous mark',
    k = 'next mark',
  }
end

if core.plugin.doge.active then g.which_key_map.v.D = "DOGe" end

if core.plugin.trouble.active then
  g.which_key_map.v.x = {
    name = '+Trouble',
    d = 'document',
    e = 'quickfix',
    l = 'loclist',
    r = 'references',
    w = 'workspace',
  }
end

core.augroup("WhichKeyMode", {
  {
    events = {"FileType"},
    targets = {"which_key"},
    command = "set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2",
  },
})

