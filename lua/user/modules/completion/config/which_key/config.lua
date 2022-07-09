rvim.wk = {
  leader_mode = {
    S = 'edit snippet',
    a = {
      name = '+Actions',
      [';'] = 'open terminal',
      e = 'turn off guides',
      F = { ':vertical resize 90<CR>', 'vertical resize 90' },
      L = { ':vertical resize 40<CR>', 'vertical resize 30%%' },
      o = 'turn on guides',
      O = { ':<C-f>:resize 10<CR>', 'open old commands' },
      R = 'empty registers',
    },
    b = { name = '+Bufferline' },
    F = {
      name = '+Fold',
      l = 'under curosr',
      r = 'recursive cursor',
      o = 'open all',
      O = 'open top level',
      x = 'close all',
      z = 'refocus ',
    },
    L = {
      name = 'rVim',
      [';'] = { ':Alpha<CR>', 'alpha' },
      c = {
        "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_user_dir(), 'config/init.lua'))<CR>",
        'open config file',
      },
      C = { ':checkhealth<CR>', 'check health' },
      d = {
        "<cmd>lua vim.fn.execute('edit ' .. require('user.core.log').get_path())<CR>",
        'open rvim logfile',
      },
      l = {
        "<cmd>lua vim.fn.execute('edit ' .. vim.lsp.get_log_path())<CR>",
        'lsp: open logfile',
      },
      M = { ':messages<CR>', 'messages' },
      p = { "<cmd>exe 'edit '.stdpath('cache').'/packer.nvim.log'<CR>", 'packer: open logfile' },
      s = {
        "<cmd>lua vim.fn.execute('edit ' .. join_paths(rvim.get_cache_dir(), 'prof.log'))<CR>",
        'open startuptime logs',
      },
      v = {
        ':e ' .. join_paths(rvim.get_config_dir(), 'init.lua<CR>'),
        'open vimrc',
      },
    },
    z = { name = 'Fold' },
  },
  localleader = {
    d = { name = 'Dap' },
    l = { name = 'Lsp' },
    L = { name = 'rVim' },
    t = { name = 'Neotest' },
    w = { name = 'Window' },
  },
  visual_mode = {
    ['/'] = 'comment',
    l = { name = 'Lsp' },
    L = { name = 'rVim' },
  },
  normal_mode = {
    [']'] = {
      name = '+next',
      ['<space>'] = 'add space below',
    },
    ['['] = {
      name = '+prev',
      ['<space>'] = 'add space above',
    },
    ['ds'] = 'surround: delete',
    ['z='] = 'spell: correct an error',
  },
  plugin = {
    lsp = {
      name = '+Lsp',
      d = {
        ':Telescope diagnostics bufnr=0 theme=get_ivy<CR>',
        'telescope: document diagnostics',
      },
      c = 'peek class definition',
      u = 'peek func definition',
      h = { ':LspInfo<CR>', 'lsp: info' },
      H = { ':LspInstallInfo<CR>', 'lspinstaller: info' },
      m = { ':Mason<CR>', 'mason: info' },
      n = { ':NullLsInfo<CR>', 'null-ls: info' },
      N = { ':LspSettings buffer local<CR>', 'nlsp: buffer config' },
      R = { ':Telescope lsp_references<CR>', 'telescope: references' },
      s = { ':Telescope lsp_document_symbols<CR>', 'telescope: document symbols' },
      S = { ':Telescope lsp_dynamic_workspace_symbols<CR>', 'telescope: workspace symbols' },
      w = { ':Telescope diagnostics theme=get_ivy<CR>', 'telescope: workspace diagnostics' },
    },
    dap_ui = {
      toggle = {
        ':lua require"dapui".toggle()',
        'toggle ui',
      },
      inspect = {
        ':lua require"dap.ui.variables".hover()',
        'inspect',
      },
    },
    packer = {
      name = '+Plug',
      c = { ':PlugCompile<CR>', 'compile' },
      C = { ':PlugClean<CR>', 'clean' },
      d = { ':PlugCompiledDelete<CR>', 'delete packer_compiled' },
      u = { ':PlugUpdate<CR>', 'update' },
      e = { ':PlugCompiledEdit<CR>', 'edit packer_compiled' },
      i = { ':PlugInstall<CR>', 'install' },
      I = { ':PlugInvalidate<CR>', 'invalidate' },
      s = { ':PlugSync<CR>', 'sync' },
      S = { ':PlugStatus<CR>', 'Status' },
    },
    git = {
      name = '+Git',
      c = { ':lua _G.__fterm_cmd("git_commit")<CR>', 'commit' },
      d = { ':lua _G.__fterm_cmd("conf_commit")<CR>', 'commit dotfiles' },
    },
  },
}
