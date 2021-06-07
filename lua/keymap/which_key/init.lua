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
      x = 'close all'
    },
    F = 'resize 90%',
    h = 'horizontal split',
    n = 'no highlight',
    o = 'turn on guides',
    r = 'rename buffer',
    R = 'empty registers',
    S = 'Toggle Shade',
    u = 'undotreeToggle',
    v = 'vertical split',
    V = 'select all',
    x = 'save and exit',
    Y = 'yank all',
    z = 'force exit'
  },
  b = {
    name = '+Buffer',
    n = 'move next',
    b = 'move previous',
    d = {name = '+Delete', A = 'all', h = 'to left', x = 'all except current'},

    s = 'word'
  },
  c = {
    name = '+Command',
    a = 'vertical resize 30',
    c = 'Toggle context',
    h = {name = '+Help', w = 'word'},
    f = 'nvim-tree find',
    r = 'nvim-tree refresh',
    s = 'edit snippet',
    v = 'nvim-tree toggle'
  },
  d = {
    name = '+Debug',
    c = 'continue',
    r = {name = '+Repl', o = 'open', l = 'run last'},
    s = {name = '+Step', i = 'into', o = 'out', v = 'over'},
    b = {
      name = '+Breakpoints',
      l = 'set log point',
      s = 'set condition',
      t = 'toggle'
    }
  },
  e = {
    name = '+Floaterm',
    l = 'lazygit',
    n = 'node',
    p = 'python',
    r = 'ranger'
  },
  E = 'Inspect token',
  f = {
    name = '+Telescope',
    b = "file browser",
    c = {
      name = '+Command',
      A = 'autocmds',
      c = 'commands',
      b = 'buffers',
      e = 'planets',
      f = 'builtin',
      h = 'help',
      H = 'history',
      k = 'keymaps',
      l = 'loclist',
      m = 'man pages',
      r = 'registers',
      T = 'treesitter',
      v = 'vim options',
      z = 'current file fuzzy find'
    },
    d = {
      name = '+Dotfiles',
      b = 'branches',
      B = 'bcommits',
      c = 'commits',
      f = 'git files',
      r = 'recent files',
      s = 'status'
    },
    e = {
      name = '+Extensions',
      m = 'media files',
      b = 'change background',
      p = 'project'
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
      s = 'status'
    },
    v = {
      name = '+Lsp',
      a = 'code action',
      A = 'range code action',
      r = 'references',
      s = {name = '+Symbols', d = 'document', w = 'workspace'}
    },
    g = {
      name = '+Git',
      b = 'branches',
      c = 'commits',
      C = 'bcommits',
      f = 'files',
      s = 'status'
    }
  },
  F = {
    name = '+Far',
    f = 'replace in File',
    d = 'do',
    i = 'search iteratively',
    r = 'replace in Project',
    z = 'undo'
  },
  -- g = {
  --   name = '+Git',
  --   a = 'fetch all',
  --   b = 'branches',
  --   A = 'blame',
  --   c = {name = '+Commit', a = 'amend', m = 'message'},
  --   C = 'checkout',
  --   d = 'diff',
  --   D = 'diff split',
  --   h = 'diffget',
  --   i = 'init',
  --   k = 'diffget',
  --   l = 'log',
  --   e = 'push',
  --   p = 'poosh',
  --   P = 'pull',
  --   r = 'remove',
  --   s = 'status'
  -- },
  h = {
    name = '+Gitsigns',
    b = 'blame line',
    e = 'preview hunk',
    r = 'reset hunk',
    s = 'stage hunk',
    t = 'toggle line blame',
    u = 'undo stage hunk'
  },
  I = {name = '+Info', c = 'check health', e = 'ts info', u = 'ts update'},
  l = {name = "+LocList", i = 'empty', s = 'toggle'},
  L = {name = '+Lsp_utils', i = 'info', l = 'log', r = 'restart'},
  m = {
    name = '+Mark',
    e = 'toggle',
    b = 'previous mark',
    k = 'next mark',
    w = 'where_am_i'
  },
  n = {name = "+New", f = "open in same dir", s = "create in same dir"},
  o = {name = '+Toggle'},
  P = {
    name = '+Plug',
    c = 'compile',
    C = 'clean',
    i = 'install',
    s = 'sync',
    U = 'update'
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
    N = 'new'
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
      n = 'goto next'
    },
    D = "DOGe",
    f = 'format',
    l = 'set loc list',
    o = 'open qflist',
    s = 'Symbols outline',
    v = 'toggle virtual text',
    w = {name = '+Color', m = 'pencils'},
    x = {
      name = '+Trouble',
      d = 'document',
      e = 'quickfix',
      l = 'loclist',
      r = 'references',
      w = 'workspace'
    }
  },
  w = {
    name = "+Orientation",
    h = "change to horizontal",
    v = "change to vertical"
  }
}

r17.augroup("WhichKeyMode", {
  {
    events = {"FileType"},
    targets = {"which_key"},
    command = "set laststatus=0 noshowmode | autocmd BufLeave <buffer> set laststatus=2"
  }
})
