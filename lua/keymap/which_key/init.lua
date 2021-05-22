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
  ['_'] = 'delete current buffer',
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
    N = 'toggle line numbers',
    o = 'turn on guides',
    r = 'toggle rnvimr',
    R = 'toggle relative line numbers',
    s = 'save and exit',
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
    d = {
      name = '+Delete buffer',
      A = 'all',
      h = 'to left',
      x = 'all except current'
    },

    s = 'word'
  },
  c = {
    name = '+Command',
    a = 'vertical resize 30',
    c = 'Toggle context',
    h = {name = '+Help', w = 'word'},
    f = 'nvim-tree find',
    r = 'nvim-tree refresh',
    R = 'empty registers',
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
  f = {
    name = '+Telescope',
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
  g = {
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
    s = 'status'
  },
  h = {
    name = '+Gitsigns',
    b = 'blame line',
    e = 'preview hunk',
    r = 'reset hunk',
    s = 'stage hunk',
    t = 'toggle line blame',
    u = 'undo stage hunk'
  },
  I = {name = '+Info', c = 'check health', e = 'treesitter'},
  L = {name = '+Lsp_utils', i = 'info', l = 'log', r = 'restart'},
  m = {
    name = '+mark',
    e = 'toggle',
    b = 'previous mark',
    k = 'next mark',
    w = 'where_am_i'
  },
  o = {name = '+Toggle_cmds'},
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
  T = {name = '+Treesitter', m = 'scope incremental', n = 'init selection'},
  v = {
    name = '+Code',
    a = 'code action',
    A = 'range code action',
    c = 'find the cursor word definition and reference',
    D = 'preview definition',
    d = {
      name = '+Diagnostics',
      b = 'goto previous',
      l = 'current line',
      n = 'goto next'
    },
    f = 'format',
    l = {
      name = '+Lsp',
      l = 'set loc list',
      s = 'signature',
      e = 'type definition'
    },
    o = 'open qflist',
    r = {name = '+Rename', n = 'builtin lsp', r = 'lsp_saga'},
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
  }
}

