if not rvim then return end
local settings, highlight = rvim.filetype_settings, rvim.highlight
local cmd, fn, api, opt_l = vim.cmd, vim.fn, vim.api, vim.opt_local

settings({
  [{ 'gitcommit', 'gitrebase' }] = {
    bo = { bufhidden = 'delete' },
    opt = {
      list = false,
      spell = true,
      spelllang = 'en_gb',
    },
  },
  ['dap-repl'] = {
    opt = {
      buflisted = false,
      winfixheight = true,
      signcolumn = 'yes:2',
    },
  },
  [{ 'typescript', 'typescriptreact' }] = {
    bo = { textwidth = 100 },
    opt = { spell = true },
  },
  -- stylua: ignore
  [{ 'python', 'rust', 'org', 'go', 'markdown' }] = {
    opt = { spell = true, },
  },
  go = {
    opt = {
      tabstop = 4,
      shiftwidth = 4,
      expandtab = false,
      iskeyword = vim.opt.iskeyword:append('-'),
    },
    function()
      require('which-key').register({ ['<localleader>g'] = { name = 'Gopher' } })
      local with_desc = function(desc) return { buffer = 0, desc = desc } end
      map('n', '<localleader>gb', '<Cmd>GoBuild<CR>', with_desc('build'))
      map('n', '<localleader>gfs', '<Cmd>GoFillStruct<CR>', with_desc('fill struct'))
      map('n', '<localleader>gfp', '<Cmd>GoFixPlurals<CR>', with_desc('fix plurals'))
      map('n', '<localleader>gie', '<Cmd>GoIfErr<CR>', with_desc('if err'))
    end,
  },
  graphql = {
    opt = {
      formatoptions = vim.opt.formatoptions:remove('t'),
      iskeyword = vim.opt.iskeyword:append('$,@-@'),
    },
  },
  help = {
    opt = {
      list = false,
      spell = true,
      textwidth = 78,
    },
    plugins = {
      ['virt-column'] = function(col)
        if not vim.bo.readonly then col.setup_buffer({ virtcolumn = '+1' }) end
      end,
    },
    function(args)
      local opts = { buffer = args.buf }
      -- if this a vim help file create mappings to make navigation easier otherwise enable preferred editing settings
      if vim.startswith(fn.expand('%'), vim.env.VIMRUNTIME) or vim.bo.readonly then
        opt_l.spell = false
        api.nvim_create_autocmd('BufWinEnter', { buffer = 0, command = 'wincmd L | vertical resize 80' })
        -- https://vim.fandom.com/wiki/Learn_to_use_help
        map('n', '<CR>', '<C-]>', opts)
        map('n', '<BS>', '<C-T>', opts)
      else
        map('n', '<leader>ml', 'maGovim:tw=78:ts=8:noet:ft=help:norl:<esc>`a', opts)
      end
    end,
  },
  httpResult = {
    function()
      api.nvim_create_autocmd('BufWinEnter', {
        buffer = 0,
        command = 'wincmd L | vertical resize 80',
      })
    end,
  },
  javascript = {
    opt = { spell = true },
  },
  json = {
    bo = {
      autoindent = true,
      expandtab = true,
      formatoptions = 'tcq2l',
      shiftwidth = 2,
      softtabstop = 2,
      tabstop = 2,
    },
    wo = {
      conceallevel = 0,
      foldmethod = 'syntax',
    },
    function()
      local filename = fn.expand('%:t')
      if filename ~= 'package.json' then return end

      require('which-key').register({ ['<localleader>'] = { p = { name = 'Package Info' } } })
      local with_desc = function(desc) return { buffer = 0, desc = desc } end
      local package_info = require('package-info')
      map('n', '<localleader>pt', package_info.toggle, with_desc('package-info: toggle'))
      map('n', '<localleader>pu', package_info.update, with_desc('package-info: update'))
      map('n', '<localleader>pd', package_info.delete, with_desc('package-info: delete'))
      map('n', '<localleader>pi', package_info.install, with_desc('package-info: install new'))
      map('n', '<localleader>pc', package_info.change_version, with_desc('package-info: change version'))
    end,
  },
  lua = {
    bo = { textwidth = 120 },
    opt = {
      spell = true,
      spelllang = 'en_gb',
      spellfile = vim.opt.spellfile:prepend(join_paths(vim.call('stdpath', 'config'), 'spell', 'lua.utf-8.add')),
      iskeyword = vim.opt.iskeyword:append('-'),
    },
  },
  NeogitCommitMessage = {
    opt = {
      list = false,
      spell = true,
      spelllang = 'en_gb',
    },
    plugins = {
      cmp = function(cmp)
        cmp.setup.filetype('NeogitCommitMessage', {
          sources = {
            { name = 'git', group_index = 1 },
            { name = 'luasnip', group_index = 1 },
            { name = 'dictionary', group_index = 1 },
            { name = 'spell', group_index = 1 },
            { name = 'buffer', group_index = 2 },
          },
        })
      end,
    },
    function()
      vim.schedule(function()
        -- Schedule this call rvim highlights are not set correctly if there is not a delay
        highlight.set_winhl('gitcommit', 0, { { VirtColumn = { fg = { from = 'Variable' } } } })
      end)
      vim.treesitter.language.register('gitcommit', 'NeogitCommitMessage')
    end,
  },
  qf = {
    opt = {
      wrap = false,
      number = false,
      signcolumn = 'yes',
      buflisted = false,
      winfixheight = true,
    },
    mappings = {
      { 'n', 'dd', rvim.list.qf.delete, desc = 'delete current quickfix entry' },
      { 'v', 'd', rvim.list.qf.delete, desc = 'delete selected quickfix entry' },
      { 'n', 'H', ':colder<CR>' },
      { 'n', 'L', ':cnewer<CR>' },
    },
    function()
      -- force quickfix to open beneath all other splits
      cmd.wincmd('J')
      rvim.adjust_split_height(3, 10)
    end,
  },
  vim = {
    wo = {
      foldmethod = 'marker',
    },
    opt = { spell = true },
  },
})
